#!/usr/bin/env bash
# ============================================================
# HappyHorse 环境检查脚本
# 检查 ossutil 安装状态和 ~/.happy-horse.env 配置状态
# 输出清晰的状态报告，供 Agent 判断哪些配置缺失
# ============================================================

ENV_FILE="$HOME/.happy-horse.env"

# 加载现有配置
[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"

echo "==============================="
echo "  HappyHorse 环境检查报告"
echo "==============================="
echo ""

# ---------- 1. 检查 ossutil ----------
echo "【ossutil】"
if command -v ossutil &>/dev/null; then
  OSSUTIL_VER=$(ossutil version 2>/dev/null | head -1 || echo "已安装")
  echo "  状态: ✅ 已安装 - $OSSUTIL_VER"
else
  echo "  状态: ❌ 未安装"
  OS=$(uname -s)
  ARCH=$(uname -m)
  echo "  系统: $OS / $ARCH"
  if [[ "$OS" == "Darwin" && "$ARCH" == "arm64" ]]; then
    echo "  安装命令:"
    echo "    curl -o /tmp/ossutil.zip https://gosspublic.alicdn.com/ossutil/v2/2.2.2/ossutil-2.2.2-mac-arm64.zip"
    echo "    unzip /tmp/ossutil.zip -d /tmp/"
    echo "    chmod 755 /tmp/ossutil-2.2.2-mac-arm64/ossutil"
    echo "    sudo mv /tmp/ossutil-2.2.2-mac-arm64/ossutil /usr/local/bin/"
  elif [[ "$OS" == "Darwin" && "$ARCH" == "x86_64" ]]; then
    echo "  安装命令:"
    echo "    curl -o /tmp/ossutil.zip https://gosspublic.alicdn.com/ossutil/v2/2.2.2/ossutil-2.2.2-mac-amd64.zip"
    echo "    unzip /tmp/ossutil.zip -d /tmp/"
    echo "    chmod 755 /tmp/ossutil-2.2.2-mac-amd64/ossutil"
    echo "    sudo mv /tmp/ossutil-2.2.2-mac-amd64/ossutil /usr/local/bin/"
  elif [[ "$OS" == "Linux" && "$ARCH" == "x86_64" ]]; then
    echo "  安装命令:"
    echo "    curl -o /tmp/ossutil.zip https://gosspublic.alicdn.com/ossutil/v2/2.2.2/ossutil-2.2.2-linux-amd64.zip"
    echo "    unzip /tmp/ossutil.zip -d /tmp/"
    echo "    chmod 755 /tmp/ossutil-2.2.2-linux-amd64/ossutil"
    echo "    sudo mv /tmp/ossutil-2.2.2-linux-amd64/ossutil /usr/local/bin/"
  elif [[ "$OS" == "Linux" && "$ARCH" == "aarch64" ]]; then
    echo "  安装命令:"
    echo "    curl -o /tmp/ossutil.zip https://gosspublic.alicdn.com/ossutil/v2/2.2.2/ossutil-2.2.2-linux-arm64.zip"
    echo "    unzip /tmp/ossutil.zip -d /tmp/"
    echo "    chmod 755 /tmp/ossutil-2.2.2-linux-arm64/ossutil"
    echo "    sudo mv /tmp/ossutil-2.2.2-linux-arm64/ossutil /usr/local/bin/"
  else
    echo "  请参考 skill 目录 reference/ossutils-quick.md 手动安装"
  fi
fi
echo ""

# ---------- 2. 检查配置文件 ----------
echo "【配置文件】"
if [[ -f "$ENV_FILE" ]]; then
  echo "  路径: ✅ $ENV_FILE"
else
  echo "  路径: ❌ $ENV_FILE（不存在，将在保存配置时自动创建）"
fi
echo ""

# ---------- 3. 检查必填变量 ----------
echo "【API Key 配置】"
if [[ -n "${DASHSCOPE_API_KEY:-}" ]]; then
  MASKED="${DASHSCOPE_API_KEY:0:8}****${DASHSCOPE_API_KEY: -4}"
  echo "  DASHSCOPE_API_KEY: ✅ 已设置 ($MASKED)"
else
  echo "  DASHSCOPE_API_KEY: ❌ 未设置（百炼平台 API Key，必填）"
fi
echo ""

echo "【OSS 配置（上传本地文件时必填）】"
if [[ -n "${OSS_ACCESS_KEY_ID:-}" ]]; then
  MASKED="${OSS_ACCESS_KEY_ID:0:6}****${OSS_ACCESS_KEY_ID: -4}"
  echo "  OSS_ACCESS_KEY_ID:     ✅ 已设置 ($MASKED)"
else
  echo "  OSS_ACCESS_KEY_ID:     ❌ 未设置"
fi

if [[ -n "${OSS_ACCESS_KEY_SECRET:-}" ]]; then
  echo "  OSS_ACCESS_KEY_SECRET: ✅ 已设置 (已隐藏)"
else
  echo "  OSS_ACCESS_KEY_SECRET: ❌ 未设置"
fi

if [[ -n "${OSS_BUCKET:-}" ]]; then
  echo "  OSS_BUCKET:            ✅ 已设置 ($OSS_BUCKET)"
else
  echo "  OSS_BUCKET:            ❌ 未设置（OSS Bucket 名称）"
fi

if [[ -n "${OSS_REGION:-}" ]]; then
  echo "  OSS_REGION:            ✅ 已设置 ($OSS_REGION)"
else
  echo "  OSS_REGION:            ❌ 未设置（如 cn-hangzhou）"
fi
echo ""

# ---------- 4. 最终状态 ----------
MISSING=0
[[ -z "${DASHSCOPE_API_KEY:-}" ]] && ((MISSING++))

echo "==============================="
if [[ $MISSING -eq 0 ]]; then
  echo "  ✅ 核心配置完整，可以使用 happyhorse.sh"
else
  echo "  ⚠️  有 $MISSING 个必填配置缺失"
  echo "  请向 Agent 提供缺失的值，Agent 将自动保存到 $ENV_FILE"
fi
echo "==============================="
