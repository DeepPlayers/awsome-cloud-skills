#!/usr/bin/env bash
# ============================================================
# HappyHorse 配置保存脚本
# 用法: ./save-env.sh KEY=VALUE [KEY2=VALUE2 ...]
# 示例: ./save-env.sh DASHSCOPE_API_KEY=sk-xxx OSS_BUCKET=my-bucket
# ============================================================

ENV_FILE="$HOME/.happy-horse.env"

if [[ $# -eq 0 ]]; then
  echo "用法: $(basename "$0") KEY=VALUE [KEY2=VALUE2 ...]"
  echo ""
  echo "支持的 KEY:"
  echo "  DASHSCOPE_API_KEY      百炼平台 API Key"
  echo "  OSS_ACCESS_KEY_ID      OSS Access Key ID"
  echo "  OSS_ACCESS_KEY_SECRET  OSS Access Key Secret"
  echo "  OSS_BUCKET             OSS Bucket 名称"
  echo "  OSS_REGION             OSS 地域，如 cn-hangzhou"
  exit 0
fi

# 创建文件（如不存在）
touch "$ENV_FILE"
chmod 600 "$ENV_FILE"  # 限制权限，保护密钥

for arg in "$@"; do
  KEY="${arg%%=*}"
  VALUE="${arg#*=}"

  if [[ -z "$KEY" || -z "$VALUE" ]]; then
    echo "⚠️  跳过无效参数: $arg"
    continue
  fi

  # 如果 key 已存在则更新，否则追加
  if grep -q "^${KEY}=" "$ENV_FILE" 2>/dev/null; then
    # macOS 和 Linux 兼容的 sed 替换
    if [[ "$(uname -s)" == "Darwin" ]]; then
      sed -i '' "s|^${KEY}=.*|${KEY}=${VALUE}|" "$ENV_FILE"
    else
      sed -i "s|^${KEY}=.*|${KEY}=${VALUE}|" "$ENV_FILE"
    fi
    echo "✅ 已更新: $KEY"
  else
    echo "${KEY}=${VALUE}" >> "$ENV_FILE"
    echo "✅ 已保存: $KEY"
  fi
done

echo ""
echo "配置已保存到: $ENV_FILE"
