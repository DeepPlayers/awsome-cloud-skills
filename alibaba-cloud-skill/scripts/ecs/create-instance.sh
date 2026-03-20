#!/bin/bash
# ECS实例创建脚本

set -e

# 默认参数
REGION="${REGION:-cn-hangzhou}"
INSTANCE_TYPE="${INSTANCE_TYPE:-ecs.t5-lc1m2.small}"
IMAGE_ID="${IMAGE_ID:-aliyun_3_x64_20G_alibase_20240828.vhd}"
SECURITY_GROUP="${SECURITY_GROUP:-}"
VSWITCH_ID="${VSWITCH_ID:-}"
INSTANCE_NAME="${INSTANCE_NAME:-cli-created-instance}"
SYSTEM_DISK_SIZE="${SYSTEM_DISK_SIZE:-40}"
SYSTEM_DISK_CATEGORY="${SYSTEM_DISK_CATEGORY:-cloud_essd}"
INSTANCE_CHARGE_TYPE="${INSTANCE_CHARGE_TYPE:-PostPaid}"
INTERNET_MAX_BANDWIDTH_OUT="${INTERNET_MAX_BANDWIDTH_OUT:-0}"

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
创建ECS实例

用法:
  $0 [options]

必需参数:
  --security-group <sg-id>    安全组ID
  --vswitch-id <vswitch-id>   交换机ID

可选参数:
  --region <region>                    地域ID (默认: cn-hangzhou)
  --instance-type <type>              实例规格 (默认: ecs.t5-lc1m2.small)
  --image-id <image-id>               镜像ID (默认: 最新CentOS)
  --instance-name <name>              实例名称
  --system-disk-size <size>           系统盘大小GB (默认: 40)
  --system-disk-category <category>   系统盘类型 (默认: cloud_essd)
  --instance-charge-type <type>       付费类型 (PostPaid/PrePaid)
  --internet-max-bandwidth-out <mbps> 公网带宽Mbps (默认: 0)
  --password <password>               实例密码
  --key-pair <key-pair-name>          密钥对名称
  --profile <profile>                 使用指定凭证配置
  --dryrun                            模拟运行，不实际创建

示例:
  # 创建按量付费实例
  $0 --security-group sg-xxx --vswitch-id vsw-xxx

  # 创建带公网IP的实例
  $0 --security-group sg-xxx --vswitch-id vsw-xxx --internet-max-bandwidth-out 10

  # 使用自定义镜像
  $0 --security-group sg-xxx --vswitch-id vsw-xxx --image-id m-xxx
EOF
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --region) REGION="$2"; shift 2 ;;
            --instance-type) INSTANCE_TYPE="$2"; shift 2 ;;
            --image-id) IMAGE_ID="$2"; shift 2 ;;
            --security-group) SECURITY_GROUP="$2"; shift 2 ;;
            --vswitch-id) VSWITCH_ID="$2"; shift 2 ;;
            --instance-name) INSTANCE_NAME="$2"; shift 2 ;;
            --system-disk-size) SYSTEM_DISK_SIZE="$2"; shift 2 ;;
            --system-disk-category) SYSTEM_DISK_CATEGORY="$2"; shift 2 ;;
            --instance-charge-type) INSTANCE_CHARGE_TYPE="$2"; shift 2 ;;
            --internet-max-bandwidth-out) INTERNET_MAX_BANDWIDTH_OUT="$2"; shift 2 ;;
            --password) PASSWORD="$2"; shift 2 ;;
            --key-pair) KEY_PAIR="$2"; shift 2 ;;
            --profile) PROFILE="$2"; shift 2 ;;
            --dryrun) DRYRUN=true; shift ;;
            -h|--help) usage; exit 0 ;;
            *) warn "未知参数: $1"; shift ;;
        esac
    done
}

# 验证必需参数
validate_args() {
    if [[ -z "$SECURITY_GROUP" ]]; then
        error "必须指定安全组ID (--security-group)"
    fi
    if [[ -z "$VSWITCH_ID" ]]; then
        error "必须指定交换机ID (--vswitch-id)"
    fi
}

# 创建实例
create_instance() {
    local cmd="aliyun ecs RunInstances \
        --RegionId '$REGION' \
        --InstanceType '$INSTANCE_TYPE' \
        --ImageId '$IMAGE_ID' \
        --SecurityGroupId '$SECURITY_GROUP' \
        --VSwitchId '$VSWITCH_ID' \
        --InstanceName '$INSTANCE_NAME' \
        --SystemDisk.Size $SYSTEM_DISK_SIZE \
        --SystemDisk.Category '$SYSTEM_DISK_CATEGORY' \
        --InstanceChargeType '$INSTANCE_CHARGE_TYPE' \
        --InternetMaxBandwidthOut $INTERNET_MAX_BANDWIDTH_OUT"
    
    # 可选参数
    [[ -n "$PASSWORD" ]] && cmd+=" --Password '$PASSWORD'"
    [[ -n "$KEY_PAIR" ]] && cmd+=" --KeyPairName '$KEY_PAIR'"
    [[ -n "$PROFILE" ]] && cmd+=" --profile '$PROFILE'"
    
    # 模拟运行
    [[ "$DRYRUN" == true ]] && cmd+=" --dryrun"
    
    info "创建实例中..."
    info "地域: $REGION"
    info "规格: $INSTANCE_TYPE"
    info "镜像: $IMAGE_ID"
    
    local result=$(eval "$cmd")
    
    echo "$result"
    
    if [[ "$DRYRUN" != true ]]; then
        local instance_id=$(echo "$result" | jq -r '.InstanceIdSets.InstanceIdSet[0]' 2>/dev/null)
        if [[ -n "$instance_id" ]] && [[ "$instance_id" != "null" ]]; then
            info "实例创建成功: $instance_id"
        fi
    fi
}

# 主函数
main() {
    parse_args "$@"
    validate_args
    create_instance
}

main "$@"
