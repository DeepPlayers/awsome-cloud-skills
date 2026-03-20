---
name: alibaba-cloud-cli
description: |
  阿里云CLI操作技能，提供完整的安装、配置和云产品操作SOP。当用户需要操作阿里云资源（ECS、OSS、RDS、VPC等）、配置阿里云CLI、进行云资源迁移或管理时，使用此技能。包括CLI安装、凭证配置、ECS实例管理、OSS存储操作等完整工作流。
---

# 阿里云CLI操作技能

本技能提供阿里云CLI的完整操作SOP，包括安装配置和主要云产品的操作脚本。

## ⚠️ 执行前必读：仓库同步检查

**在执行任何任务之前，必须先检查并同步远程仓库更新：**

远程仓库地址：`http://gitlab.alibaba-inc.com/ez-tam-ai/awsome-cloud-skills.git`

### 同步流程

```bash
# 1. 进入项目目录（如果尚未克隆，先执行克隆）
# 克隆仓库（首次使用）
git clone http://gitlab.alibaba-inc.com/ez-tam-ai/awsome-cloud-skills.git
cd awsome-cloud-skills

# 或进入已有的项目目录
cd <你的项目路径>

# 2. 检查远程是否有更新
git fetch origin

# 3. 查看本地和远程的差异
git status

# 4. 如果远程有更新且无冲突，执行pull
git pull origin main
# 或: git pull origin master (根据实际分支名)
```

### 同步规则

| 情况 | 处理方式 |
|------|----------|
| 本地不是git仓库 | 提示用户克隆项目 |
| 本地是git仓库但未配置远程 | 自动添加远程仓库 origin |
| 远程地址与预期不符 | 自动更新远程仓库地址 |
| 远程有更新，本地无修改 | 执行 `git pull` 同步更新 |
| 远程有更新，本地有修改但无冲突 | 执行 `git pull` 同步更新 |
| 远程有更新，本地有冲突 | **跳过pull**，提醒用户手动解决冲突 |
| 远程无更新 | 无需操作，继续执行任务 |

### 冲突处理提醒

如果检测到冲突，**不要自动pull**，需要告知用户：

> ⚠️ 检测到本地仓库与远程存在冲突，已跳过自动同步。请手动解决冲突后执行 `git pull`，或联系管理员处理。

### 同步检查脚本示例

```bash
#!/bin/bash
# sync-repo.sh - 仓库同步检查脚本

REMOTE_URL="http://gitlab.alibaba-inc.com/ez-tam-ai/awsome-cloud-skills.git"

# 获取脚本所在目录，定位到 SKILL.md 所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"  # alibaba-cloud 目录

# 从 SKILL 目录向上查找 git 仓库根目录（最多向上2层）
REPO_DIR=""
SEARCH_DIR="$SKILL_DIR"
MAX_DEPTH=2
DEPTH=0
while [ "$SEARCH_DIR" != "/" ] && [ $DEPTH -lt $MAX_DEPTH ]; do
    [ -d "$SEARCH_DIR/.git" ] && { REPO_DIR="$SEARCH_DIR"; break; }
    SEARCH_DIR="$(dirname "$SEARCH_DIR")"
    DEPTH=$((DEPTH + 1))
done

if [ -z "$REPO_DIR" ]; then
    echo "错误：SKILL所在目录不是git仓库，请先克隆项目："
    echo "  git clone $REMOTE_URL"
    exit 1
fi

cd "$REPO_DIR" || exit 1

# 检查是否配置了远程仓库
ORIGIN_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$ORIGIN_URL" ]; then
    echo "未配置远程仓库，正在添加..."
    git remote add origin "$REMOTE_URL"
elif [ "$ORIGIN_URL" != "$REMOTE_URL" ]; then
    echo "远程仓库地址不匹配，正在更新..."
    git remote set-url origin "$REMOTE_URL"
fi

# 获取远程更新信息
git fetch origin 2>/dev/null

# 检查是否有更新
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")

if [ -z "$REMOTE" ]; then
    echo "未设置上游分支，请先配置远程跟踪"
    exit 0
fi

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "本地已是最新版本，无需同步"
    exit 0
fi

# 检查是否有冲突
if git diff --quiet && git diff --cached --quiet; then
    echo "远程有更新，正在同步..."
    git pull --no-edit origin HEAD && echo "同步成功" || echo "同步失败，请手动处理"
else
    echo "⚠️ 检测到本地有未提交的修改，可能存在冲突"
    echo "请手动执行: git stash && git pull && git stash pop"
fi
```

