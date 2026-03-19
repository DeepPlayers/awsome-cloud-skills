#!/bin/bash
# OSS文件上传脚本

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
OSS文件上传脚本

用法:
  $0 <source> <dest> [options]

参数:
  source                  本地文件或目录路径
  dest                    OSS目标路径 (格式: oss://bucket/path/)

选项:
  --recursive, -r         递归上传目录
  --force, -f             强制覆盖已存在的文件
  --acl <acl>             设置对象ACL (private/public-read)
  --storage-class <class> 存储类型 (Standard/IA/Archive)
  --bandwidth <speed>     限速 (如: 10M, 1G)
  --jobs <n>              并发任务数 (默认: 3)
  --dryrun                模拟运行，不实际上传

示例:
  # 上传单个文件
  $0 ./file.txt oss://my-bucket/path/file.txt

  # 上传目录
  $0 ./my-dir/ oss://my-bucket/dir/ -r

  # 限速上传
  $0 ./large-file.zip oss://my-bucket/ --bandwidth 10M

  # 设置存储类型为低频
  $0 ./archive.tar oss://my-bucket/ --storage-class IA
EOF
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --recursive|-r) RECURSIVE=true; shift ;;
            --force|-f) FORCE=true; shift ;;
            --acl) ACL="$2"; shift 2 ;;
            --storage-class) STORAGE_CLASS="$2"; shift 2 ;;
            --bandwidth) BANDWIDTH="$2"; shift 2 ;;
            --jobs) JOBS="$2"; shift 2 ;;
            --dryrun) DRYRUN=true; shift ;;
            -h|--help) usage; exit 0 ;;
            oss://*)
                if [[ -z "$DEST" ]]; then
                    DEST="$1"
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
        error "必须指定源文件路径"
    fi
    if [[ -z "$DEST" ]]; then
        error "必须指定目标OSS路径 (格式: oss://bucket/path/)"
    fi
    if [[ ! -e "$SOURCE" ]]; then
        error "源文件不存在: $SOURCE"
    fi
}

# 上传文件
upload() {
    local cmd="aliyun ossutil cp '$SOURCE' '$DEST'"
    
    # 添加选项
    [[ "$RECURSIVE" == true ]] && cmd+=" --recursive"
    [[ "$FORCE" == true ]] && cmd+=" --force"
    [[ -n "$ACL" ]] && cmd+=" --acl $ACL"
    [[ -n "$STORAGE_CLASS" ]] && cmd+=" --storage-class $STORAGE_CLASS"
    [[ -n "$BANDWIDTH" ]] && cmd+=" --bandwidth-limit $BANDWIDTH"
    [[ -n "$JOBS" ]] && cmd+=" --jobs $JOBS"
    [[ "$DRYRUN" == true ]] && cmd+=" --dry-run"
    
    info "上传: $SOURCE -> $DEST"
    
    if [[ -d "$SOURCE" ]]; then
        info "模式: 目录上传"
    else
        info "模式: 文件上传"
    fi
    
    [[ -n "$BANDWIDTH" ]] && info "限速: $BANDWIDTH"
    [[ -n "$STORAGE_CLASS" ]] && info "存储类型: $STORAGE_CLASS"
    
    eval "$cmd"
    
    if [[ "$DRYRUN" != true ]]; then
        info "上传完成"
    fi
}

# 主函数
main() {
    parse_args "$@"
    validate_args
    upload
}

main "$@"
