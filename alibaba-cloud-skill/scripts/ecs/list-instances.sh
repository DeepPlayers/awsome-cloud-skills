#!/bin/bash
# ECS实例列表查询脚本
# 支持多条件筛选和格式化输出

set -e

# 默认参数
REGION="${REGION:-cn-hangzhou}"
OUTPUT_FORMAT="${OUTPUT_FORMAT:-table}"

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
ECS实例列表查询

用法:
  $0 [options]

选项:
  --region <region>           地域ID (默认: cn-hangzhou)
  --status <status>           实例状态 (Running/Stopped)
  --instance-type <type>      实例规格
  --vpc-id <vpc-id>          VPC ID
  --vswitch-id <vswitch-id>  交换机ID
  --security-group <sg-id>   安全组ID
  --instance-name <name>     实例名称(模糊匹配)
  --output <format>          输出格式 (table/json/raw)
  --profile <profile>        使用指定凭证配置

示例:
  # 列出所有实例
  $0

  # 列出运行中的实例
  $0 --status Running

  # 列出指定VPC的实例
  $0 --vpc-id vpc-xxx

  # JSON格式输出
  $0 --output json
EOF
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --region) REGION="$2"; shift 2 ;;
            --status) STATUS="$2"; shift 2 ;;
            --instance-type) INSTANCE_TYPE="$2"; shift 2 ;;
            --vpc-id) VPC_ID="$2"; shift 2 ;;
            --vswitch-id) VSWITCH_ID="$2"; shift 2 ;;
            --security-group) SECURITY_GROUP="$2"; shift 2 ;;
            --instance-name) INSTANCE_NAME="$2"; shift 2 ;;
            --output) OUTPUT_FORMAT="$2"; shift 2 ;;
            --profile) PROFILE="$2"; shift 2 ;;
            -h|--help) usage; exit 0 ;;
            *) warn "未知参数: $1"; shift ;;
        esac
    done
}

# 构建查询命令
build_query_cmd() {
    local cmd="aliyun ecs DescribeInstances --RegionId '$REGION'"
    
    # 添加可选参数
    [[ -n "$STATUS" ]] && cmd+=" --InstanceStatus '$STATUS'"
    [[ -n "$INSTANCE_TYPE" ]] && cmd+=" --InstanceType '$INSTANCE_TYPE'"
    [[ -n "$VPC_ID" ]] && cmd+=" --VpcId '$VPC_ID'"
    [[ -n "$VSWITCH_ID" ]] && cmd+=" --VSwitchId '$VSWITCH_ID'"
    [[ -n "$SECURITY_GROUP" ]] && cmd+=" --SecurityGroupId '$SECURITY_GROUP'"
    [[ -n "$INSTANCE_NAME" ]] && cmd+=" --InstanceName '$INSTANCE_NAME'"
    [[ -n "$PROFILE" ]] && cmd+=" --profile '$PROFILE'"
    
    # 添加输出格式
    if [[ "$OUTPUT_FORMAT" == "table" ]]; then
        cmd+=" --output cols='InstanceId,InstanceName,Status,InstanceType,PrivateIpAddress,PublicIpAddress,CreatedTime' rows='Instances.Instance[]'"
    fi
    
    # 分页聚合
    cmd+=" --pager"
    
    echo "$cmd"
}

# 执行查询
execute_query() {
    local cmd=$(build_query_cmd)
    
    info "查询地域: $REGION"
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        eval "$cmd" | jq '.Instances.Instance[]'
    elif [[ "$OUTPUT_FORMAT" == "raw" ]]; then
        eval "$cmd"
    else
        eval "$cmd"
    fi
}

# 主函数
main() {
    parse_args "$@"
    execute_query
}

main "$@"
