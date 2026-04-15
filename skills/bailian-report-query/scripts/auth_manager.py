"""
认证管理模块

负责从 FBI 开放接口动态获取 ChatBI 技能认证属性。
支持本地缓存，避免重复请求。
"""

import os
import sys
import json
import time
import requests
from datetime import datetime, timedelta

# 认证缓存文件路径
AUTH_CACHE_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'auth_cache.json')

# 缓存有效期：30 分钟（秒）
CACHE_EXPIRE_SECONDS = 30 * 60


def fetch_auth_properties(force_refresh: bool = False) -> dict:
    """
    从 FBI 接口获取 ChatBI 技能认证属性
    
    Args:
        force_refresh: 是否强制刷新（忽略缓存）
    
    Returns:
        包含认证属性的字典：
        {
            "app_name": "chatbi_personal",
            "app_secret": "f76a517c-8596-4d20-b404-fc7797f711bf",
            "emp_id": "475345",
            "assistant_id": "b7adef38c39b41eb914d15dfaf238a61",
            "server_domain": "https://fbi.alibaba-inc.com",
            "model": "qwen3.5-plus"
        }
    
    Raises:
        Exception: 获取失败时抛出异常
    """
    # 尝试从缓存读取
    if not force_refresh:
        cached = _read_cache()
        if cached and not _is_cache_expired(cached):
            return cached.get("properties", {})
    
    # 从接口获取
    properties = _fetch_from_api()
    
    # 保存到缓存
    _save_cache(properties)
    
    return properties


def _fetch_from_api() -> dict:
    """
    从 FBI 开放接口获取认证属性
    
    Returns:
        认证属性字典
    
    Raises:
        Exception: 请求失败或返回异常时抛出
    """
    url = "https://fbi.alibaba-inc.com/ai/FbiCopilotAssistantAction/queryChatBISkillProperty"
    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
        "Accept": "application/json, text/plain, */*",
        "Accept-Encoding": "gzip, deflate, br",
        "Connection": "keep-alive",
    }
    
    try:
        response = requests.get(url, headers=headers, timeout=10, allow_redirects=False)
        
        # 检查是否需要登录（302 重定向到登录页）
        if response.status_code == 302:
            raise Exception(
                "未登录或登录已过期，请先在浏览器中访问以下链接完成认证：\n"
                "https://fbi.alibaba-inc.com/ai/FbiCopilotAssistantAction/queryChatBISkillProperty\n\n"
                "认证成功后，再次执行即可获取认证信息。"
            )
        
        response.raise_for_status()
        result = response.json()
        
        # 检查返回码
        if result.get("returnCode") != 0:
            raise Exception(f"接口返回错误：{result.get('returnMessage', '未知错误')}")
        
        # 提取 returnValue
        return_value = result.get("returnValue")
        if not return_value:
            raise Exception("接口未返回有效的认证信息")
        
        # 映射字段名（接口返回的是下划线，配置文件使用的是相同的）
        properties = {
            "app_name": return_value.get("app_name", ""),
            "app_secret": return_value.get("app_secret", ""),
            "emp_id": return_value.get("emp_id", ""),
            "assistant_id": return_value.get("assistant_id", ""),
            "server_domain": return_value.get("server_domain", "https://fbi.alibaba-inc.com"),
            "model": return_value.get("model", ""),
        }
        
        # 验证必要字段
        required_fields = ["app_name", "app_secret", "emp_id", "assistant_id"]
        missing_fields = [f for f in required_fields if not properties.get(f)]
        if missing_fields:
            raise Exception(f"认证信息缺少必要字段：{', '.join(missing_fields)}")
        
        return properties
        
    except requests.exceptions.RequestException as e:
        raise Exception(f"请求认证接口失败：{e}")
    except json.JSONDecodeError as e:
        raise Exception(f"解析认证接口响应失败：{e}")


def _read_cache() -> dict:
    """
    读取缓存文件
    
    Returns:
        缓存数据字典，读取失败返回 None
    """
    try:
        if not os.path.exists(AUTH_CACHE_FILE):
            return None
        
        with open(AUTH_CACHE_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError):
        return None


def _save_cache(properties: dict) -> None:
    """
    保存认证信息到缓存文件
    
    Args:
        properties: 认证属性字典
    """
    cache_data = {
        "timestamp": time.time(),
        "cached_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "properties": properties
    }
    
    try:
        with open(AUTH_CACHE_FILE, 'w', encoding='utf-8') as f:
            json.dump(cache_data, f, ensure_ascii=False, indent=2)
    except IOError as e:
        print(f"⚠️ 保存认证缓存失败：{e}")


def _is_cache_expired(cache_data: dict) -> bool:
    """
    检查缓存是否过期
    
    Args:
        cache_data: 缓存数据字典
    
    Returns:
        True 表示已过期，False 表示未过期
    """
    if not cache_data or "timestamp" not in cache_data:
        return True
    
    elapsed = time.time() - cache_data["timestamp"]
    return elapsed > CACHE_EXPIRE_SECONDS


def clear_auth_cache() -> bool:
    """
    清除认证缓存
    
    Returns:
        是否成功清除
    """
    try:
        if os.path.exists(AUTH_CACHE_FILE):
            os.remove(AUTH_CACHE_FILE)
            return True
        return False
    except IOError:
        return False


def get_auth_status() -> dict:
    """
    获取认证状态信息
    
    Returns:
        认证状态字典
    """
    cache = _read_cache()
    
    if cache and not _is_cache_expired(cache):
        return {
            "status": "valid",
            "cached_at": cache.get("cached_at", "未知"),
            "expires_in": max(0, int(CACHE_EXPIRE_SECONDS - (time.time() - cache["timestamp"]))),
            "properties": cache.get("properties", {})
        }
    else:
        return {
            "status": "expired" if cache else "none",
            "message": "认证缓存已过期" if cache else "无认证缓存，需要重新获取"
        }


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="认证管理工具")
    parser.add_argument("--refresh", action="store_true", help="强制刷新认证信息")
    parser.add_argument("--clear", action="store_true", help="清除认证缓存")
    parser.add_argument("--status", action="store_true", help="查看认证状态")
    
    args = parser.parse_args()
    
    if args.clear:
        if clear_auth_cache():
            print("✅ 认证缓存已清除")
        else:
            print("⚠️ 无缓存文件")
        sys.exit(0)
    
    if args.status:
        status = get_auth_status()
        print(json.dumps(status, ensure_ascii=False, indent=2))
        sys.exit(0)
    
    # 获取认证信息
    try:
        properties = fetch_auth_properties(force_refresh=args.refresh)
        print("✅ 认证成功！获取到的配置：")
        print(json.dumps(properties, ensure_ascii=False, indent=2))
    except Exception as e:
        print(f"❌ 认证失败：{e}")
        sys.exit(1)
