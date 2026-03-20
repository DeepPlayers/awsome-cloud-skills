#!/bin/bash
# ECS实例跨地域迁移脚本
# 基于自定义镜像实现跨地域迁移

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# 使用帮助
usage() {
    cat << EOF
ECS实例跨地域迁移

用法:
  $0 --instance-id <id> --dest-region <region> [options]

必需参数:
  --instance-id <id>          源实例ID
  --dest-region <region>      目标地域ID

可选参数:
  --source-region <region>    源地域ID (默认: cn-hangzhou)
  --security-group <sg-id>    目标地域安全组ID
  --vswitch-id <vswitch-id>   目标地域交换机ID
  --instance-type <type>      目标实例规格
  --profile <profile>         使用指定凭证配置
  --dryrun                    模拟运行

示例:
  # 迁移实例到北京地域
  $0 --instance-id i-xxx --dest-region cn-beijing \\
     --security-group sg-xxx --vswitch-id vsw-xxx

迁移流程:
  1. 为源实例创建自定义镜像
  2. 复制镜像到目标地域
  3. 使用镜像在目标地域创建实例
  4. 验证新实例

注意:
  - 迁移会产生快照费用
  - 实例元数据会变化（IP、MAC等）
  - 建议迁移前停止源实例
EOF
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --instance-id) INSTANCE_ID="$2"; shift 2 ;;
            --source-region) SOURCE_REGION="$2"; shift 2 ;;
            --dest-region) DEST_REGION="$2"; shift 2 ;;
            --security-group) SECURITY_GROUP="$2"; shift 2 ;;
            --vswitch-id) VSWITCH_ID="$2"; shift 2 ;;
            --instance-type) INSTANCE_TYPE="$2"; shift 2 ;;
            --profile) PROFILE="$2"; shift 2 ;;
            --dryrun) DRYRUN=true; shift ;;
            -h|--help) usage; exit 0 ;;
            *) warn "未知参数: $1"; shift ;;
        esac
    done
    
    SOURCE_REGION="${SOURCE_REGION:-cn-hangzhou}"
}

# 验证参数
validate_args() {
    if [[ -z "$INSTANCE_ID" ]]; then
        error "必须指定源实例ID (--instance-id)"
    fi
    if [[ -z "$DEST_REGION" ]]; then
        error "必须指定目标地域 (--dest-region)"
    fi
    if [[ "$DRYRUN" != true ]]; then
        if [[ -z "$SECURITY_GROUP" ]] || [[ -z "$VSWITCH_ID" ]]; then
            error "必须指定目标地域的安全组和交换机 (--security-group, --vswitch-id)"
        fi
    fi
}

# 等待镜像可用
wait_image_available() {
    local region="$1"
    local image_id="$2"
    local max_wait=1800
    local waited=0
    
    info "等待镜像 $image_id 创建完成..."
    
    while [[ $waited -lt $max_wait ]]; do
        local cmd="aliyun ecs DescribeImages --RegionId '$region' --ImageId '$image_id'"
        [[ -n "$PROFILE" ]] && cmd+=" --profile '$PROFILE'"
        
        local status=$(eval "$cmd" | jq -r '.Images.Image[0].Status')
        
        case "$status" in
            Available)
                return 0
                ;;
            CreateFailed)
                error "镜像创建失败"
                ;;
            Creating)
                echo -n "."
                ;;
        esac
        sleep 10
        waited=$((waited + 10))
    done
    
    error "等待镜像超时"
}

# 步骤1: 创建镜像
step1_create_image() {
    step "步骤1: 创建源实例镜像"
    
    local image_name="migrate-from-${INSTANCE_ID}-$(date +%Y%m%d%H%M%S)"
    
    local cmd="aliyun ecs CreateImage \
        --RegionId '$SOURCE_REGION' \
        --InstanceId '$INSTANCE_ID' \
        --ImageName '$image_name'"
    [[ -n "$PROFILE" ]] && cmd+=" --profile '$PROFILE'"
    
    local result=$(eval "$cmd")
    SOURCE_IMAGE_ID=$(echo "$result" | jq -r '.ImageId')
    
    info "镜像创建中: $SOURCE_IMAGE_ID"
    
    wait_image_available "$SOURCE_REGION" "$SOURCE_IMAGE_ID"
    info "源镜像创建完成: $SOURCE_IMAGE_ID"
}

