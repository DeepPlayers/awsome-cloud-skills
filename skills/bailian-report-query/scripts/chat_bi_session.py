"""
会话管理模块

负责 ChatBI 会话的创建与持久化。
- 优先从 chat_bi_session_id.md 中读取已有会话 ID，避免重复创建
- 若不存在有效会话 ID，则调用 ChatBI 开放接口创建新会话，并将结果写入文件
"""

import json
import sys
import os
import requests

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import read_config, read_session_id, write_session_id, is_session_expired, check_version, build_api_url


def create_session(session_name: str = "skill数据分析会话", need_check_permission: bool = True) -> str:
    """
    调用 ChatBI 开放接口创建新会话

    Args:
        session_name: 会话名称
        need_check_permission: 是否校验访问人是否有助手的使用权限

    Returns:
        新创建的会话 ID
    """
    config = read_config()
    server_domain = config["server_domain"]
    app_name = config["app_name"]
    app_secret = config["app_secret"]
    emp_id = config["emp_id"]
    assistant_id = config["assistant_id"]

    url = build_api_url(server_domain, "/ai/FbiOpenChatBiAction/createSession", config)
    headers = {"Content-Type": "application/x-www-form-urlencoded"}

    create_session_param = {
        "assistantId": assistant_id,
        "name": session_name,
        "empId": str(emp_id),
        "needCheckPermission": str(need_check_permission).lower(),
    }

    data = {
        "createSessionParam": json.dumps(create_session_param),
        "appParam": json.dumps({"appName": app_name, "appSecret": app_secret}),
    }

    response = requests.post(url, headers=headers, data=data, timeout=30)
    response.raise_for_status()

    result = response.json()
    if result.get("returnCode") != 0:
        raise Exception(f"创建会话失败：{result.get('returnMessage')}")

    session_id = result.get("returnValue")
    if not session_id:
        raise Exception("创建会话失败：接口未返回有效的会话 ID")

    return session_id


def get_or_create_session(session_name: str = "ChatBI 会话") -> str:
    """
    获取有效的会话 ID：优先读取已保存的会话 ID，若不存在或已过期则自动创建并持久化。
    会话创建超过 1 小时后自动失效，再次对话时会创建新会话。

    Args:
        session_name: 新建会话时使用的会话名称

    Returns:
        可用的会话 ID
    """
    existing_session_id, created_time = read_session_id()

    if existing_session_id:
        if is_session_expired(created_time):
            print(f"会话已过期（创建于 {created_time}），正在创建新会话...")
        else:
            print(f"使用已有会话 ID：{existing_session_id}（创建于 {created_time}）")
            return existing_session_id
    else:
        print("未找到已有会话，正在创建新会话...")

    new_session_id = create_session(session_name)
    write_session_id(new_session_id)
    print(f"新会话已创建并保存：{new_session_id}")
    return new_session_id


def clear_session() -> bool:
    """
    清除已保存的会话 ID

    Returns:
        是否成功清除
    """
    session_file_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), '..', 'chat_bi_session_id.md'
    )
    if not os.path.exists(session_file_path):
        return False

    with open(session_file_path, 'r', encoding='utf-8') as session_file:
        content = session_file.read()

    start_marker = "<!-- SESSION_ID_START -->"
    end_marker = "<!-- SESSION_ID_END -->"
    start_index = content.find(start_marker)
    end_index = content.find(end_marker)

    if start_index == -1 or end_index == -1:
        return False

    new_content = (
        content[: start_index + len(start_marker)]
        + "\n"
        + content[end_index:]
    )

    with open(session_file_path, 'w', encoding='utf-8') as session_file:
        session_file.write(new_content)

    return True


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--clear":
        # 清除会话
        if clear_session():
            print("会话 ID 已清除，下次使用时会创建新会话")
        else:
            print("未找到会话文件")
        sys.exit(0)

    check_version()
    session_name = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] != "--clear" else "ChatBI 会话"
    session_id = get_or_create_session(session_name)
    print(f"当前会话 ID：{session_id}")
