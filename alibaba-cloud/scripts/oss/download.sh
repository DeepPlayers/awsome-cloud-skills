#!/bin/bash
# OSS文件下载脚本

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
OSS文件下载脚本

用法:
  $0 <source> <dest> [options]

参数:
  source                  OSS源路径 (格式: oss://bucket/path/)
  dest                    本地目标路径

选项:
  --recursive, -r         递归下载目录
  --force, -f             强制覆盖已存在的文件
  --bandwidth <speed>     限速 (如: 10M, 1G)
  --jobs <n>              并发任务数 (默认: 3)
  --dryrun                模拟运行，不实际下载

示例:
  # 下载单个文件
  $0 oss://my-bucket/file.txt ./file.txt

  # 下载目录
  $0 oss://my-bucket/dir/ ./local-dir/ -r

  # 限速下载
  $0 oss://my-bucket/large-file.zip ./ --bandwidth 10M

  # 下载所有jpg文件
  $0 oss://my-bucket/images/ ./images/ -r --include "*.jpg"
EOF
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --recursive|-r) RECURSIVE=true; shift ;;
            --force|-f) FORCE=true; shift ;;
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
                if [[ -z "$DEST" ]]; then
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
        error "必须指定源OSS路径 (格式: oss://bucket/path/)"
    fi
    if [[ -z "$DEST" ]]; then
        error "必须指定本地目标路径"
    fi
}

# 下载文件
download() {
    local cmd="aliyun ossutil cp '$SOURCE' '$DEST'"
    
    # 添加选项
    [[ "$RECURSIVE" == true ]] && cmd+=" --recursive"
    [[ "$FORCE" == true ]] && cmd+=" --force"
    [[ -n "$BANDWIDTH" ]] && cmd+=" --bandwidth-limit $BANDWIDTH"
    [[ -n "$JOBS" ]] && cmd+=" --jobs $JOBS"
    [[ -n "$INCLUDE" ]] && cmd+=" --include '$INCLUDE'"
    [[ -n "$EXCLUDE" ]] && cmd+=" --exclude '$EXCLUDE'"
    [[ "$DRYRUN" == true ]] && cmd+=" --dry-run"
    
    info "下载: $SOURCE -> $DEST"
    [[ -n "$BANDWIDTH" ]] && info "限速: $BANDWIDTH"
    
    eval "$cmd"
    
    if [[ "$DRYRUN" != true ]]; then
        info "下载完成"
    fi
}

# 主函数
main() {
    parse_args "$@"
    validate_args
    download
}

main "$@"
