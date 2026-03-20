#!/bin/bash
# OSS目录同步脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# 使用帮助
usage() {
    cat << EOF
OSS目录同步脚本

用法:
  $0 <source> <dest> [options]

参数:
  source                  源路径 (本地路径或 oss://bucket/path/)
  dest                    目标路径 (本地路径或 oss://bucket/path/)

选项:
  --delete                删除目标端存在但源端不存在的文件
  --bandwidth <speed>     限速 (如: 10M, 1G)
  --jobs <n>              并发任务数 (默认: 3)
  --include <pattern>     包含文件模式 (如: "*.jpg")
  --exclude <pattern>     排除文件模式 (如: "*.tmp")
  --dryrun                模拟运行，不实际同步

同步方向:
  - 本地 -> OSS: 本地路径在前
  - OSS -> 本地: OSS路径在前
  - OSS -> OSS: 两个都是OSS路径

示例:
  # 本地同步到OSS
  $0 ./local-dir/ oss://my-bucket/dir/

  # OSS同步到本地
  $0 oss://my-bucket/dir/ ./local-dir/

  # 同步并删除目标多余文件
  $0 ./local-dir/ oss://my-bucket/dir/ --delete

  # 只同步jpg文件
  $0 ./images/ oss://my-bucket/images/ --include "*.jpg"

  # 排除临时文件
  $0 ./data/ oss://my-bucket/data/ --exclude "*.tmp"
EOF
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --delete) DELETE=true; shift ;;
            --bandwidth) BANDWIDTH="$2"; shift 2 ;;
            --jobs) JOBS="$2"; shift 2 ;;
            --include) INCLUDE="$2"; shift 2 ;;
            --exclude) EXCLUDE="$2"; shift 2 ;;
            --dryrun) DRYRUN=true; shift ;;
            -h|--help) usage; exit 0 ;;
            oss://*)
                if [[ -z "$SOURCE" ]]; then
                    SOURCE="$1"
                else
                    warn "未知参数: $1"
                fi
                shift
                ;;
            -*)
                warn "未知参数: $1"
                shift
                ;;
            *)
                if [[ -z "$SOURCE" ]]; then
                    SOURCE="$1"
                elif [[ -z "$DEST" ]]; then
                    DEST="$1"
                else
                    warn "未知参数: $1"
                fi
                shift
                ;;
        esac
    done
}

# 验证参数
validate_args() {
    if [[ -z "$SOURCE" ]]; then
        error "必须指定源路径"
    fi
    if [[ -z "$DEST" ]]; then
        error "必须指定目标路径"
    fi
}

# 判断同步方向
detect_direction() {
    if [[ "$SOURCE" == oss://* ]] && [[ "$DEST" == oss://* ]]; then
        echo "oss-to-oss"
    elif [[ "$SOURCE" == oss://* ]]; then
        echo "oss-to-local"
    else
        echo "local-to-oss"
    fi
}

# 同步
sync() {
    local cmd="aliyun ossutil sync '$SOURCE' '$DEST'"
    
    # 添加选项
    [[ "$DELETE" == true ]] && cmd+=" --delete"
    [[ -n "$BANDWIDTH" ]] && cmd+=" --bandwidth-limit $BANDWIDTH"
    [[ -n "$JOBS" ]] && cmd+=" --jobs $JOBS"
    [[ -n "$INCLUDE" ]] && cmd+=" --include '$INCLUDE'"
    [[ -n "$EXCLUDE" ]] && cmd+=" --exclude '$EXCLUDE'"
    [[ "$DRYRUN" == true ]] && cmd+=" --dry-run"
    
    local direction=$(detect_direction)
    
    info "同步方向: $direction"
    info "源: $SOURCE"
    info "目标: $DEST"
    [[ "$DELETE" == true ]] && info "模式: 增量同步 + 删除"
    [[ -n "$BANDWIDTH" ]] && info "限速: $BANDWIDTH"
    
    eval "$cmd"
    
    if [[ "$DRYRUN" != true ]]; then
        info "同步完成"
    fi
}

# 主函数
main() {
    parse_args "$@"
    validate_args
    sync
}

main "$@"
