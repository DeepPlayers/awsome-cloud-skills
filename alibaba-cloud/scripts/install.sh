#!/bin/bash
# 阿里云CLI安装脚本
# 支持macOS、Linux、Windows(WSL/Git Bash)

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印函数
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 检测操作系统
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        CYGWIN*|MINGW*|MSYS*)    echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

# 检测架构
detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)   echo "amd64" ;;
        arm64|aarch64)  echo "arm64" ;;
        *)              echo "unknown" ;;
    esac
}

# 检查是否已安装
check_installed() {
    if command -v aliyun &> /dev/null; then
        local version=$(aliyun version 2>/dev/null || echo "unknown")
        info "阿里云CLI已安装，版本: $version"
        return 0
    fi
    return 1
}

# macOS安装
install_macos() {
    info "检测到macOS系统"
    
    # 优先使用Homebrew
    if command -v brew &> /dev/null; then
        info "使用Homebrew安装..."
        brew install aliyun-cli
    else
        info "Homebrew未安装，使用脚本安装..."
        /bin/bash -c "$(curl -fsSL https://aliyuncli.alicdn.com/install.sh)"
    fi
}

# Linux安装
install_linux() {
    info "检测到Linux系统"
    
    local arch=$(detect_arch)
    info "系统架构: $arch"
    
    # 使用官方安装脚本
    info "使用官方脚本安装..."
    /bin/bash -c "$(curl -fsSL https://aliyuncli.alicdn.com/install.sh)"
}

# Windows安装（通过Git Bash或WSL）
install_windows() {
    warn "检测到Windows环境（Git Bash/WSL）"
    info "建议使用以下方式安装："
    echo "  1. Chocolatey: choco install aliyun-cli"
    echo "  2. 手动下载: https://aliyuncli.alicdn.com/aliyun-cli-windows-latest-amd64.zip"
    echo "  3. 将解压后的aliyun.exe放入PATH目录"
}

# 验证安装
verify_installation() {
    info "验证安装..."
    
    if command -v aliyun &> /dev/null; then
        local version=$(aliyun version 2>/dev/null)
        info "安装成功！版本: $version"
        echo ""
        info "下一步：配置凭证"
        echo "  aliyun configure"
        echo ""
        info "或使用非交互式配置："
        echo "  aliyun configure set --profile default --mode AK \\"
        echo "    --access-key-id <AccessKeyId> \\"
        echo "    --access-key-secret <AccessKeySecret> \\"
        echo "    --region cn-hangzhou"
        return 0
    else
        error "安装验证失败，请检查PATH环境变量"
    fi
}

# 主函数
main() {
    echo "======================================"
    echo "    阿里云CLI安装脚本"
    echo "======================================"
    echo ""
    
    # 检查是否已安装
    if check_installed; then
        read -p "是否重新安装？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "跳过安装"
            exit 0
        fi
    fi
    
    # 检测系统
    local os=$(detect_os)
    info "操作系统: $os"
    
    # 根据系统安装
    case $os in
        macos)  install_macos ;;
        linux)  install_linux ;;
        windows) install_windows ;;
        *)      error "不支持的操作系统: $os" ;;
    esac
    
    # 验证安装
    verify_installation
}

# 执行主函数
main "$@"