---

## 快速开始

### 1. 检查环境

首先确认阿里云CLI是否已安装：

```bash
aliyun version
```

### 2. 安装CLI（如未安装）

根据操作系统选择安装方式：

**macOS (推荐Homebrew):**
```bash
brew install aliyun-cli
```

**Linux (一键安装):**
```bash
/bin/bash -c "$(curl -fsSL https://aliyuncli.alicdn.com/install.sh)"
```

**Windows (PowerShell):**
```powershell
# 使用Chocolatey
choco install aliyun-cli

# 或下载安装包
# https://aliyuncli.alicdn.com/aliyun-cli-windows-latest-amd64.zip
```

### 3. 配置凭证

**交互式配置（推荐新手）:**
```bash
aliyun configure
```

**非交互式配置:**
```bash
aliyun configure set \
  --profile default \
  --mode AK \
  --access-key-id <AccessKeyId> \
  --access-key-secret <AccessKeySecret> \
  --region cn-hangzhou
```

## 命令结构

### RPC风格API（大部分产品）

```bash
aliyun <ProductCode> <APIName> [Parameters]
```

示例：
```bash
# 查询ECS可用地域
aliyun ecs DescribeRegions

# 查询ECS实例
aliyun ecs DescribeInstances --RegionId cn-hangzhou
```

### ROA风格API（容器服务等）

```bash
aliyun <ProductCode> <Method> <PathPattern> [RequestBody] [Parameters]
```

示例：
```bash
# 查询ACK集群
aliyun cs GET /regions/cn-hangzhou/clusters
```

## 常用命令选项

| 选项 | 说明 | 示例 |
|------|------|------|
| `--profile, -p` | 指定凭证配置 | `--profile akProfile` |
| `--region` | 指定地域 | `--region cn-beijing` |
| `--output, -o` | 格式化输出 | `--output cols=InstanceId,Status rows=Instances.Instance[]` |
| `--pager` | 聚合分页结果 | `--pager` |
| `--waiter` | 结果轮询 | `--waiter expr='Status' to='Available'` |
| `--dryrun` | 模拟调用 | `--dryrun` |
| `--force` | 强制调用 | 配合 `--version` 使用 |

## 插件管理（CLI 3.3.0+）

阿里云CLI 3.3.0起采用插件化架构，各云产品的命令行调用能力拆分为独立插件。**如果操作的产品命令不存在，需要先安装对应插件。**

### 查找和安装插件

```bash
# 查看所有可用的远程插件
aliyun plugin list-remote

# 搜索包含关键词的插件
aliyun plugin search ecs

# 安装单个插件
aliyun plugin install --names ecs

# 同时安装多个插件
aliyun plugin install --names ecs rds vpc

# 安装指定版本
aliyun plugin install --names fc --version 1.0.0
```

### 启用自动安装插件

```bash
# 通过命令启用
aliyun configure set --auto-plugin-install true

# 或通过环境变量启用
export ALIBABA_CLOUD_CLI_PLUGIN_AUTO_INSTALL=true
```

### 更新和卸载插件

```bash
# 更新指定插件
aliyun plugin update --name ecs

# 更新所有已安装的插件
aliyun plugin update

# 卸载插件
aliyun plugin uninstall --name ecs
```

### 插件命令格式

插件使用短横线命名风格（kebab-case）：

```bash
aliyun <产品Code> <命令> [--参数名 值 ...]

# 示例：查询ECS地域
aliyun ecs describe-regions --accept-language zh-CN

# 示例：查询ECS实例
aliyun ecs describe-instances --biz-region-id cn-hangzhou
```

### 常用插件命令

| 命令 | 说明 |
|------|------|
| `aliyun plugin list` | 列出已安装插件 |
| `aliyun plugin list-remote` | 列出远程可用插件 |
| `aliyun plugin search <关键词>` | 搜索命令对应的插件 |
| `aliyun plugin install --names <名称>` | 安装插件 |
| `aliyun plugin update [--name <名称>]` | 更新插件 |
| `aliyun plugin uninstall --name <名称>` | 卸载插件 |

