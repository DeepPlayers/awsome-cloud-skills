#!/bin/bash
# ECS镜像创建脚本

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
创建ECS自定义镜像

用法:
  $0 --instance-id <instance-id> [options]

选项:
  --instance-id <id>      实例ID（必需）
  --image-name <name>     镜像名称
  --image-desc <desc>     镜像描述
  --region <region>       地域ID (默认: cn-hangzhou)
  --profile <profile>     使用指定凭证配置
  --wait                  等待镜像创建完成
  --dryrun                模拟运行

示例:
  # 从实例创建镜像
  $0 --instance-id i-xxx --image-name my-image

  # 创建镜像并等待完成
  $0 --instance-id i-xxx --image-name my-image --wait

注意:
  - 建议在创建镜像前停止实例，以保证数据完整性
  - 创建镜像会产生快照费用
EOF
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --instance-id) INSTANCE_ID="$2"; shift 2 ;;
            --image-name) IMAGE_NAME="$2"; shift 2 ;;
            --image-desc) IMAGE_DESC="$2"; shift 2 ;;
            --region) REGION="$2"; shift 2 ;;
            --profile) PROFILE="$2"; shift 2 ;;
            --wait) WAIT=true; shift ;;
            --dryrun) DRYRUN=true; shift ;;
            -h|--help) usage; exit 0 ;;
            *) warn "未知参数: $1"; shift ;;
        esac
    done
    
    REGION="${REGION:-cn-hangzhou}"
    IMAGE_NAME="${IMAGE_NAME:-image-from-${INSTANCE_ID}}"
}

# 验证参数
validate_args() {
    if [[ -z "$INSTANCE_ID" ]]; then
        error "必须指定实例ID (--instance-id)"
    fi
}

# 检查镜像状态
check_image_status() {
    local image_id="$1"
    local cmd="aliyun ecs DescribeImages --RegionId '$REGION' --ImageId '$image_id'"
    [[ -n "$PROFILE" ]] && cmd+=" --profile '$PROFILE'"
    
    local status=$(eval "$cmd" | jq -r '.Images.Image[0].Status')
    echo "$status"
}

# 创建镜像
create_image() {
    local cmd="aliyun ecs CreateImage \
        --RegionId '$REGION' \
        --InstanceId '$INSTANCE_ID' \
        --ImageName '$IMAGE_NAME'"
    
    [[ -n "$IMAGE_DESC" ]] && cmd+=" --Description '$IMAGE_DESC'"
    [[ -n "$PROFILE" ]] && cmd+=" --profile '$PROFILE'"
    [[ "$DRYRUN" == true ]] && cmd+=" --dryrun"
    
    info "创建镜像: $IMAGE_NAME"
    info "源实例: $INSTANCE_ID"
    info "地域: $REGION"
    
    local result=$(eval "$cmd")
    echo "$result"
    
    if [[ "$DRYRUN" != true ]]; then
        local image_id=$(echo "$result" | jq -r '.ImageId')
        if [[ -n "$image_id" ]] && [[ "$image_id" != "null" ]]; then
            info "镜像ID: $image_id"
            
            if [[ "$WAIT" == true ]]; then
                info "等待镜像创建完成..."
                local max_wait=1800  # 30分钟
                local waited=0
                
                while [[ $waited -lt $max_wait ]]; do
                    local status=$(check_image_status "$image_id")
                    case "$status" in
                        Available)
                            info "镜像创建成功: $image_id"
                            exit 0
                            ;;
                        CreateFailed)
                            error "镜像创建失败"
                            ;;
                        Creating)
                            echo -n "."
                            ;;
                        *)
                            warn "未知状态: $status"
                            ;;
                    esac
                    sleep 10
                    waited=$((waited + 10))
                done
                
                echo ""
                warn "等待超时，请手动检查镜像状态"
            fi
        fi
    fi
}

# 主函数
main() {
    parse_args "$@"
    validate_args
    create_image
}

main "$@"
