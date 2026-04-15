"""
公共工具函数模块

提供配置读取、服务域名获取、会话 ID 持久化等公共能力。
支持从 FBI 接口动态获取认证信息，本地配置作为降级方案。
"""

import os
import sys
import yaml
import requests
import json
from datetime import datetime

# 导入认证管理模块
try:
    from auth_manager import fetch_auth_properties
    AUTH_MANAGER_AVAILABLE = True
except ImportError:
    AUTH_MANAGER_AVAILABLE = False

support_agents = ["analysis", "odps_table_analysis", "askData", "reportAnalysis", "quickAnalysis",
                  "visualizeDataReport", "indicatorInspection", "find_odps_table", "find_report"]


def build_api_url(server_domain: str, path: str, config: dict = None) -> str:
    """
    构建 API 请求 URL，当配置了灰度环境时自动追加 isGrayEnv=true 参数。

    Args:
        server_domain: 服务域名，如 https://pre-fbi.alibaba-inc.com
        path: API 路径，如 /ai/FbiOpenChatBiAction/checkVersion
        config: 配置字典，用于读取 isGrayEnv 配置。若不传则不追加灰度参数

    Returns:
        完整的 API URL
    """
    url = f"{server_domain}{path}"
    if config and config.get("isGrayEnv") is True:
        separator = "&" if "?" in url else "?"
        url = f"{url}{separator}isGrayEnv=true"
    return url


def read_config() -> dict:
    """读取配置，支持动态认证和本地配置降级
    
    优先级：
    1. 从 FBI 接口动态获取认证信息（如果 auth_manager 可用）
    2. 从本地 config.yaml 读取（降级方案）
    3. 合并配置（动态认证优先）
    
    Returns:
        完整的配置字典
    """
    config_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'config.yaml')
    
    # 读取本地配置作为基础
    local_config = {}
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            local_config = yaml.safe_load(f) or {}
    except (FileNotFoundError, yaml.YAMLError) as e:
        print(f"⚠️ 读取本地配置文件失败：{e}，将尝试从接口获取")
    
    # 尝试从 FBI 接口获取动态认证信息
    dynamic_config = {}
    if AUTH_MANAGER_AVAILABLE:
        try:
            dynamic_config = fetch_auth_properties()
            if dynamic_config:
                print("✅ 已从 FBI 接口获取最新认证信息")
        except Exception as e:
            print(f"⚠️ 从接口获取认证信息失败：{e}")
            print("📋 使用本地配置文件中的认证信息")
    
    # 合并配置：动态认证 > 本地配置 > 默认值
    merged_config = {
        "server_domain": dynamic_config.get("server_domain") or local_config.get("server_domain", "https://fbi.alibaba-inc.com"),
        "app_name": dynamic_config.get("app_name") or local_config.get("app_name", ""),
        "app_secret": dynamic_config.get("app_secret") or local_config.get("app_secret", ""),
        "emp_id": dynamic_config.get("emp_id") or local_config.get("emp_id", ""),
        "assistant_id": dynamic_config.get("assistant_id") or local_config.get("assistant_id", ""),
        "model": dynamic_config.get("model") or local_config.get("model", ""),
        "query_mode": local_config.get("query_mode", "think"),
        "result_format": local_config.get("result_format", "markdown"),
        "use_env_property": local_config.get("use_env_property", False),
        "isGrayEnv": local_config.get("isGrayEnv", False),
    }
    
    # 如果仍然没有必要的认证信息，抛出错误
    required_fields = ["app_name", "app_secret", "emp_id", "assistant_id"]
    missing_fields = [f for f in required_fields if not merged_config.get(f)]
    if missing_fields:
        raise Exception(
            f"缺少必要的认证配置：{', '.join(missing_fields)}\n"
            f"请确保：\n"
            f"1. 已在浏览器中登录 FBI 系统\n"
            f"2. 访问过 https://fbi.alibaba-inc.com/ai/FbiCopilotAssistantAction/queryChatBISkillProperty\n"
            f"3. 或手动在 config.yaml 中配置这些信息"
        )
    
    # 检查是否启用环境变量读取（优先级最高）
    use_env_property = merged_config.get('use_env_property', False)
    if use_env_property:
        access_token = os.environ.get('ACCESS_TOKEN')
        if access_token:
            try:
                token_data = json.loads(access_token)
                # 映射环境变量中的字段到配置属性
                merged_config['app_name'] = token_data.get('fbi_app_name', merged_config.get('app_name'))
                merged_config['app_secret'] = token_data.get('fbi_app_secret', merged_config.get('app_secret'))
                merged_config['emp_id'] = token_data.get('fbi_emp_id', merged_config.get('emp_id'))
                merged_config['assistant_id'] = token_data.get('fbi_assistant_id', merged_config.get('assistant_id'))
            except json.JSONDecodeError as e:
                raise ValueError(f"ACCESS_TOKEN 解析失败：{e}")
        else:
            raise ValueError("use_env_property 为 true 时，必须设置 ACCESS_TOKEN 环境变量")
    
    # 请求远程系统配置并合并，本地配置优先
    remote_config = _fetch_remote_system_config(merged_config)
    if remote_config:
        for key, value in remote_config.items():
            if key not in merged_config:
                merged_config[key] = value
    
    return merged_config