## 检查未提及产品的CLI支持

当用户需要操作的产品在SKILL中未明确提及，或执行命令时提示命令不存在时，请按以下SOP流程操作：

### SOP流程

```bash
# 第1步：确认产品是否提供CLI支持
aliyun plugin list-remote

# 第2步：根据产品名搜索对应的插件名称
aliyun plugin search <产品关键词>
# 例如：搜索DMS产品
aliyun plugin search dms

# 第3步：安装确认的插件
aliyun plugin install --names <插件名称>
# 例如：安装DMS插件
aliyun plugin install --names dms

# 第4步：确认插件支持的操作
<产品Code> <命令> --help
# 例如：查看DMS支持的操作
aliyun dms --help
```

### 完整示例：检查DMS产品的CLI支持

```bash
# 步骤1：列出所有可用插件，找到目标产品
aliyun plugin list-remote | grep -i dms

# 步骤2：安装DMS插件
aliyun plugin install --names dms

# 步骤3：查看DMS插件支持的命令
aliyun dms --help

# 步骤4：根据help输出执行具体操作
aliyun dms <具体命令> --help
```

### 注意事项

- **插件安装是按需的**：只有安装对应插件后，才能使用该产品的CLI命令
- **插件命名规则**：插件名称通常为产品名称的小写形式（如 `ecs`、`rds`、`dms`）
- **自动安装功能**：可通过 `aliyun configure set --auto-plugin-install true` 启用命令自动安装插件
- **版本兼容性**：部分插件可能需要特定版本的CLI，必要时请先更新CLI

### 常见问题

| 问题 | 解决方案 |
|------|----------|
| `plugin list-remote` 输出为空 | 检查网络连接，或更新CLI到最新版本 |
| 搜索不到目标产品插件 | 该产品可能尚未提供CLI插件支持，可联系阿里云确认 |
| 插件安装失败 | 检查插件名称是否正确，确认CLI版本支持插件功能 |
| 安装后命令仍不可用 | 重新打开终端窗口，或检查插件是否安装成功 |

---

## 处理必须指定Region参数但是未指定Region的查询

> **适用范围**：本SOP适用于所有需要指定Region的阿里云产品查询操作，不仅限于ECS。

当查询操作需要强制指定`RegionId`，但客户未提供具体区域时，请按以下流程处理：

### SOP流程

```bash
# 第1步：咨询用户确认区域
# 询问用户需要操作的具体区域

# 第2步：若用户不确定，先列出可用区域（ECS通用接口）
aliyun ecs DescribeRegions --accept-language zh-CN

# 对于其他产品，同样可以使用ecs接口获取Region列表
aliyun ecs DescribeRegions --output json | jq -r '.Regions.Region[].RegionId'
```

### 遍历多Region执行查询

当用户需要查询多个区域或不确定具体区域时，可以遍历所有可用区域：

```bash
# 步骤1：获取所有Region列表
REGIONS=$(aliyun ecs DescribeRegions --accept-language zh-CN --output json | jq -r '.Regions.Region[].RegionId')

# 步骤2：遍历每个Region执行查询
for REGION in $REGIONS; do
    echo "=== 查询区域: $REGION ==="
    # RDS实例查询
    aliyun rds DescribeDBInstances --RegionId "$REGION"
done
```

### 完整示例

**场景1：查询用户未指定区域的ECS实例**

```bash
# 列出所有可用区域（便于用户确认）
aliyun ecs DescribeRegions --accept-language zh-CN --output table

# 根据用户选择的区域执行查询
aliyun ecs DescribeInstances --RegionId cn-hangzhou --output table

# 或遍历所有区域（如果用户需要全量数据）
for region in cn-hangzhou cn-beijing cn-shanghai; do
    echo "=== 区域: $region ==="
    aliyun ecs DescribeInstances --RegionId "$region" --output table
done
```

**场景2：查询用户未指定区域的RDS实例**

```bash
# 同样先获取Region列表
aliyun ecs DescribeRegions --accept-language zh-CN --output table

# 查询指定区域的RDS实例
aliyun rds DescribeDBInstances --RegionId cn-hangzhou --output table
```

**场景3：查询用户未指定区域的VPC资源**

```bash
# VPC资源查询同样需要Region
aliyun vpc DescribeVpcs --RegionId cn-hangzhou --output table
aliyun vpc DescribeVSwitches --RegionId cn-hangzhou --output table
```

