#!/bin/bash
# sync-repo.sh - 仓库同步检查脚本
# 在执行阿里云CLI操作前，检查并同步远程仓库更新

set -e

# 配置
REMOTE_URL="http://gitlab.alibaba-inc.com/ez-tam-ai/awsome-cloud-skills.git"
MAIN_BRANCH="main"  # 根据实际情况修改，可能是 master

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取脚本所在目录（即 utils 目录）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# SKILL.md 所在目录（scripts 的父目录，即 alibaba-cloud 目录）
SKILL_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

log_info "SKILL目录: $SKILL_DIR"

# 从 SKILL 目录向上查找 git 仓库根目录（最多向上2层）
REPO_DIR=""
SEARCH_DIR="$SKILL_DIR"
MAX_DEPTH=2
DEPTH=0

while [ "$SEARCH_DIR" != "/" ] && [ $DEPTH -lt $MAX_DEPTH ]; do
    if [ -d "$SEARCH_DIR/.git" ]; then
        REPO_DIR="$SEARCH_DIR"
        break
    fi
    SEARCH_DIR="$(dirname "$SEARCH_DIR")"
    DEPTH=$((DEPTH + 1))
done

# 如果没找到，尝试用 git rev-parse
if [ -z "$REPO_DIR" ]; then
    REPO_DIR=$(cd "$SKILL_DIR" && git rev-parse --show-toplevel 2>/dev/null || echo "")
fi

# 检查是否找到仓库路径
if [ -z "$REPO_DIR" ]; then
    log_error "SKILL所在目录不是git仓库"
    echo "请先克隆项目:"
    echo "  git clone $REMOTE_URL"
    exit 1
fi

# 进入仓库根目录
cd "$REPO_DIR" || {
    log_error "无法进入目录: $REPO_DIR"
    exit 1
}

log_info "仓库目录: $(pwd)"

# 检查是否配置了远程仓库
ORIGIN_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$ORIGIN_URL" ]; then
    log_warn "未配置远程仓库 origin"
    log_info "正在添加远程仓库: $REMOTE_URL"
    git remote add origin "$REMOTE_URL" || {
        log_error "添加远程仓库失败"
        exit 1
    }
    log_info "远程仓库配置成功"
elif [ "$ORIGIN_URL" != "$REMOTE_URL" ]; then
    log_warn "当前远程仓库地址与预期不符"
    echo "  当前: $ORIGIN_URL"
    echo "  预期: $REMOTE_URL"
    log_info "正在更新远程仓库地址..."
    git remote set-url origin "$REMOTE_URL" || {
        log_error "更新远程仓库地址失败"
        exit 1
    }
    log_info "远程仓库地址已更新"
fi

# 获取远程更新信息
log_info "正在检查远程仓库更新..."
git fetch origin 2>/dev/null || {
    log_error "无法连接远程仓库，请检查网络连接"
    exit 1
}

# 获取当前分支名
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
log_info "当前分支: $CURRENT_BRANCH"

# 检查是否设置了上游分支
UPSTREAM=$(git rev-parse --abbrev-ref @{u} 2>/dev/null || echo "")

if [ -z "$UPSTREAM" ]; then
    log_warn "未设置上游分支，尝试设置跟踪远程分支..."
    git branch --set-upstream-to="origin/$CURRENT_BRANCH" "$CURRENT_BRANCH" 2>/dev/null || {
        log_warn "无法设置上游分支，请手动配置"
    }
    UPSTREAM=$(git rev-parse --abbrev-ref @{u} 2>/dev/null || echo "")
fi

# 获取本地和远程的commit hash
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse "$UPSTREAM" 2>/dev/null || echo "")

if [ -z "$REMOTE" ]; then
    log_warn "无法获取远程commit信息"
    exit 0
fi

# 比较本地和远程
if [ "$LOCAL" = "$REMOTE" ]; then
    log_info "本地已是最新版本，无需同步"
    exit 0
fi

# 检查本地是否有未提交的修改
HAS_UNSTAGED=$(git diff --name-only 2>/dev/null)
HAS_STAGED=$(git diff --cached --name-only 2>/dev/null)
HAS_UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null)

if [ -n "$HAS_UNSTAGED" ] || [ -n "$HAS_STAGED" ] || [ -n "$HAS_UNTRACKED" ]; then
    log_warn "检测到本地有未提交的修改:"
    [ -n "$HAS_UNSTAGED" ] && echo "  - 未暂存的文件: $(echo "$HAS_UNSTAGED" | wc -l | tr -d ' ') 个"
    [ -n "$HAS_STAGED" ] && echo "  - 已暂存的文件: $(echo "$HAS_STAGED" | wc -l | tr -d ' ') 个"
    [ -n "$HAS_UNTRACKED" ] && echo "  - 未跟踪的文件: $(echo "$HAS_UNTRACKED" | wc -l | tr -d ' ') 个"
    
    # 尝试pull，如果有冲突会失败
    log_info "尝试同步远程更新..."
    if git pull --no-edit origin "$CURRENT_BRANCH" 2>/dev/null; then
        log_info "同步成功"
        exit 0
    else
        log_error "⚠️ 同步失败，检测到冲突！"
        echo ""
        echo "请手动解决冲突，建议执行以下命令："
        echo "  git stash              # 暂存本地修改"
        echo "  git pull origin $CURRENT_BRANCH   # 拉取远程更新"
        echo "  git stash pop          # 恢复本地修改"
        echo ""
        echo "或联系管理员处理。"
        exit 1
    fi
else
    # 本地干净，直接pull
    log_info "远程有更新，正在同步..."
    if git pull --no-edit origin "$CURRENT_BRANCH"; then
        log_info "同步成功"
        exit 0
    else
        log_error "同步失败，请手动处理"
        exit 1
    fi
fi
