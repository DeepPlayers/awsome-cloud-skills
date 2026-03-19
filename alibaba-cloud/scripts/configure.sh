#!/bin/bash
# 阿里云CLI凭证配置脚本
# 支持多种凭证类型配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 默认值
DEFAULT_REGION="cn-hangzhou"
DEFAULT_OUTPUT="json"
DEFAULT_LANGUAGE="zh"

# 打印函数
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# 显示当前配置
show_current_config() {
    info "当前凭证配置列表："
    aliyun configure list 2>/dev/null || warn "暂无配置"
    echo ""
    
    info "当前使用的配置："
    aliyun configure get profile 2>/dev/null || warn "未设置默认配置"
}

# AK类型凭证配置
configure_ak() {
    local profile="${1:-default}"
    local access_key_id="$2"
    local access_key_secret="$3"
    local region="${4:-$DEFAULT_REGION}"
    
    if [[ -z "$access_key_id" ]] || [[ -z "$access_key_secret" ]]; then
        error "请提供AccessKeyId和AccessKeySecret"
    fi
    
    info "配置AK类型凭证 (profile: $profile)..."
    
    aliyun configure set \
        --profile "$profile" \
        --mode AK \
        --access-key-id "$access_key_id" \
        --access-key-secret "$access_key_secret" \
        --region "$region" \
        --language "$DEFAULT_LANGUAGE"
    
    info "配置完成"
}

# StsToken类型凭证配置
configure_sts() {
    local profile="${1:-sts-profile}"
    local access_key_id="$2"
    local access_key_secret="$3"
    local sts_token="$4"
    local region="${5:-$DEFAULT_REGION}"
    
    if [[ -z "$access_key_id" ]] || [[ -z "$access_key_secret" ]] || [[ -z "$sts_token" ]]; then
        error "请提供AccessKeyId、AccessKeySecret和StsToken"
    fi
    
    info "配置StsToken类型凭证 (profile: $profile)..."
    
    aliyun configure set \
        --profile "$profile" \
        --mode StsToken \
        --access-key-id "$access_key_id" \
        --access-key-secret "$access_key_secret" \
        --sts-token "$sts_token" \
        --region "$region"
    
    info "配置完成"
}

# RamRoleArn类型凭证配置
configure_ram_role() {
    local profile="${1:-ram-role-profile}"
    local access_key_id="$2"
    local access_key_secret="$3"
    local ram_role_arn="$4"
    local role_session_name="${5:-session}"
    local region="${6:-$DEFAULT_REGION}"
    local sts_region="${7:-$DEFAULT_REGION}"
    
    if [[ -z "$access_key_id" ]] || [[ -z "$access_key_secret" ]] || [[ -z "$ram_role_arn" ]]; then
        error "请提供AccessKeyId、AccessKeySecret和RamRoleArn"
    fi
    
    info "配置RamRoleArn类型凭证 (profile: $profile)..."
    
    aliyun configure set \
        --profile "$profile" \
        --mode RamRoleArn \
        --access-key-id "$access_key_id" \
        --access-key-secret "$access_key_secret" \
        --ram-role-arn "$ram_role_arn" \
        --role-session-name "$role_session_name" \
        --sts-region "$sts_region" \
        --region "$region"
    
    info "配置完成"
}

# EcsRamRole类型凭证配置（ECS实例内使用）
configure_ecs_role() {
    local profile="${1:-ecs-profile}"
    local ram_role_name="$2"
    local region="${3:-$DEFAULT_REGION}"
    
    info "配置EcsRamRole类型凭证 (profile: $profile)..."
    
    aliyun configure set \
        --profile "$profile" \
        --mode EcsRamRole \
        --ram-role-name "$ram_role_name" \
        --region "$region"
    
    info "配置完成"
}

# 切换配置
switch_profile() {
    local profile="$1"
    
    if [[ -z "$profile" ]]; then
        error "请指定要切换的profile名称"
    fi
    
    info "切换到配置: $profile"
    aliyun configure switch --profile "$profile"
    info "切换完成"
}

# 删除配置
delete_profile() {
    local profile="$1"
    
    if [[ -z "$profile" ]]; then
        error "请指定要删除的profile名称"
    fi
    
    read -p "确认删除配置 '$profile'? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        aliyun configure delete --profile "$profile"
        info "配置已删除: $profile"
    else
        info "取消删除"
    fi
}

# 验证配置
verify_config() {
    local profile="${1:-default}"
    
    info "验证配置 '$profile'..."
    
    # 尝试调用一个简单的API
    if aliyun ecs DescribeRegions --profile "$profile" &>/dev/null; then
        info "配置验证成功"
        return 0
    else
        error "配置验证失败，请检查凭证是否正确"
    fi
}

# 使用帮助
usage() {
    cat << EOF
阿里云CLI凭证配置脚本

用法:
  $0 <command> [options]

命令:
  show                        显示当前配置
  ak <profile> <ak_id> <ak_secret> [region]
                              配置AK类型凭证
  sts <profile> <ak_id> <ak_secret> <token> [region]
                              配置StsToken类型凭证
  ram-role <profile> <ak_id> <ak_secret> <role_arn> [session_name] [region]
                              配置RamRoleArn类型凭证
  ecs-role <profile> <role_name> [region]
                              配置EcsRamRole类型凭证
  switch <profile>            切换到指定配置
  delete <profile>            删除指定配置
  verify [profile]            验证配置是否有效
  interactive                 交互式配置

示例:
  # 配置AK凭证
  $0 ak default LTAIxxx secret123 cn-hangzhou

  # 切换配置
  $0 switch prod-profile

  # 验证配置
  $0 verify default

凭证类型说明:
  AK          - AccessKey凭证（最常用）
  StsToken    - 临时安全令牌
  RamRoleArn  - RAM角色扮演
  EcsRamRole  - ECS实例RAM角色（免密钥）
EOF
}

# 交互式配置
interactive_configure() {
    info "开始交互式配置..."
    aliyun configure
}

# 主函数
main() {
    local command="$1"
    shift || true
    
    case "$command" in
        show)
            show_current_config
            ;;
        ak)
            configure_ak "$@"
            ;;
        sts)
            configure_sts "$@"
            ;;
        ram-role)
            configure_ram_role "$@"
            ;;
        ecs-role)
            configure_ecs_role "$@"
            ;;
        switch)
            switch_profile "$@"
            ;;
        delete)
            delete_profile "$@"
            ;;
        verify)
            verify_config "$@"
            ;;
        interactive)
            interactive_configure
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            if [[ -z "$command" ]]; then
                show_current_config
            else
                error "未知命令: $command\n使用 '$0 --help' 查看帮助"
            fi
            ;;
    esac
}

main "$@"

