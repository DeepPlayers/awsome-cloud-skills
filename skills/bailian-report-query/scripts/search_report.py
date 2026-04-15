"""
资源 URL 解析模块

通过用户提供的 FBI 资源 URL 解析出资源 ID 和资源类型（dataset 或 report）。
"""

import json
import sys
import os
import requests

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import read_config, build_api_url

def parse_resource_id_by_url(url: str) -> dict:
    """
    通过资源 URL 解析出资源 ID 和资源类型

    调用 FBI 开放接口，从用户提供的 URL 中提取对应的资源 ID 和资源类型。

    Args:
        url: 用户输入的 FBI 资源页面 URL，
             例如 https://fbi.alibaba-inc.com/fbi/dataset/71959005/edit.htm
             或   https://fbi.alibaba-inc.com/fbi/site/page.htm?id=53694&menuId=3

    Returns:
        包含 resource_id、resource_type、source_url 的字典；解析失败时抛出异常
    """
    config = read_config()
    server_domain = config["server_domain"]

    api_url = build_api_url(server_domain, "/ai/FbiOpenChatBiAction/parseResourceIdByUrl", config)

    headers = {"Content-Type": "application/x-www-form-urlencoded"}

    data = {"url": url}

    response = requests.post(api_url, headers=headers, data=data, timeout=30)
    response.raise_for_status()

    if not response.text or not response.text.strip():
        raise Exception(f"解析资源 URL 失败：接口返回空响应（HTTP {response.status_code}）")

    try:
        result = response.json()
    except requests.exceptions.JSONDecodeError:
        raise Exception(f"解析资源 URL 失败：接口返回非 JSON 格式内容，响应内容：{response.text[:200]}")

    if result.get("returnCode") != 0:
        raise Exception(f"解析资源 URL 失败：{result.get('returnMessage')}")

    return_value = result.get("returnValue")
    if not return_value:
        raise Exception("解析资源 URL 未返回有效结果")

    resource_id = return_value.get("resourceId")
    resource_type = return_value.get("resourceType")

    if not resource_id:
        raise Exception("解析资源 URL 未返回有效的资源 ID")

    return {
        "resource_id": str(resource_id),
        "resource_type": resource_type,
        "source_url": url,
    }

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法：python search_report.py <资源URL>")
        print("示例：")
        print('  python search_report.py "https://fbi.alibaba-inc.com/fbi/dataset/71959005/edit.htm"')
        print('  python search_report.py "https://fbi.alibaba-inc.com/fbi/site/page.htm?id=53694&menuId=3"')
        sys.exit(1)
    resource_url = sys.argv[1]
    parsed_result = parse_resource_id_by_url(resource_url)
    print(json.dumps(parsed_result, ensure_ascii=False, indent=2))
