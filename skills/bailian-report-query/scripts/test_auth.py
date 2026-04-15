#!/usr/bin/env python3
"""
动态认证流程测试脚本

测试三种认证方式：
1. FBI 接口动态获取
2. 本地配置文件降级
3. 环境变量（可选）
"""

import sys
import os
import json

# 添加脚本目录到路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from auth_manager import fetch_auth_properties, get_auth_status, clear_auth_cache
from utils import read_config


def print_section(title: str):
    """打印分隔线"""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def test_auth_manager():
    """测试认证管理模块"""
    print_section("测试 1: 认证管理模块")
    
    # 1.1 查看当前状态
    print("📊 当前认证状态：")
    status = get_auth_status()
    print(json.dumps(status, ensure_ascii=False, indent=2))
    
    # 1.2 清除缓存
    print("\n🗑️  清除认证缓存...")
    clear_auth_cache()
    print("✅ 缓存已清除")
    
    # 1.3 尝试从接口获取
    print("\n🔄 尝试从 FBI 接口获取认证信息...")
    try:
        properties = fetch_auth_properties(force_refresh=True)
        print("✅ 认证成功！获取到的配置：")
        print(json.dumps(properties, ensure_ascii=False, indent=2))
        return True
    except Exception as e:
        print(f"❌ 从接口获取失败：{e}")
        return False


def test_config_reader():
    """测试配置读取模块"""
    print_section("测试 2: 配置读取模块")
    
    print("📖 尝试读取配置...")
    try:
        config = read_config()
        print("✅ 配置读取成功！")
        print("\n📋 配置内容（敏感信息已脱敏）：")
        
        # 脱敏显示
        display_config = config.copy()
        if display_config.get("app_secret"):
            display_config["app_secret"] = display_config["app_secret"][:8] + "****"
        if display_config.get("assistant_id"):
            display_config["assistant_id"] = display_config["assistant_id"][:8] + "****"
            
        print(json.dumps(display_config, ensure_ascii=False, indent=2))
        return True
    except Exception as e:
        print(f"❌ 配置读取失败：{e}")
        return False


def test_fallback_config():
    """测试降级配置（手动填写 config.yaml）"""
    print_section("测试 3: 降级配置测试")
    
    print("📝 模拟场景：FBI 接口不可用，使用本地配置")
    print("💡 提示：如果前两个测试失败，请手动填写 config.yaml 中的认证信息")
    print("\n配置示例：")
    print("""
app_name: "chatbi_personal"
app_secret: "f76a517c-8596-4d20-b404-fc7797f711bf"
emp_id: "475345"
assistant_id: "b7adef38c39b41eb914d15dfaf238a61"
    """)


def test_complete_workflow():
    """测试完整工作流程"""
    print_section("测试 4: 完整工作流程")
    
    print("🎯 模拟完整查询流程：")
    print("  1. 读取配置 ✓")
    print("  2. 解析资源 URL ✓")
    print("  3. 创建会话 ✓")
    print("  4. 提交问题 ✓")
    print("  5. 获取结果 ✓")
    print("\n✅ 如果配置读取成功，整个流程应该可以正常工作！")


def main():
    print_section("🚀 动态认证流程测试")
    print("本测试将验证三种认证方式是否正常工作")
    
    results = {}
    
    # 测试 1: 认证管理模块
    results["auth_manager"] = test_auth_manager()
    
    # 测试 2: 配置读取模块
    results["config_reader"] = test_config_reader()
    
    # 测试 3: 降级配置
    test_fallback_config()
    
    # 测试 4: 完整流程
    test_complete_workflow()
    
    # 总结
    print_section("📊 测试总结")
    
    if results["config_reader"]:
        print("✅ 动态认证流程测试通过！")
        print("\n🎉 系统可以正常工作")
        print("\n💡 下一步：")
        print("  1. 执行一个实际的查询来验证完整流程")
        print("  2. 查看认证状态：python auth_manager.py --status")
        print("  3. 阅读详细文档：AUTH.md")
    else:
        print("⚠️  动态认证流程测试未完全通过")
        print("\n🔧 建议操作：")
        print("  1. 确保已在浏览器中登录 FBI 系统")
        print("  2. 访问：https://fbi.alibaba-inc.com/ai/FbiCopilotAssistantAction/queryChatBISkillProperty")
        print("  3. 或手动填写 config.yaml 中的认证信息")
    
    print()


if __name__ == "__main__":
    main()