def _fetch_remote_system_config(config: dict) -> dict:
    """
    请求远程系统配置接口，获取服务端下发的配置属性。

    Args:
        config: 当前已读取的本地配置，用于获取 server_domain、app_name、app_secret

    Returns:
        远程配置字典，请求失败时返回空字典
    """
    server_domain = config.get("server_domain", "")
    app_name = config.get("app_name", "")
    app_secret = config.get("app_secret", "")

    if not server_domain or not app_name or not app_secret:
        return {}

    url = build_api_url(server_domain, "/ai/FbiOpenChatBiAction/querySkillSystemConfig", config)
    headers = {"Content-Type": "application/x-www-form-urlencoded"}
    data = {
        "appParam": json.dumps({"appName": app_name, "appSecret": app_secret}),
    }

    try:
        response = requests.post(url, headers=headers, data=data, timeout=10)
        response.raise_for_status()
        result = response.json()

        if result.get("returnCode") != 0:
            return {}

        return result.get("returnValue", {}) or {}

    except (requests.exceptions.RequestException, json.JSONDecodeError):
        return {}


def get_server_domain() -> str:
    """获取服务域名"""
    config = read_config()
    return config['server_domain']


def _get_session_file_path() -> str:
    """获取会话持久化文件路径"""
    return os.path.join(
        os.path.dirname(os.path.abspath(__file__)), 'chat_bi_session_id.md'
    )


def read_session_id() -> tuple:
    """
    从 chat_bi_session_id.md 中读取已保存的会话 ID 和创建时间

    Returns:
        (session_id, created_time) 的元组，若不存在则返回 ("", "")
    """
    session_file_path = _get_session_file_path()
    if not os.path.exists(session_file_path):
        return "", ""

    with open(session_file_path, 'r', encoding='utf-8') as session_file:
        content = session_file.read()

    start_marker = "<!-- SESSION_ID_START -->"
    end_marker = "<!-- SESSION_ID_END -->"
    start_index = content.find(start_marker)
    end_index = content.find(end_marker)

    if start_index == -1 or end_index == -1:
        return "", ""

    raw_data = content[start_index + len(start_marker):end_index].strip()
    if not raw_data:
        return "", ""

    # 解析 JSON 格式的会话数据
    try:
        session_data = json.loads(raw_data)
        session_id = session_data.get("session_id", "")
        created_time = session_data.get("created_time", "")
        return session_id, created_time
    except json.JSONDecodeError:
        # 兼容旧格式：纯 session_id 文本，无创建时间
        return raw_data, ""


def write_session_id(session_id: str) -> None:
    """
    将会话 ID 和当前时间写入 chat_bi_session_id.md

    Args:
        session_id: 要持久化保存的会话 ID
    """
    session_file_path = _get_session_file_path()
    created_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    session_data = json.dumps({
        "session_id": session_id,
        "created_time": created_time
    }, ensure_ascii=False)

    start_marker = "<!-- SESSION_ID_START -->"
    end_marker = "<!-- SESSION_ID_END -->"

    if not os.path.exists(session_file_path):
        new_content = f"""# ChatBI Session ID

{start_marker}
{session_data}
{end_marker}
"""
        with open(session_file_path, 'w', encoding='utf-8') as session_file:
            session_file.write(new_content)
        return

    with open(session_file_path, 'r', encoding='utf-8') as session_file:
        content = session_file.read()

    start_index = content.find(start_marker)
    end_index = content.find(end_marker)

    if start_index == -1 or end_index == -1:
        raise Exception("chat_bi_session_id.md 格式异常，找不到标记位")

    new_content = (
        content[: start_index + len(start_marker)]
        + f"\n{session_data}\n"
        + content[end_index:]
    )

    with open(session_file_path, 'w', encoding='utf-8') as session_file:
        session_file.write(new_content)


