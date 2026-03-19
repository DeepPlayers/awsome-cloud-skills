#!/bin/bash
# OSS Bucket操作脚本

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
OSS Bucket操作脚本

用法:
  $0 <command> [options]

命令:
  list                    列出所有Bucket
  create <bucket>         创建Bucket
  delete <bucket>         删除Bucket
  info <bucket>           查看Bucket信息
  acl <bucket> [acl]      设置/查看Bucket ACL
  ls <bucket>             列出Bucket内的对象

选项:
  --region <region>       地域ID
  --acl <acl>             访问权限 (private/public-read/public-read-write)
  --storage-class <class> 存储类型 (Standard/IA/Archive)
  --profile <profile>     使用指定凭证配置

示例:
  # 列出所有Bucket
  $0 list

  # 创建Bucket
  $0 create my-bucket --region cn-hangzhou

  # 设置Bucket为公共读
  $0 acl my-bucket public-read

  # 列出Bucket内对象
  $0 ls my-bucket
EOF
}

# 列出所有Bucket
list_buckets() {
    info "列出所有Bucket"
    aliyun ossutil ls
}

# 创建Bucket
create_bucket() {
    local bucket="$1"
    local region="${REGION:-cn-hangzhou}"
    local acl="${ACL:-private}"
    local storage_class="${STORAGE_CLASS:-Standard}"
    
    if [[ -z "$bucket" ]]; then
        error "必须指定Bucket名称"
    fi
    
    info "创建Bucket: $bucket"
    info "地域: $region"
    info "ACL: $acl"
    info "存储类型: $storage_class"
    
    aliyun ossutil mb oss://$bucket \
        --region $region \
        --acl $acl \
        --storage-class $storage_class
}

# 删除Bucket
delete_bucket() {
    local bucket="$1"
    
    if [[ -z "$bucket" ]]; then
        error "必须指定Bucket名称"
    fi
    
    read -p "确认删除Bucket '$bucket'? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "取消删除"
        exit 0
    fi
    
    info "删除Bucket: $bucket"
    aliyun ossutil rb oss://$bucket --force
}

# 查看Bucket信息
bucket_info() {
    local bucket="$1"
    
    if [[ -z "$bucket" ]]; then
        error "必须指定Bucket名称"
    fi
    
    info "Bucket信息: $bucket"
    aliyun ossutil stat oss://$bucket --human-readable
}

# 设置/查看Bucket ACL
bucket_acl() {
    local bucket="$1"
    local acl="$2"
    
    if [[ -z "$bucket" ]]; then
        error "必须指定Bucket名称"
    fi
    
    if [[ -n "$acl" ]]; then
        info "设置Bucket ACL: $bucket -> $acl"
        aliyun ossutil api put-bucket-acl --bucket $bucket --acl $acl
    else
        info "查看Bucket ACL: $bucket"
        aliyun ossutil api get-bucket-acl --bucket $bucket --output-format json
    fi
}

# 列出Bucket内对象
list_objects() {
    local bucket="$1"
    
    if [[ -z "$bucket" ]]; then
        error "必须指定Bucket名称"
    fi
    
    info "列出Bucket对象: $bucket"
    aliyun ossutil ls oss://$bucket/ --recursive
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --region) REGION="$2"; shift 2 ;;
            --acl) ACL="$2"; shift 2 ;;
            --storage-class) STORAGE_CLASS="$2"; shift 2 ;;
            --profile) PROFILE="$2"; shift 2 ;;
            -h|--help) usage; exit 0 ;;
            *) 
                if [[ -z "$COMMAND" ]]; then
                    COMMAND="$1"
                elif [[ -z "$BUCKET" ]]; then
                    BUCKET="$1"
                else
                    warn "未知参数: $1"
                fi
                shift
                ;;
        esac
    done
}

# 主函数
main() {
    parse_args "$@"
    
    case "$COMMAND" in
        list) list_buckets ;;
        create) create_bucket "$BUCKET" ;;
        delete) delete_bucket "$BUCKET" ;;
        info) bucket_info "$BUCKET" ;;
        acl) bucket_acl "$BUCKET" "$ACL" ;;
        ls) list_objects "$BUCKET" ;;
        *) usage ;;
    esac
}

main "$@"