# 步骤2: 复制镜像
step2_copy_image() {
    step "步骤2: 复制镜像到目标地域"
    
    local dest_image_name="copy-${SOURCE_IMAGE_ID}"
    
    local cmd="aliyun ecs CopyImage \
        --RegionId '$SOURCE_REGION' \
        --ImageId '$SOURCE_IMAGE_ID' \
        --DestinationRegionId '$DEST_REGION' \
        --DestinationImageName '$dest_image_name'"
    [[ -n "$PROFILE" ]] && cmd+=" --profile '$PROFILE'"
    
    local result=$(eval "$cmd")
    DEST_IMAGE_ID=$(echo "$result" | jq -r '.ImageId')
    
    info "镜像复制中: $DEST_IMAGE_ID"
    
    wait_image_available "$DEST_REGION" "$DEST_IMAGE_ID"
    info "目标镜像创建完成: $DEST_IMAGE_ID"
}

# 步骤3: 创建实例
step3_create_instance() {
    step "步骤3: 在目标地域创建实例"
    
    local instance_name="migrated-from-${INSTANCE_ID}"
    local instance_type="${INSTANCE_TYPE:-ecs.t5-lc1m2.small}"
    
    local cmd="aliyun ecs RunInstances \
        --RegionId '$DEST_REGION' \
        --ImageId '$DEST_IMAGE_ID' \
        --SecurityGroupId '$SECURITY_GROUP' \
        --VSwitchId '$VSWITCH_ID' \
        --InstanceType '$instance_type' \
        --InstanceName '$instance_name' \
        --PasswordInherit true"
    [[ -n "$PROFILE" ]] && cmd+=" --profile '$PROFILE'"
    
    local result=$(eval "$cmd")
    NEW_INSTANCE_ID=$(echo "$result" | jq -r '.InstanceIdSets.InstanceIdSet[0]')
    
    info "新实例创建中: $NEW_INSTANCE_ID"
}

# 步骤4: 验证实例
step4_verify_instance() {
    step "步骤4: 验证新实例"
    
    info "等待实例启动..."
    sleep 30
    
    local cmd="aliyun ecs DescribeInstances \
        --RegionId '$DEST_REGION' \
        --InstanceIds '[\"$NEW_INSTANCE_ID\"]'"
    [[ -n "$PROFILE" ]] && cmd+=" --profile '$PROFILE'"
    
    local result=$(eval "$cmd")
    local status=$(echo "$result" | jq -r '.Instances.Instance[0].Status')
    local private_ip=$(echo "$result" | jq -r '.Instances.Instance[0].NetworkInterfaces.NetworkInterface[0].PrivateIpSets.PrivateIpSet[0].PrivateIpAddress')
    
    info "新实例状态: $status"
    info "内网IP: $private_ip"
    
    echo ""
    echo "======================================"
    info "迁移完成！"
    echo "======================================"
    echo "源实例: $INSTANCE_ID ($SOURCE_REGION)"
    echo "新实例: $NEW_INSTANCE_ID ($DEST_REGION)"
    echo "源镜像: $SOURCE_IMAGE_ID"
    echo "目标镜像: $DEST_IMAGE_ID"
    echo ""
    warn "请检查新实例数据是否正确"
    warn "确认无误后可释放源实例和镜像"
}

# 主函数
main() {
    echo "======================================"
    echo "    ECS实例跨地域迁移"
    echo "======================================"
    echo ""
    
    parse_args "$@"
    validate_args
    
    if [[ "$DRYRUN" == true ]]; then
        warn "模拟运行模式，不执行实际操作"
        info "源实例: $INSTANCE_ID ($SOURCE_REGION)"
        info "目标地域: $DEST_REGION"
        exit 0
    fi
    
    step1_create_image
    step2_copy_image
    step3_create_instance
    step4_verify_instance
}

main "$@"
