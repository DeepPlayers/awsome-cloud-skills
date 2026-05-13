#!/usr/bin/env bash
# hook_confirm.sh — PreToolUse 确认钩子
# 由 Qoder IDE hooks 系统调用，statusMessage 已在 frontmatter 中声明并由 IDE 显示。
# 本脚本退出 0 表示允许继续，退出 1 表示拦截操作。
# 当前策略：直接放行（IDE 层 statusMessage 已完成人工确认）。
exit 0
