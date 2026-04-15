"""
创建会话消息模块

向 ChatBI 提交用户问题，返回用于后续轮询的 answerMessageId。
意图固定使用 analysis（数据分析），支持传入资源信息（报表、数据集等）以关联具体资源。
"""

import json
import sys
import os
import requests

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import read_config, query_assistant_agentId, check_version, build_api_url
from chat_bi_session import get_or_create_session


def create_chat(
        question: str,
        resource_info: dict = None,
        session_id: str = None,
        parent_message_id: str = "",
        deep_think_mode: bool = False,
        not_use_web_search_tool: bool = False,
        not_use_clarify_tool: bool = True,
        attachments: list = None,
) -> dict:
    """
    创建会话消息，提交用户问题

    Args:
        question: 用户输入的问题
        resource_info: 资源信息字典，用于关联具体资源。格式示例：
                       - 报表：{"resourceId": "1659642", "resourceType": "report"}
                       - 数据集：{"resourceId": "71959005", "resourceType": "dataset"}
                       传入后会自动构建 attachments
        session_id: 会话 ID，不传则自动从文件读取或创建新会话
        parent_message_id: 多轮对话时上一轮回答的消息 ID，首次对话不传
        deep_think_mode: 是否开启深度思考，默认开启
        not_use_web_search_tool: 是否禁用联网搜索工具，默认不禁用
        not_use_clarify_tool: 是否禁用问题澄清反问工具，默认禁用
        attachments: 附件列表，直接指定附件内容。若同时传入了 resource_info，resource_info 优先

    Returns:
        包含 answerMessageId 和 questionMessageId 的字典
    """
    config = read_config()
    server_domain = config["server_domain"]
    app_name = config["app_name"]
    app_secret = config["app_secret"]
    emp_id = str(config["emp_id"])
    model = config.get("model", "")
    assistant_id = config["assistant_id"]

    # 自动获取会话 ID
    if not session_id:
        session_id = get_or_create_session()

    # 获取 askData 意图对应的 agentId
    custom_agent_id = config["agent_id"] if "agent_id" in config else query_assistant_agentId("askData")

    # 查询模式：quick（极速模式）、think（思考模式）
    query_mode = config.get("query_mode", "think")
    is_instant_query = query_mode == "quick"

    url = build_api_url(server_domain, "/ai/FbiOpenChatBiAction/createChat", config)
    headers = {"Content-Type": "application/x-www-form-urlencoded"}

    create_chat_param = {
        "sessionId": session_id,
        "customAgentId": custom_agent_id,
        "question": question,
        "empId": emp_id,
        "parentMessageId": parent_message_id,
        "model": model,
        "deepThinkMode": str(deep_think_mode).lower(),
        "notUseWebSearchTool": str(not_use_web_search_tool).lower(),
        "notUseClarifyTool": str(not_use_clarify_tool).lower(),
        "instantQueryMode": is_instant_query,
    }

    # 若传入了资源信息，自动构建附件
    if resource_info and not attachments:
        attachments = [
            {
                "type": "inner_resource",
                "subType": resource_info.get("resourceType", "report"),
                "resourceId": str(resource_info.get("resourceId", ""))
            }
        ]

    # 添加附件信息
    if attachments:
        create_chat_param["attachments"] = attachments

    data = {
        "createChatParam": json.dumps(create_chat_param),
        "appParam": json.dumps({"appName": app_name, "appSecret": app_secret}),
    }

    response = requests.post(url, headers=headers, data=data, timeout=30)
    response.raise_for_status()

    result = response.json()
    if result.get("returnCode") != 0:
        raise Exception(f"创建会话消息失败：{result.get('returnMessage')}")

    return_value = result.get("returnValue", {})
    answer_message_id = return_value.get("answerMessageId")
    if not answer_message_id:
        raise Exception("创建会话消息失败：接口未返回有效的 answerMessageId")
    return return_value


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print('用法：python create_chat.py <问题> [资源信息JSON]')
        print('  资源信息JSON 格式：\'{"resourceId": "<id>", "resourceType": "<type>"}\'')
        print('  resourceType 支持：report（报表）、dataset（数据集）')
        print("示例：")
        print("  python create_chat.py '查询本月内，地区=华东下，销售额按求和统计'")
        print("""  python create_chat.py '查询上月内，地区=华东、渠道=APP下，订单量按求和统计' '{"resourceId": "1659642", "resourceType": "report"}'""")
        sys.exit(1)

    check_version()
    user_question = sys.argv[1]
    resource_info_str = sys.argv[2] if len(sys.argv) > 2 else ""

    # 解析资源信息 JSON
    user_resource_info = None
    if resource_info_str:
        try:
            user_resource_info = json.loads(resource_info_str)
        except json.JSONDecodeError:
            print(f"资源信息 JSON 解析失败：{resource_info_str}")
            sys.exit(1)

    print(f"正在提交问题：{user_question}")
    if user_resource_info:
        print(f"关联资源：{user_resource_info.get('resourceId')}（类型：{user_resource_info.get('resourceType')}）")
    chat_result = create_chat(user_question, resource_info=user_resource_info)
    print(f"提交成功！")
    print(f"answerMessageId: {chat_result.get('answerMessageId')}")
    print(f"questionMessageId: {chat_result.get('questionMessageId')}")
