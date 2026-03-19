#!/bin/bash
# 结果轮询工具

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
结果轮询工具

用法:
  $0 --command <cmd> --expr <expr> --to <value> [options]

必需参数:
  --command <cmd>      要执行的CLI命令
  --expr <expr>        要检查的JSON路径表达式
  --to <value>         期望的值

可选参数:
  --interval <sec>     轮询间隔秒数 (默认: 5)
  --timeout <sec>      超时秒数 (默认: 300)
  --profile <profile>  使用指定凭证配置

示例:
  # 等待镜像创建完成
  $0 --command "aliyun ecs DescribeImages --ImageId m-xxx" \\
     --expr ".Images.Image[0].Status" --to "Available"

  # 等待实例启动
  $0 --command "aliyun ecs DescribeInstanceStatus --InstanceId i-xxx" \\
     --expr ".InstanceStatuses.InstanceStatus[0].Status" --to "Running"

  # 等待镜像复制完成
  $0 --command "aliyun ecs DescribeImages --RegionId cn-beijing --ImageId m-xxx" \\
     --expr ".Images.Image[0].Status" --to "Available" \\
     --timeout 1800
EOF
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --command) COMMAND="$2"; shift 2 ;;
            --expr) EXPR="$2"; shift 2 ;;
            --to) EXPECTED="$2"; shift 2 ;;
            --interval) INTERVAL="$2"; shift 2 ;;
            --timeout) TIMEOUT="$2"; shift 2 ;;
            --profile) PROFILE="$2"; shift 2 ;;
            -h|--help) usage; exit 0 ;;
            *) warn "未知参数: $1"; shift ;;
        esac
    done
    
    INTERVAL="${INTERVAL:-5}"
    TIMEOUT="${TIMEOUT:-300}"
}

# 验证参数
validate_args() {
    if [[ -z "$COMMAND" ]]; then
        error "必须指定要执行的命令 (--command)"
    fi
    if [[ -z "$EXPR" ]]; then
        error "必须指定JSON路径表达式 (--expr)"
    fi
    if [[ -z "$EXPECTED" ]]; then
        error "必须指定期望值 (--to)"
    fi
}

# 轮询
poll() {
    local waited=0
    
    info "开始轮询..."
    info "命令: $COMMAND"
    info "检查表达式: $EXPR"
    info "期望值: $EXPECTED"
    info "超时: ${TIMEOUT}秒"
    echo ""
    
    while [[ $waited -lt $TIMEOUT ]]; do
        local result=$(eval "$COMMAND" 2>/dev/null)
        local current=$(echo "$result" | jq -r "$EXPR" 2>/dev/null || echo "null")
        
        echo -ne "\r当前值: $current (已等待 ${waited}秒)    "
        
        if [[ "$current" == "$EXPECTED" ]]; then
            echo ""
            info "条件满足！"
            return 0
        fi
        
        # 检查失败状态
        case "$current" in
            CreateFailed|Error|Failed)
                echo ""
                error "状态变为失败: $current"
                ;;
        esac
        
        sleep $INTERVAL
        waited=$((waited + INTERVAL))
    done
    
    echo ""
    error "轮询超时，最终状态: $current"
}

# 主函数
main() {
    parse_args "$@"
    validate_args
    poll
}

main "$@"
