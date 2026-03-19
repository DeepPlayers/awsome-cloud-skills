#!/bin/bash
# 错误检查工具

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 使用帮助
usage() {
    cat << EOF
CLI错误检查工具

用法:
  $0 <command> [options]

命令:
  check <json>           检查API返回是否有错误
  diagnose <error>       诊断错误信息
  common                 显示常见错误及解决方案

选项:
  --verbose              显示详细信息

示例:
  # 检查API返回
  aliyun ecs DescribeInstances | $0 check

  # 诊断错误
  $0 diagnose "InvalidAccessKeyId.NotFound"

  # 显示常见错误
  $0 common
EOF
}

# 常见错误定义
COMMON_ERRORS=(
    "InvalidAccessKeyId.NotFound:AccessKey ID不存在，请检查配置的AccessKey ID是否正确"
    "SignatureDoesNotMatch:签名不匹配，请检查AccessKey Secret是否正确"
    "InvalidRegionId.NotFound:地域不存在，请检查RegionId是否正确"
    "InsufficientBalance:账户余额不足，请充值后重试"
    "QuotaExceeded:配额超限，请申请提高配额"
    "InvalidInstanceId.NotFound:实例不存在，请检查InstanceId是否正确"
    "IncorrectInstanceStatus:实例状态不正确，请检查实例当前状态"
    "InvalidParameter:参数错误，请检查参数格式和取值"
    "ServiceUnavailable:服务不可用，请稍后重试"
    "Throttling:请求被限流，请降低请求频率"
    "UnauthorizedOperation:未授权操作，请检查RAM权限"
)

# 检查API返回
check_response() {
    local input="$1"
    local verbose="$2"
    
    if [[ -z "$input" ]]; then
        input=$(cat)
    fi
    
    local code=$(echo "$input" | jq -r '.Code // empty')
    local message=$(echo "$input" | jq -r '.Message // empty')
    local request_id=$(echo "$input" | jq -r '.RequestId // empty')
    
    if [[ -n "$code" ]]; then
        error "API调用失败"
        echo ""
        echo "错误码: $code"
        echo "错误信息: $message"
        echo "请求ID: $request_id"
        echo ""
        
        # 尝试诊断
        diagnose_error "$code"
        return 1
    else
        info "API调用成功"
        if [[ "$verbose" == "true" ]]; then
            echo "请求ID: $request_id"
        fi
        return 0
    fi
}

# 诊断错误
diagnose_error() {
    local error_code="$1"
    
    echo "诊断结果:"
    echo ""
    
    local found=false
    for err in "${COMMON_ERRORS[@]}"; do
        if [[ "$err" == "$error_code"* ]]; then
            echo "  $err"
            found=true
            break
        fi
    done
    
    if [[ "$found" == false ]]; then
        echo "  未找到此错误的已知解决方案"
        echo ""
        echo "建议排查步骤:"
        echo "  1. 检查网络连接"
        echo "  2. 验证凭证配置"
        echo "  3. 确认参数格式"
        echo "  4. 查看API文档"
        echo "  5. 使用 --dryrun 模拟调用"
    fi
}

# 显示常见错误
show_common_errors() {
    echo "常见错误及解决方案:"
    echo ""
    for err in "${COMMON_ERRORS[@]}"; do
        echo "  $err"
    done
    echo ""
    echo "通用排查步骤:"
    echo "  1. 检查网络状态"
    echo "  2. 验证身份凭证"
    echo "  3. 确认地域和接入点"
    echo "  4. 检查参数格式"
    echo "  5. 确认RAM权限"
    echo "  6. 更新CLI版本"
}

# 主函数
main() {
    local command="$1"
    shift || true
    
    local verbose="false"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --verbose) verbose="true"; shift ;;
            -h|--help) usage; exit 0 ;;
            *) shift ;;
        esac
    done
    
    case "$command" in
        check)
            local input="$1"
            if [[ -z "$input" ]] || [[ "$input" == "-" ]]; then
                input=$(cat)
            fi
            check_response "$input" "$verbose"
            ;;
        diagnose)
            local error_code="$1"
            if [[ -z "$error_code" ]]; then
                error "请指定错误码"
            fi
            diagnose_error "$error_code"
            ;;
        common)
            show_common_errors
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            # 默认从标准输入读取并检查
            check_response "$(cat)" "$verbose"
            ;;
    esac
}

main "$@"
