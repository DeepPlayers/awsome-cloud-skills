#!/usr/bin/env bash
# ============================================================
# HappyHorse 统一视频生成脚本
# 用法: ./happyhorse.sh <mode> [options]
# mode: i2v | t2v | r2v | video-edit | batch
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$HOME/.happy-horse.env"
OSS_CACHE_FILE="$HOME/.happy-horse-oss-cache.json"
API_BASE="https://dashscope.aliyuncs.com/api/v1/services/aigc/video-generation/video-synthesis"
TASK_API="https://dashscope.aliyuncs.com/api/v1/tasks"
POLL_INTERVAL=5

# ---------- 加载环境变量 ----------
[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"

# ---------- 参数默认值 ----------
RESOLUTION="1080P"
DURATION=15
RATIO="16:9"
WATERMARK=false
SEED=""
PROMPT=""
IMAGE=""
VIDEO=""
REFS=()
OUTPUT_FILE=""
OUTPUT_DIR="."

# batch 专用参数
BATCH_CONFIG=""
BATCH_MAX_CONCURRENCY=10

MODE="${1:-}"
[[ -n "$MODE" ]] && shift || true

# ---------- 帮助信息 ----------
usage() {
  cat <<EOF
用法: $(basename "$0") <mode> [options]

模式:
  i2v        图生视频 (Image-to-Video)
  t2v        文生视频 (Text-to-Video)
  r2v        参考生视频 (Reference-to-Video)
  video-edit 视频编辑 (Video-Edit)
  batch      批量并发生成 (Batch Generation)

通用选项:
  -p, --prompt <text|file>       prompt 文本或 .txt/.md 文件路径
  -r, --resolution <720P|1080P>  分辨率，默认 1080P
  -d, --duration <5|10|15>        时长（秒），默认 15
  --ratio <16:9|9:16|1:1>        比例，默认 16:9 (t2v/r2v 有效)
  -o, --output <file>            输出文件路径
  --output-dir <dir>             输出目录，默认当前目录
  -s, --seed <int>               随机种子
  -w, --watermark                添加水印，默认不加
  --clear-cache                 清理过期的 OSS 上传缓存
  -h, --help                     显示帮助

i2v 专用:
  -i, --image <url|path>         首帧图片（URL 或本地路径，自动上传到 OSS）

r2v 专用:
  --ref <url|path>               参考图（可多次指定，最多 9 张，支持本地路径）

video-edit 专用:
  -v, --video <url|path>         待编辑视频（URL 或本地路径，自动上传到 OSS）
  --ref <url|path>               参考图（可多次指定，支持本地路径）

batch 专用:
  --config <file>                JSON 配置文件路径（必填）
  --max-concurrency <int>        最大并发数，默认 10

环境变量（存储在 ~/.happy-horse.env）:
  DASHSCOPE_API_KEY              百炼平台 API Key（必填）
  OSS_ACCESS_KEY_ID              OSS AK（上传本地文件时必填）
  OSS_ACCESS_KEY_SECRET          OSS SK（上传本地文件时必填）
  OSS_BUCKET                     OSS Bucket（上传本地文件时必填）
  OSS_REGION                     OSS Region，如 cn-hangzhou（上传本地文件时必填）

示例:
  # 图生视频（URL 图片）
  ./happyhorse.sh i2v -i "https://example.com/img.png" -p "让画面动起来" -d 10

  # 图生视频（本地图片，自动上传 OSS）
  ./happyhorse.sh i2v -i ./my_image.png -p "让画面动起来"

  # 文生视频
  ./happyhorse.sh t2v -p "一只猫在草地上奔跑" -r 1080P -d 5

  # 参考生视频（多参考图）
  ./happyhorse.sh r2v -p "图1 身着旗袍的女士镜头由近及远..." --ref girl.jpg --ref fan.jpg

  # 视频编辑
  ./happyhorse.sh video-edit -v input.mp4 -p "让角色穿上条纹毛衣" --ref sweater.png

  # 批量并发生成（JSON 配置文件）
  ./happyhorse.sh batch --config ./tasks.json

  # 批量并发生成（自定义最大并发数）
  ./happyhorse.sh batch --config ./tasks.json --max-concurrency 5
EOF
  exit 0
}

# ---------- 校验核心依赖 ----------
check_env() {
  if [[ -z "${DASHSCOPE_API_KEY:-}" ]]; then
    echo "❌ 缺少 DASHSCOPE_API_KEY"
    echo "   请运行: bash $SCRIPT_DIR/check-setup.sh"
    exit 1
  fi
}

check_oss_env() {
  local missing=()
  [[ -z "${OSS_ACCESS_KEY_ID:-}" ]] && missing+=("OSS_ACCESS_KEY_ID")
  [[ -z "${OSS_ACCESS_KEY_SECRET:-}" ]] && missing+=("OSS_ACCESS_KEY_SECRET")
  [[ -z "${OSS_BUCKET:-}" ]] && missing+=("OSS_BUCKET")
  [[ -z "${OSS_REGION:-}" ]] && missing+=("OSS_REGION")
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "❌ OSS 配置不完整，缺少: ${missing[*]}"
    echo "   请运行: bash $SCRIPT_DIR/check-setup.sh"
    exit 1
  fi
}

# ============================================================
# OSS 上传缓存：避免重复上传同一文件（预签名 URL 24h 内有效）
# 缓存文件：~/.happy-horse-oss-cache.json
# 校验依据：绝对路径 + 文件 mtime + 文件大小 + 过期时间
# ============================================================

# 读取整个缓存文件 -> JSON 字符串
read_oss_cache() {
  if [[ -f "$OSS_CACHE_FILE" ]]; then
    cat "$OSS_CACHE_FILE"
  else
    echo "{}"
  fi
}

# 检查缓存中是否存在有效条目，命中返回 presigned_url，否则返回空
check_oss_cache() {
  local abs_path="$1"
  local cache_data
  cache_data=$(read_oss_cache)

  python3 - "$abs_path" "$cache_data" <<'PY'
import sys, json, os, time

abs_path = sys.argv[1]
cache = json.loads(sys.argv[2])

entry = cache.get(abs_path)
if not entry:
    sys.exit(1)

# 文件必须仍然存在且未修改
try:
    stat = os.stat(abs_path)
except OSError:
    sys.exit(1)

if stat.st_mtime != entry.get('file_mtime', 0):
    sys.exit(1)
if stat.st_size != entry.get('file_size', 0):
    sys.exit(1)

# 检查过期：预签名 URL 有效期 24h，预留 10 分钟缓冲
now_ts = time.time()
expires_ts = entry.get('expires_at', 0)
if now_ts >= expires_ts - 600:  # 10 分钟缓冲
    sys.exit(1)

# 校验 OSS bucket/region 一致
if entry.get('bucket') != os.environ.get('OSS_BUCKET', ''):
    sys.exit(1)
if entry.get('region') != os.environ.get('OSS_REGION', ''):
    sys.exit(1)

# 命中！输出预签名 URL
print(entry['presigned_url'])
PY
  # 返回值：成功=0+URL输出，失败=1
}

# 保存上传记录到缓存
save_oss_cache() {
  local abs_path="$1"
  local oss_path="$2"
  local presigned_url="$3"

  local cache_data
  cache_data=$(read_oss_cache)

  python3 - "$abs_path" "$oss_path" "$presigned_url" "$cache_data" <<'PY'
import sys, json, os, time

abs_path = sys.argv[1]
oss_path = sys.argv[2]
presigned_url = sys.argv[3]
cache = json.loads(sys.argv[4])

try:
    stat = os.stat(abs_path)
except OSError:
    sys.exit(1)

now_ts = time.time()
# 预签名 URL 24h 有效，留 5 分钟缓冲
expires_at = now_ts + (24 * 3600) - 300

cache[abs_path] = {
    "oss_path": oss_path,
    "presigned_url": presigned_url,
    "uploaded_at": now_ts,
    "expires_at": expires_at,
    "file_mtime": stat.st_mtime,
    "file_size": stat.st_size,
    "bucket": os.environ.get('OSS_BUCKET', ''),
    "region": os.environ.get('OSS_REGION', '')
}

cache_file = os.path.expanduser('~/.happy-horse-oss-cache.json')
with open(cache_file, 'w') as f:
    json.dump(cache, f, ensure_ascii=False, indent=2)
os.chmod(cache_file, 0o600)
PY
}

# 清理过期或无效的缓存条目
clear_expired_cache() {
  local cache_data
  cache_data=$(read_oss_cache)

  python3 - "$cache_data" <<'PY'
import sys, json, os, time

cache = json.loads(sys.argv[1])
now_ts = time.time()
cleaned = {}
removed = 0

for path, entry in cache.items():
    # 检查过期
    if now_ts >= entry.get('expires_at', 0):
        removed += 1
        continue
    # 检查文件是否存在且未修改
    try:
        stat = os.stat(path)
        if stat.st_mtime != entry.get('file_mtime', 0):
            removed += 1
            continue
        if stat.st_size != entry.get('file_size', 0):
            removed += 1
            continue
    except OSError:
        removed += 1
        continue
    # 检查 bucket/region 一致
    if entry.get('bucket') != os.environ.get('OSS_BUCKET', ''):
        removed += 1
        continue
    if entry.get('region') != os.environ.get('OSS_REGION', ''):
        removed += 1
        continue
    cleaned[path] = entry

cache_file = os.path.expanduser('~/.happy-horse-oss-cache.json')
with open(cache_file, 'w') as f:
    json.dump(cleaned, f, ensure_ascii=False, indent=2)
os.chmod(cache_file, 0o600)

total = len(cache)
kept = len(cleaned)
print(f"缓存清理完成: {removed} 条移除, {kept} 条保留 (原 {total} 条)")
PY
}

# ---------- OSS 上传（含缓存检查），返回预签名 URL ----------
oss_upload() {
  local local_file="$1"
  local file_label="${2:-文件}"

  check_oss_env

  # Step 0: 检查缓存
  local abs_path
  abs_path="$(cd "$(dirname "$local_file")" 2>/dev/null && pwd)/$(basename "$local_file")"
  local cached_url
  cached_url=$(check_oss_cache "$abs_path" 2>/dev/null || true)
  if [[ -n "$cached_url" ]]; then
    echo "♻️  缓存命中，复用预签名 URL: ${file_label}" >&2
    echo "$cached_url"
    return 0
  fi

  # 缓存未命中 -> 执行实际上传
  if ! command -v ossutil &>/dev/null; then
    echo "❌ ossutil 未安装，请运行: bash $SCRIPT_DIR/check-setup.sh" >&2
    exit 1
  fi

  local filename
  filename=$(basename "$local_file")
  local ext="${filename##*.}"
  local base="${filename%.*}"
  local oss_key="happyhorse/${base}-$(date +%Y%m%d%H%M%S).${ext}"
  local oss_path="oss://${OSS_BUCKET}/${oss_key}"

  echo "📤 上传 ${file_label} 到 OSS: $oss_path" >&2
  if ! ossutil cp "$local_file" "$oss_path"     -i "$OSS_ACCESS_KEY_ID"     -k "$OSS_ACCESS_KEY_SECRET"     --region "$OSS_REGION"     -q >&2 2>&1; then
    echo "❌ OSS 上传失败" >&2
    exit 1
  fi

  echo "🔗 生成预签名 URL（有效期 24h）..." >&2
  local presign_out
  presign_out=$(ossutil presign "$oss_path"     --expires-duration 24h     -i "$OSS_ACCESS_KEY_ID"     -k "$OSS_ACCESS_KEY_SECRET"     --region "$OSS_REGION" 2>/dev/null)

  local url
  url=$(echo "$presign_out" | grep -oE 'https?://[^[:space:]]+' | head -1)

  if [[ -z "$url" ]]; then
    echo "❌ 预签名 URL 生成失败，输出: $presign_out" >&2
    exit 1
  fi

  # 保存到缓存
  save_oss_cache "$abs_path" "$oss_path" "$url"

  echo "$url"
}

# ---------- 解析 URL：本地文件则上传，否则直接返回 ----------
resolve_url() {
  local input="$1"
  local label="${2:-文件}"
  if [[ -f "$input" ]]; then
    oss_upload "$input" "$label"
  else
    echo "$input"
  fi
}

# ---------- 读取 prompt ----------
read_prompt() {
  local p="$1"
  if [[ -f "$p" ]]; then
    echo "📄 从文件读取 prompt：$p" >&2
    cat "$p"
  else
    echo "$p"
  fi
}

# ---------- 用 python3 构建 JSON body ----------
build_json() {
  python3 - "$@"
}

# ---------- 提交任务（仅提交，返回 task_id）----------
submit_task() {
  local body="$1"
  local label="${2:-}"

  local submit_resp
  submit_resp=$(curl -s -X POST "$API_BASE" \
    -H "X-DashScope-Async: enable" \
    -H "Authorization: Bearer $DASHSCOPE_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$body")

  local task_id
  task_id=$(echo "$submit_resp" | python3 -c \
    "import sys,json; d=json.load(sys.stdin); print(d.get('output',{}).get('task_id',''))" 2>/dev/null)

  if [[ -z "$task_id" ]]; then
    echo "❌ ${label}任务提交失败：$submit_resp" >&2
    return 1
  fi
  echo "$task_id"
}

# ---------- 轮询单个任务，返回 video_url 或报错 ----------
poll_one_task() {
  local task_id="$1"
  local label="${2:-}"
  local MAX_POLLS=120
  local POLL_COUNT=0

  while true; do
    sleep "$POLL_INTERVAL"
    ((POLL_COUNT++))
    if [[ $POLL_COUNT -ge $MAX_POLLS ]]; then
      echo "❌ ${label}轮询超时（${MAX_POLLS}次），task_id: $task_id" >&2
      return 1
    fi
    local poll_resp
    poll_resp=$(curl -s -X GET "$TASK_API/$task_id" \
      -H "Authorization: Bearer $DASHSCOPE_API_KEY")

    local status
    status=$(echo "$poll_resp" | python3 -c \
      "import sys,json; d=json.load(sys.stdin); print(d.get('output',{}).get('task_status',''))" 2>/dev/null)

    if [[ "$status" == "SUCCEEDED" ]]; then
      local video_url
      video_url=$(echo "$poll_resp" | python3 -c \
        "import sys,json; d=json.load(sys.stdin); print(d.get('output',{}).get('video_url',''))" 2>/dev/null)
      if [[ -z "$video_url" ]]; then
        echo "❌ ${label}任务成功但未获取到视频 URL" >&2
        return 1
      fi
      echo "$video_url"
      return 0
    elif [[ "$status" == "FAILED" ]]; then
      local err_msg
      err_msg=$(echo "$poll_resp" | python3 -c \
        "import sys,json; d=json.load(sys.stdin); print(d.get('output',{}).get('message','未知错误'))" 2>/dev/null)
      echo "❌ ${label}任务失败：$err_msg" >&2
      return 1
    fi
    if [[ $((POLL_COUNT % 5)) -eq 0 ]]; then
      echo "   ${label}状态: $status (轮询 $POLL_COUNT/$MAX_POLLS)" >&2
    fi
  done
}

# ---------- 提交任务并轮询结果（单任务模式使用）----------
submit_and_poll() {
  local body="$1"
  local label="${2:-}"

  echo "🚀 ${label}提交任务..." >&2
  local task_id
  task_id=$(submit_task "$body" "$label")
  if [[ -z "$task_id" ]]; then
    exit 1
  fi
  echo "✅ ${label}任务已提交 task_id: $task_id" >&2

  echo "⏳ ${label}等待生成..." >&2
  local video_url
  video_url=$(poll_one_task "$task_id" "$label")
  if [[ -z "$video_url" ]]; then
    exit 1
  fi
  echo "$video_url"
}

# ============================================================
# 批量并发轮询：同时轮询多个 task_id，逐个下载完成的视频
# task_map_file 每行格式：task_id|idx|output_file|label
# ============================================================
batch_poll_all() {
  local task_map_file="$1"
  local total="$2"
  local completed=0
  local failed=0
  local MAX_POLLS=120
  local POLL_COUNT=0

  echo ""
  echo "========================================"
  echo "  开始并发轮询 $total 个任务..."
  echo "========================================"

  local state_dir
  state_dir=$(dirname "$task_map_file")/batch_state
  mkdir -p "$state_dir"
  cp "$task_map_file" "${state_dir}/pending.txt"
  > "${state_dir}/results.txt"

  while true; do
    sleep "$POLL_INTERVAL"
    ((POLL_COUNT++))

    if [[ $POLL_COUNT -ge $MAX_POLLS ]]; then
      local remaining
      remaining=$(wc -l < "${state_dir}/pending.txt" 2>/dev/null | tr -d ' ')
      echo "❌ 轮询超时，仍有 $remaining 个任务未完成" >&2
      break
    fi

    local new_pending="${state_dir}/pending_new.txt"
    > "$new_pending"

    while IFS='|' read -r task_id idx output_file label; do
      [[ -z "$task_id" ]] && continue

      local poll_resp
      poll_resp=$(curl -s -X GET "$TASK_API/$task_id" \
        -H "Authorization: Bearer $DASHSCOPE_API_KEY")

      local status
      status=$(echo "$poll_resp" | python3 -c \
        "import sys,json; d=json.load(sys.stdin); print(d.get('output',{}).get('task_status',''))" 2>/dev/null)

      if [[ "$status" == "SUCCEEDED" ]]; then
        local video_url
        video_url=$(echo "$poll_resp" | python3 -c \
          "import sys,json; d=json.load(sys.stdin); print(d.get('output',{}).get('video_url',''))" 2>/dev/null)

        if [[ -n "$video_url" ]]; then
          local out_path="${OUTPUT_DIR}/${output_file}"
          mkdir -p "$(dirname "$out_path")" 2>/dev/null || true
          echo "⬇️  [$idx] 下载: $out_path" >&2
          curl -s -L "$video_url" -o "$out_path"
          ((completed++))
          echo "✅ [$idx] 完成！$out_path" >&2
          echo "$idx|SUCCESS|$out_path" >> "${state_dir}/results.txt"
        else
          ((failed++))
          echo "❌ [$idx] 成功但无视频 URL" >&2
          echo "$idx|FAILED|no_video_url" >> "${state_dir}/results.txt"
        fi
      elif [[ "$status" == "FAILED" ]]; then
        local err_msg
        err_msg=$(echo "$poll_resp" | python3 -c \
          "import sys,json; d=json.load(sys.stdin); print(d.get('output',{}).get('message','未知错误'))" 2>/dev/null)
        ((failed++))
        echo "❌ [$idx] 失败: $err_msg" >&2
        echo "$idx|FAILED|$err_msg" >> "${state_dir}/results.txt"
      else
        echo "$task_id|$idx|$output_file|$label" >> "$new_pending"
      fi
    done < "${state_dir}/pending.txt"

    mv "$new_pending" "${state_dir}/pending.txt"

    local remaining
    remaining=$(wc -l < "${state_dir}/pending.txt" 2>/dev/null | tr -d ' ')

    # 每 3 次轮询打印一次进度（减少噪音）
    if [[ $((POLL_COUNT % 3)) -eq 0 || $remaining -eq 0 ]]; then
      echo "📊 进度: ✅$completed ❌$failed ⏳$remaining / 总计$total" >&2
    fi

    if [[ $remaining -eq 0 ]]; then
      break
    fi
  done

  echo ""
  echo "========================================"
  echo "  批量任务完成: ✅$completed ❌$failed / 总计$total"
  if [[ $completed -gt 0 ]]; then
    echo "  输出目录: $OUTPUT_DIR"
    ls -la "$OUTPUT_DIR"/*.mp4 2>/dev/null | head -20 || true
  fi
  echo "========================================"
}

# ---------- 下载视频 ----------
download_video() {
  local url="$1"
  mkdir -p "$OUTPUT_DIR"
  if [[ -z "$OUTPUT_FILE" ]]; then
    local ts
    ts=$(date +"%Y%m%d_%H%M%S")
    OUTPUT_FILE="${OUTPUT_DIR}/output-${MODE}-${ts}.mp4"
  fi
  echo "⬇️  下载视频到: $OUTPUT_FILE" >&2
  curl -s -L "$url" -o "$OUTPUT_FILE"
  echo "✅ 完成！视频已保存：$OUTPUT_FILE"
}

# ---------- 解析通用参数 ----------
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--prompt)     PROMPT="$2"; shift 2 ;;
      -r|--resolution) RESOLUTION="$2"; shift 2 ;;
      -d|--duration)   DURATION="$2"; shift 2 ;;
      --ratio)         RATIO="$2"; shift 2 ;;
      -o|--output)     OUTPUT_FILE="$2"; shift 2 ;;
      --output-dir)    OUTPUT_DIR="$2"; shift 2 ;;
      -i|--image)      IMAGE="$2"; shift 2 ;;
      -v|--video)      VIDEO="$2"; shift 2 ;;
      --ref)           REFS+=("$2"); shift 2 ;;
      -w|--watermark)  WATERMARK=true; shift ;;
      -s|--seed)       SEED="$2"; shift 2 ;;
      -h|--help)       usage ;;
      *) echo "❌ 未知参数: $1"; usage ;;
    esac
  done
}

# ---------- 解析 batch 专用参数 ----------
parse_batch_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --config)           BATCH_CONFIG="$2"; shift 2 ;;
      --max-concurrency)  BATCH_MAX_CONCURRENCY="$2"; shift 2 ;;
      --output-dir)       OUTPUT_DIR="$2"; shift 2 ;;
      -h|--help)          usage ;;
      *) echo "❌ 未知 batch 参数: $1"; usage ;;
    esac
  done
}

# ============================================================
# Source guard: 当被 source 时仅加载函数定义，跳过主逻辑
# ============================================================
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  return 0 2>/dev/null || exit 0
fi

# 处理独立于 mode 的全局命令（此时所有函数已定义）
if [[ "${MODE:-}" == "--clear-cache" ]]; then
  clear_expired_cache
  exit 0
fi

# ============================================================
# 主逻辑
# ============================================================
case "$MODE" in

  # ----------------------------------------------------------
  # i2v：图生视频
  # ----------------------------------------------------------
  i2v)
    parse_args "$@"
    check_env
    [[ -z "$IMAGE" ]] && { echo "❌ 必须通过 -i 指定图片 URL 或本地路径"; usage; }

    PROMPT_TEXT=""
    [[ -n "$PROMPT" ]] && PROMPT_TEXT=$(read_prompt "$PROMPT")

    IMAGE_URL=$(resolve_url "$IMAGE" "图片")

    echo "🎬 图生视频 | 图片: $(echo "$IMAGE_URL" | cut -c1-60)..." >&2
    echo "   分辨率: $RESOLUTION | 时长: ${DURATION}s | 水印: $WATERMARK" >&2
    [[ -n "$PROMPT_TEXT" ]] && echo "   Prompt: $(echo "$PROMPT_TEXT" | head -c 100)..." >&2

    BODY=$(build_json "$PROMPT_TEXT" "$IMAGE_URL" "$RESOLUTION" "$DURATION" "$SEED" "$WATERMARK" <<'PY'
import sys, json
prompt, img_url, res, dur, seed, wm = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]
body = {
    "model": "happyhorse-1.0-i2v",
    "input": {"media": [{"type": "first_frame", "url": img_url}]},
    "parameters": {"resolution": res, "duration": int(dur), "watermark": wm == "true"}
}
if prompt: body["input"]["prompt"] = prompt
if seed: body["parameters"]["seed"] = int(seed)
print(json.dumps(body, ensure_ascii=False))
PY
)

    VIDEO_URL=$(submit_and_poll "$BODY" "[i2v]")
    download_video "$VIDEO_URL"
    ;;

  # ----------------------------------------------------------
  # t2v：文生视频
  # ----------------------------------------------------------
  t2v)
    parse_args "$@"
    check_env
    [[ -z "$PROMPT" ]] && { echo "❌ 必须通过 -p 指定 prompt"; usage; }

    PROMPT_TEXT=$(read_prompt "$PROMPT")

    echo "🎬 文生视频 | 分辨率: $RESOLUTION | 比例: $RATIO | 时长: ${DURATION}s" >&2
    echo "   Prompt: $(echo "$PROMPT_TEXT" | head -c 100)..." >&2

    BODY=$(build_json "$PROMPT_TEXT" "$RESOLUTION" "$RATIO" "$DURATION" "$SEED" "$WATERMARK" <<'PY'
import sys, json
prompt, res, ratio, dur, seed, wm = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]
body = {
    "model": "happyhorse-1.0-t2v",
    "input": {"prompt": prompt},
    "parameters": {"resolution": res, "ratio": ratio, "duration": int(dur), "watermark": wm == "true"}
}
if seed: body["parameters"]["seed"] = int(seed)
print(json.dumps(body, ensure_ascii=False))
PY
)

    VIDEO_URL=$(submit_and_poll "$BODY" "[t2v]")
    download_video "$VIDEO_URL"
    ;;

  # ----------------------------------------------------------
  # r2v：参考生视频
  # ----------------------------------------------------------
  r2v)
    parse_args "$@"
    check_env
    [[ -z "$PROMPT" ]] && { echo "❌ 必须通过 -p 指定 prompt"; usage; }
    [[ ${#REFS[@]} -eq 0 ]] && { echo "❌ 必须通过 --ref 指定至少一张参考图"; usage; }
    [[ ${#REFS[@]} -gt 9 ]] && { echo "❌ 参考图最多 9 张，当前 ${#REFS[@]} 张"; exit 1; }

    PROMPT_TEXT=$(read_prompt "$PROMPT")

    # 上传所有本地参考图
    REF_URLS=()
    for ref in "${REFS[@]}"; do
      REF_URLS+=("$(resolve_url "$ref" "参考图")")
    done

    echo "🎬 参考生视频 | 参考图: ${#REF_URLS[@]} 张 | 分辨率: $RESOLUTION | 时长: ${DURATION}s" >&2
    echo "   Prompt: $(echo "$PROMPT_TEXT" | head -c 100)..." >&2

    BODY=$(python3 - "$PROMPT_TEXT" "$RESOLUTION" "$RATIO" "$DURATION" "$SEED" "$WATERMARK" "${REF_URLS[@]}" <<'PY'
import sys, json
args = sys.argv[1:]
prompt, res, ratio, dur, seed, wm = args[0], args[1], args[2], args[3], args[4], args[5]
ref_urls = args[6:]
media = [{"type": "reference_image", "url": u} for u in ref_urls]
body = {
    "model": "happyhorse-1.0-r2v",
    "input": {"prompt": prompt, "media": media},
    "parameters": {"resolution": res, "ratio": ratio, "duration": int(dur), "watermark": wm == "true"}
}
if seed: body["parameters"]["seed"] = int(seed)
print(json.dumps(body, ensure_ascii=False))
PY
)

    VIDEO_URL=$(submit_and_poll "$BODY" "[r2v]")
    download_video "$VIDEO_URL"
    ;;

  # ----------------------------------------------------------
  # video-edit：视频编辑
  # ----------------------------------------------------------
  video-edit)
    parse_args "$@"
    check_env
    [[ -z "$VIDEO" ]] && { echo "❌ 必须通过 -v 指定视频 URL 或本地路径"; usage; }
    [[ -z "$PROMPT" ]] && { echo "❌ 必须通过 -p 指定编辑指令"; usage; }

    PROMPT_TEXT=$(read_prompt "$PROMPT")
    VIDEO_URL_IN=$(resolve_url "$VIDEO" "视频")

    # 上传所有本地参考图
    REF_URLS=()
    for ref in "${REFS[@]}"; do
      REF_URLS+=("$(resolve_url "$ref" "参考图")")
    done

    echo "🎬 视频编辑 | 视频: $(echo "$VIDEO_URL_IN" | cut -c1-60)..." >&2
    echo "   分辨率: $RESOLUTION | 参考图: ${#REF_URLS[@]} 张" >&2
    echo "   指令: $(echo "$PROMPT_TEXT" | head -c 100)..." >&2

    BODY=$(python3 - "$PROMPT_TEXT" "$VIDEO_URL_IN" "$RESOLUTION" "${REF_URLS[@]:-}" <<'PY'
import sys, json
args = sys.argv[1:]
prompt, video_url, res = args[0], args[1], args[2]
ref_urls = [u for u in args[3:] if u]
media = [{"type": "video", "url": video_url}]
for u in ref_urls:
    media.append({"type": "reference_image", "url": u})
body = {
    "model": "happyhorse-1.0-video-edit",
    "input": {"prompt": prompt, "media": media},
    "parameters": {"resolution": res}
}
print(json.dumps(body, ensure_ascii=False))
PY
)

    VIDEO_URL=$(submit_and_poll "$BODY" "[video-edit]")
    download_video "$VIDEO_URL"
    ;;

  # ----------------------------------------------------------
  # batch：批量并发生成
  # 由 python3 驱动：读 JSON → 上传文件 → 构建 body → 输出
  # bash 侧负责：提交 API → 并发轮询 → 下载
  # ----------------------------------------------------------
  batch)
    parse_batch_args "$@"
    check_env
    [[ -z "$BATCH_CONFIG" ]] && { echo "❌ 必须通过 --config 指定 JSON 配置文件"; usage; }
    [[ ! -f "$BATCH_CONFIG" ]] && { echo "❌ 配置文件不存在: $BATCH_CONFIG"; exit 1; }

    TASK_TMP=$(mktemp -d)
    TASK_FILE="${TASK_TMP}/tasks.txt"
    TASK_MAP="${TASK_TMP}/task_map.txt"
    trap "rm -rf $TASK_TMP" EXIT

    echo "📋 读取配置: $BATCH_CONFIG"

    # Phase 1: Python 解析 JSON + 上传本地文件 + 构建 API body
    # 输出格式: idx|mode|body_json|output_file
    python3 - "$BATCH_CONFIG" "$OUTPUT_DIR" "$SCRIPT_DIR" > "$TASK_FILE" 2>"${TASK_TMP}/py_stderr.txt" <<'PYEOF'
import json, sys, os, subprocess, base64

config_file = sys.argv[1]
output_dir = sys.argv[2]
script_dir = sys.argv[3]

with open(config_file, 'r') as f:
    config = json.load(f)

max_concurrency = config.get('max_concurrency', 10)
global_output_dir = config.get('output_dir', output_dir)
tasks = config.get('tasks', [])

if not tasks:
    print("ERROR: tasks 数组为空", file=sys.stderr)
    sys.exit(1)

# 通知 bash 总任务数
print(f"MAX_CONCURRENCY={max_concurrency}", file=sys.stderr)
print(f"TOTAL={len(tasks)}", file=sys.stderr)

SCRIPT_PATH = os.path.join(script_dir, 'happyhorse.sh')

def upload_file(path, label, idx):
    """本地文件 → OSS 上传 → 返回预签名 URL"""
    if not path or not os.path.isfile(path):
        return path
    result = subprocess.run(
        ['bash', '-c',
         f'set -a; source "$HOME/.happy-horse.env" 2>/dev/null; set +a; '
         f'SCRIPT_DIR="{os.path.dirname(SCRIPT_PATH)}"; '
         f'source "{SCRIPT_PATH}" 2>/dev/null; '
         f'oss_upload "{path}" "{label}[{idx}]"'],
        capture_output=True, text=True, timeout=120,
        env={**os.environ}
    )
    if result.returncode == 0 and result.stdout.strip():
        return result.stdout.strip().split('\n')[-1]  # 最后一行是 URL
    print(f"ERROR:OSS_UPLOAD_FAILED:{idx}:{label}:{result.stderr[-200:]}", file=sys.stderr)
    sys.exit(1)

for i, t in enumerate(tasks):
    mode = t.get('mode', '').strip()
    if mode not in ('i2v', 't2v', 'r2v', 'video-edit'):
        print(f"ERROR: 任务[{i}] mode 无效: {mode}", file=sys.stderr)
        sys.exit(1)

    # 读取 prompt
    prompt = t.get('prompt', '')
    if prompt and os.path.isfile(prompt):
        with open(prompt, 'r') as pf:
            prompt = pf.read().strip()

    resolution = t.get('resolution', '720P')
    duration = t.get('duration', 15)
    ratio = t.get('ratio', '16:9')
    seed = str(t.get('seed', ''))
    watermark = str(t.get('watermark', False)).lower()
    output_file = t.get('output', f'output-batch-{i:03d}.mp4')

    body = {}

    try:
        if mode == 'i2v':
            image = t.get('image', '')
            image_url = upload_file(image, '图片', i)
            body = {
                "model": "happyhorse-1.0-i2v",
                "input": {"media": [{"type": "first_frame", "url": image_url}]},
                "parameters": {"resolution": resolution, "duration": int(duration), "watermark": watermark == "true"}
            }
            if prompt: body["input"]["prompt"] = prompt
            if seed: body["parameters"]["seed"] = int(seed)

        elif mode == 't2v':
            body = {
                "model": "happyhorse-1.0-t2v",
                "input": {"prompt": prompt},
                "parameters": {"resolution": resolution, "ratio": ratio, "duration": int(duration), "watermark": watermark == "true"}
            }
            if seed: body["parameters"]["seed"] = int(seed)

        elif mode == 'r2v':
            refs = t.get('refs', [])
            if isinstance(refs, str): refs = [refs]
            ref_urls = [upload_file(r, '参考图', i) for r in refs]
            body = {
                "model": "happyhorse-1.0-r2v",
                "input": {"prompt": prompt, "media": [{"type": "reference_image", "url": u} for u in ref_urls]},
                "parameters": {"resolution": resolution, "ratio": ratio, "duration": int(duration), "watermark": watermark == "true"}
            }
            if seed: body["parameters"]["seed"] = int(seed)

        elif mode == 'video-edit':
            video_path = t.get('video', '')
            video_url = upload_file(video_path, '视频', i)
            refs = t.get('refs', [])
            if isinstance(refs, str): refs = [refs]
            ref_urls = [upload_file(r, '参考图', i) for r in refs]
            media = [{"type": "video", "url": video_url}]
            for u in ref_urls:
                media.append({"type": "reference_image", "url": u})
            body = {
                "model": "happyhorse-1.0-video-edit",
                "input": {"prompt": prompt, "media": media},
                "parameters": {"resolution": resolution}
            }

    except Exception as e:
        print(f"ERROR: 任务[{i}] 预处理失败: {e}", file=sys.stderr)
        sys.exit(1)

    body_b64 = base64.b64encode(json.dumps(body, ensure_ascii=False).encode()).decode()
    print(f"{i}|{mode}|{body_b64}|{output_file}")
PYEOF

    # 检查 python 错误
    if grep -q "^ERROR:" "${TASK_TMP}/py_stderr.txt" 2>/dev/null; then
      echo "❌ 配置文件处理失败："
      grep "^ERROR:" "${TASK_TMP}/py_stderr.txt" | head -5 >&2
      exit 1
    fi

    # 读取 python 输出的元信息
    TOTAL=$(wc -l < "$TASK_FILE" | tr -d ' ')
    # 从 stderr 读取 max_concurrency（JSON 中的配置优先）
    JSON_MAX_CONC=$(grep "^MAX_CONCURRENCY=" "${TASK_TMP}/py_stderr.txt" 2>/dev/null | cut -d= -f2)
    if [[ -n "$JSON_MAX_CONC" ]]; then
      BATCH_MAX_CONCURRENCY="$JSON_MAX_CONC"
    fi

    echo "📋 共 $TOTAL 个任务待处理"
    echo "   最大并发: $BATCH_MAX_CONCURRENCY"
    echo ""

    # Phase 2: 提交所有任务
    echo "========================================"
    echo "  提交任务到百炼 API"
    echo "========================================"

    SUBMITTED=0
    > "$TASK_MAP"

    while IFS='|' read -r idx mode body_b64 output_file; do
      BODY=$(echo "$body_b64" | python3 -c "import sys,base64; print(base64.b64decode(sys.stdin.read().strip()).decode())")

      echo "🚀 提交任务 [$idx] ${mode}..." >&2
      TASK_ID=$(submit_task "$BODY" "[$idx]")
      if [[ -n "$TASK_ID" ]]; then
        echo "✅ 任务 [$idx] 已提交 task_id: $TASK_ID" >&2
        echo "${TASK_ID}|${idx}|${output_file}|[${idx}]" >> "$TASK_MAP"
        ((SUBMITTED++))
      else
        echo "❌ 任务 [$idx] 提交失败，跳过" >&2
      fi
    done < "$TASK_FILE"

    echo ""
    echo "📊 已提交: $SUBMITTED / $TOTAL 个任务"

    if [[ $SUBMITTED -eq 0 ]]; then
      echo "❌ 没有任务成功提交，退出"
      exit 1
    fi

    # Phase 3: 并发轮询并下载
    batch_poll_all "$TASK_MAP" "$SUBMITTED"
    ;;

  # ----------------------------------------------------------
  # 帮助 / 错误
  # ----------------------------------------------------------
  -h|--help|help)
    usage
    ;;

  "")
    echo "❌ 请指定模式 (i2v/t2v/r2v/video-edit/batch)"
    usage
    ;;

  *)
    echo "❌ 未知模式: $MODE"
    usage
    ;;
esac
