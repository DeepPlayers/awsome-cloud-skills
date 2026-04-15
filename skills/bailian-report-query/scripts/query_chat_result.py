"""
查询会话消息结果模块

通过轮询方式获取 ChatBI 的回复结果。
- 最大等待时间为 30 分钟（1800 秒），超时则认为任务失败
- 推荐轮询间隔为 3 秒
- 支持实时打印思考过程
"""

import json
import sys
import os
import time
import requests

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import read_config, build_api_url


# 最大轮询等待时间：30 分钟
MAX_POLL_DURATION_SECONDS = 30 * 60

# 默认轮询间隔：3 秒
DEFAULT_POLL_INTERVAL_SECONDS = 3.0


def query_update_chat(answer_message_id: str, emp_id: str = None) -> dict:
    """
    单次查询会话消息的最新状态

    Args:
        answer_message_id: create_chat 返回的 answerMessageId
        emp_id: 员工工号，不传则从配置文件读取

    Returns:
        包含 finalize、think、finalAnswer 等字段的字典
    """
    config = read_config()
    server_domain = config["server_domain"]
    app_name = config["app_name"]
    app_secret = config["app_secret"]
    emp_id = emp_id or str(config["emp_id"])

    url = build_api_url(server_domain, "/ai/FbiOpenChatBiAction/queryUpdateChat", config)
    headers = {"Content-Type": "application/x-www-form-urlencoded"}

    query_update_chat_param = {
        "updateMessageId": answer_message_id,
        "empId": emp_id,
    }

    data = {
        "queryUpdateChatParam": json.dumps(query_update_chat_param, ensure_ascii=False),
        "appParam": json.dumps({"appName": app_name, "appSecret": app_secret}, ensure_ascii=False),
    }

    response = requests.post(url, headers=headers, data=data, timeout=30)
    response.raise_for_status()

    result = response.json()
    if result.get("returnCode") != 0:
        raise Exception(f"查询会话消息失败：{result.get('returnMessage')}")

    returnValue = result.get("returnValue", {})

    # 处理报表类型 URL 信息
    report_data = returnValue.get("reportTypeUrl", {})
    if report_data:
        url = report_data.get("url", "")
        report_type = report_data.get("reportType", "")
        fbiSkipUrl = returnValue.get("fbiSkipUrl", "")
        # report 表示网页报告、ppt 表示 ppt 报告、excel 表示 excel 报告，notebook 表示数字文档，给个中文映射
        if report_type == "REPORT":
            report_type = "网页报告"
        elif report_type == "PPT":
            report_type = "PPT 报告"
        elif report_type == "EXCEL":
            report_type = "Excel 报告"
        elif report_type == "NOTEBOOK":
            report_type = "数字文档"
        _summary = ""
        if report_type:
            _summary = f"已经生成{report_type},在线报告url:{url},详细执行过程 url：{fbiSkipUrl}，可以用于问题排查和问题反馈"
        returnValue.pop("reportTypeUrl")
        returnValue.pop("fbiSkipUrl")
        returnValue["summary"] = _summary

    return returnValue


def format_result_as_json(result: dict) -> dict:
    """
    将查询结果中的 originalData 提取为结构化 JSON 格式输出。

    从 originalData.general.sqlDatas 中提取每个查询的列定义和行数据，
    组装为 {columns, data, query, summary} 的结构化格式。

    Args:
        result: query_update_chat 返回的原始结果字典

    Returns:
        结构化的 JSON 结果字典
    """
    original_data = result.get("originalData", {})
    general = original_data.get("general", {})
    question_summary = general.get("question_summary", "")
    sql_datas = general.get("sqlDatas", [])

    formatted_queries = []
    for sql_data in sql_datas:
        columns = sql_data.get("columns", [])
        rows = sql_data.get("rows", [])
        query = sql_data.get("query", "")
        summary = sql_data.get("summary", "")

        # 将行数据转为字典列表，每行按列名映射
        column_names = [col.get("dataIndex", "") for col in columns]
        row_dicts = []
        for row in rows:
            row_dict = {}
            for idx, col_name in enumerate(column_names):
                row_dict[col_name] = row[idx] if idx < len(row) else None
            row_dicts.append(row_dict)

        formatted_queries.append({
            "query": query,
            "summary": summary,
            "columns": columns,
            "data": row_dicts,
        })

    return {
        "question_summary": question_summary,
        "queries": formatted_queries,
    }


def poll_until_finished(
    answer_message_id: str,
    poll_interval: float = DEFAULT_POLL_INTERVAL_SECONDS,
    show_think: bool = True,
) -> dict:
    """
    持续轮询直到获取最终结果或超时

    Args:
        answer_message_id: create_chat 返回的 answerMessageId
        poll_interval: 轮询间隔秒数，默认 3 秒
        show_think: 是否实时打印思考过程，默认打印

    Returns:
        包含最终结果的字典，含 finalAnswer、fbiSkipUrl、reportTypeUrl 等字段

    Raises:
        TimeoutError: 超过最大等待时间（30 分钟）仍未获取到结果
    """
    start_time = time.time()
    accumulated_think = ""
    poll_count = 0

    if show_think:
        print("开始轮询，等待 ChatBI 处理中...\n")

    while True:
        elapsed_seconds = time.time() - start_time
        if elapsed_seconds > MAX_POLL_DURATION_SECONDS:
            raise TimeoutError(
                f"轮询超时：已等待 {MAX_POLL_DURATION_SECONDS // 60} 分钟，任务仍未完成"
            )

        poll_count += 1
        update_result = query_update_chat(answer_message_id)
        is_finalized = update_result.get("finalize", False)
        current_think = update_result.get("think", "")

        # 打印增量思考内容
        if show_think and current_think:
            incremental_think = current_think[len(accumulated_think):]
            if incremental_think:
                print(incremental_think, end="", flush=True)
            accumulated_think = current_think

        if is_finalized:
            if show_think and accumulated_think:
                print()  # 思考过程结束后换行
            return update_result

        time.sleep(poll_interval)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法：python query_chat_result.py <answerMessageId> [轮询间隔秒数]")
        print("示例：python query_chat_result.py 'fb7bb646ab474ef0a2870715d19aab3f'")
        sys.exit(1)

    target_answer_message_id = sys.argv[1]
    target_poll_interval = float(sys.argv[2]) if len(sys.argv) > 2 else DEFAULT_POLL_INTERVAL_SECONDS

    print(f"开始查询消息 ID：{target_answer_message_id}")
    final_result = poll_until_finished(
        answer_message_id=target_answer_message_id,
        poll_interval=target_poll_interval,
        show_think=True,
    )

    print("\n========== 最终结果 ==========")
    if "think" in final_result:
        final_result.pop("think")

    config = read_config()
    result_format = config.get("result_format", "markdown")
    # 极速模式下 result_format 强制为 json
    query_mode = config.get("query_mode", "think")
    if query_mode == "quick":
        result_format = "json"

    if result_format == "json" and final_result.get("originalData"):
        json_result = format_result_as_json(final_result)
        print(json.dumps(json_result, ensure_ascii=False, indent=2))
    else:
        # markdown 格式：移除 originalData 避免输出过多原始数据
        if "originalData" in final_result:
            final_result.pop("originalData")
        print(json.dumps(final_result, ensure_ascii=False, indent=2))
