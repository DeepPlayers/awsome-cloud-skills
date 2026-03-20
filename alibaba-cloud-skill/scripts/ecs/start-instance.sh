#!/bin/bash
# ECS实例启动脚本

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
启动ECS实例

用法:
  $0 --instance-id <instance-id> [options]

选项:
  --instance-id <id>      实例ID（必需）
  --region <region>       地域ID (默认: cn-hangzhou)
  --profile <profile>     使用指定凭证配置
  --wait                  等待实例启动完成
  --dryrun                模拟运行

示例:
  # 启动实例
  $0 --instance-id i-xxx

  # 启动并等待
  $0 --instance-id i-xxx --wait
EOF
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --instance-id) INSTANCE_ID="$2"; shift 2 ;;
            --region) REGION="$2"; shift 2 ;;
            --profile) PROFILE="$2"; shift 2 ;;
            --wait) WAIT=true; shift ;;
            --dryrun) DRYRUN=true; shift ;;
            -h|--help) usage; exit 0 ;;
            *) warn "未知参数: $1"; shift ;;
        esac
    done
    
    REGION="${REGION:-cn-hangzhou}"
}

# 验证参数
validate_args() {
    if [[ -z "$INSTANCE_ID" ]]; then
        error "必须指定实例ID (--instance-id)"
    fi
}

# 检查实例状态
check_status() {
    local expected_status="$1"
    local cmd="aliyun ecs DescribeInstanceStatus --RegionId '$REGION' --InstanceId.1 '$INSTANCE_ID'"
    [[ -n "$PROFILE" ]] && cmd+=" --profile '$PROFILE'"
    
    local status=$(eval "$cmd" | jq -r '.InstanceStatuses.InstanceStatus[0].Status')
    echo "$status"
}

# 启动实例
start_instance() {
    local cmd="aliyun ecs StartInstance --InstanceId '$INSTANCE_ID'"
    [[ -n "$PROFILE" ]] && cmd+=" --profile '$PROFILE'"
    [[ "$DRYRUN" == true ]] && cmd+=" --dryrun"
    
    info "启动实例: $INSTANCE_ID"
    
    # 先检查状态
    local current_status=$(check_status)
    if [[ "$current_status" == "Running" ]]; then
        warn "实例已在运行中"
        exit 0
    fi
    
    eval "$cmd"
    
    if [[ "$DRYRUN" != true ]] && [[ "$WAIT" == true ]]; then
        info "等待实例启动..."
        local max_wait=120
        local waited=0
        
        while [[ $waited -lt $max_wait ]]; do
            local status=$(check_status)
            if [[ "$status" == "Running" ]]; then
                info "实例启动成功"
                exit 0
            fi
            sleep 5
            waited=$((waited + 5))
            echo -n "."
        done
        
        echo ""
        warn "等待超时，请手动检查实例状态"
    fi
}

# 主函数
main() {
    parse_args "$@"
    validate_args
    start_instance
}

main "$@"