### 注意事项

- **Region查询接口统一**：所有阿里云产品的可用区域列表都通过`ecs DescribeRegions`接口获取
- **RegionId命名规范**：阿里云RegionId通常为`cn-xxx`（中国区）或`ap-xxx`/`us-xxx`（海外区）格式
- **全球与中国区**：阿里云有多个端点，全球Region（国际站）和中国区（Aliyun）可能需要不同的凭证
- **查询限制**：遍历多Region查询可能耗时较长，可通过`--pager`选项聚合分页结果
- **结果输出格式**：使用`--output table`可以更直观地展示结果，便于用户查看

---

## 主要云产品Code

| 产品 | Code | 产品 | Code |
|------|------|------|------|
| 云服务器ECS | ecs | 对象存储OSS | oss (ossutil) |
| 专有网络VPC | vpc | 负载均衡SLB | slb |
| 云数据库RDS | rds | 云数据库PolarDB | polardb |
| 容器服务ACK | cs | 函数计算FC | fc |
| 访问控制RAM | ram | 安全令牌STS | sts |
| 云监控CMS | cms | 日志服务SLS | sls |
| 数据管理DMS | dms | 云效/DevOps | devops |

## 操作指南

### ECS操作

详见 `scripts/ecs/` 目录下的脚本：

- `list-instances.sh` - 列出实例
- `create-instance.sh` - 创建实例
- `start-instance.sh` - 启动实例
- `stop-instance.sh` - 停止实例
- `create-image.sh` - 创建镜像
- `migrate-instance.sh` - 跨地域迁移

### OSS操作

OSS使用内置的ossutil工具：

```bash
# 列出Bucket
aliyun ossutil ls

# 上传文件
aliyun ossutil cp local-file oss://bucket/path/

# 下载文件
aliyun ossutil cp oss://bucket/path/file ./

# 同步目录
aliyun ossutil sync ./local-dir oss://bucket/dir/
```

详见 `scripts/oss/` 目录下的脚本。

## 错误排查

### 常见问题

1. **找不到aliyun命令**
   - 检查PATH环境变量
   - 确认安装路径正确

2. **凭证无效**
   - 检查AccessKey是否正确
   - 确认RAM用户权限

3. **网络超时**
   - 检查网络连接
   - 尝试使用 `--read-timeout` 增加超时时间

4. **权限不足**
   - 检查RAM策略
   - 确认操作所需的API权限

### 调试技巧

```bash
# 模拟调用，查看请求详情
aliyun ecs DescribeInstances --dryrun

# 启用日志
aliyun ecs DescribeInstances --debug
```

## 脚本使用说明

本技能提供了预置脚本，位于 `scripts/` 目录：

```
scripts/
├── install.sh           # CLI安装脚本
├── configure.sh         # 凭证配置脚本
├── ecs/
│   ├── list-instances.sh
│   ├── create-instance.sh
│   ├── start-instance.sh
│   ├── stop-instance.sh
│   ├── create-image.sh
│   └── migrate-instance.sh
├── oss/
│   ├── bucket-ops.sh
│   ├── upload.sh
│   ├── download.sh
│   └── sync.sh
└── utils/
    ├── sync-repo.sh     # 仓库同步检查脚本（优先执行）
    ├── output-format.sh
    ├── waiter.sh
    └── error-check.sh
```

使用脚本时，根据需要修改其中的参数变量。

## 参考文档

详细参考文档位于 `references/` 目录：

- [What is Alibaba Cloud CLI](references/01-what-is-alibaba-cloud-cli/what-is-alibaba-cloud-cli.md) - 阿里云CLI概念与核心功能
- [Quick Start](references/02-quick-start/) - 快速入门指南
- [Installation Guide](references/03-installation-guide/) - 安装指南
- [Configure Alibaba Cloud CLI](references/04-configure-alibaba-cloud-cli/) - 配置凭证和相关设置
- [Using Alibaba Cloud CLI](references/05-using-alibaba-cloud-cli/) - 详细使用指南
- [Best Practices](references/06-best-practices/) - 最佳实践
- [Troubleshooting](references/08-troubleshooting/cli-troubleshooting.md) - 错误排查指南

中文文档位于 `references/zh/` 目录。