def is_session_expired(created_time: str, expire_hours: int = 1) -> bool:
    """
    判断会话是否已过期

    Args:
        created_time: 会话创建时间字符串，格式为 "%Y-%m-%d %H:%M:%S"
        expire_hours: 过期时长（小时），默认 1 小时

    Returns:
        True 表示已过期，False 表示仍有效
    """
    if not created_time:
        return True

    try:
        created_datetime = datetime.strptime(created_time, "%Y-%m-%d %H:%M:%S")
        elapsed_seconds = (datetime.now() - created_datetime).total_seconds()
        return elapsed_seconds > expire_hours * 3600
    except ValueError:
        return True


def read_skill_version() -> str:
    """
    从 SKILL.md 的 YAML front matter 中读取技能版本号。

    Returns:
        版本号字符串，读取失败时返回 "1.0.0"
    """
    skill_md_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'SKILL.md')
    try:
        with open(skill_md_path, 'r', encoding='utf-8') as f:
            content = f.read()
        # 解析 YAML front matter（--- 之间的内容）
        if content.startswith('---'):
            end_index = content.index('---', 3)
            front_matter = content[3:end_index]
            metadata = yaml.safe_load(front_matter)
            if metadata and "version" in metadata:
                return str(metadata["version"])
    except (FileNotFoundError, ValueError, yaml.YAMLError):
        pass
    return "1.0.0"


def check_version() -> None:
    """
    校验当前技能版本是否可用。

    调用 FBI 开放接口检查版本有效性，若版本过期则打印提示信息并终止程序。
    """
    config = read_config()
    server_domain = config["server_domain"]
    version = read_skill_version()
    emp_id = str(config["emp_id"])
    app_name = config["app_name"]
    app_secret = config["app_secret"]

    url = build_api_url(server_domain, "/ai/FbiOpenChatBiAction/checkVersion", config)
    headers = {"Content-Type": "application/x-www-form-urlencoded"}

    data = {
        "version": version,
        "empId": emp_id,
        "appParam": json.dumps({"appName": app_name, "appSecret": app_secret}),
    }

    try:
        response = requests.post(url, headers=headers, data=data, timeout=30)
        response.raise_for_status()
        result = response.json()

        if result.get("returnCode") != 0:
            raise Exception(f"版本校验请求失败：{result.get('returnMessage')}")

        is_valid = result.get("returnValue", True)
        if not is_valid:
            print(f"⚠️ 当前技能版本 {version} 已过期，请重新下载最新的技能包并安装。")
            sys.exit(1)

    except requests.exceptions.RequestException as e:
        print(f"⚠️ 版本校验请求异常：{e}，跳过版本检查继续执行。")


def query_assistant_agentId(intent: str) -> str:
    """
    查询助手意图对应的可用的agent的id

    Args:
        intent: 用户问题意图

    Returns:
        agentId 意图对应的agentId
    """
    config = read_config()
    url = build_api_url(config['server_domain'], '/ai/FbiOpenChatBiAction/queryAssistantAgent', config)
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }

    data = {
        'assistantId': config['assistant_id'],
        'appParam': json.dumps({
            'appName': config['app_name'],
            'appSecret': config['app_secret']
        })
    }

    def match_agent_by_prefix(data_list, key_list):
        """
        根据 agentId 前缀匹配 key 值，构造字典
        """
        result = {}
        for item in data_list:
            agent_id = item.get("agentId", "")
            for key in key_list:
                if agent_id.startswith(key):
                    result[key] = item.get("agentId", "")
                    break
        return result

    try:
        response = requests.post(url, headers=headers, data=data, timeout=30)
        response.raise_for_status()
        result = response.json()
        if result.get("returnCode") != 0:
            raise Exception(f"查询助手技能失败：{result.get('returnMessage')}")
        agents = result.get("returnValue")
        agent_map = match_agent_by_prefix(agents, support_agents)
        if agent_map and intent in agent_map:
            return agent_map[intent]

        # 如果未找到，返回 analysis 对应的 agentId 作为默认值
        if agent_map and "analysis" in agent_map:
            return agent_map["analysis"]

        raise Exception(f"未找到意图 {intent} 对应的 agentId，请检查助手配置")

    except requests.exceptions.RequestException as e:
        print(f"请求失败：{e}")
        return None
    except json.JSONDecodeError as e:
        print(f"JSON 解析失败：{e}")
        return None


if __name__ == '__main__':
    config = read_config()
    result = query_assistant_agentId(
        assistant_id=config['assistant_id'],
        app_name=config['app_name'],
        app_secret=config['app_secret']
    )

    if result:
        print(f"获取成功：{result}")
    else:
        print("获取失败")
