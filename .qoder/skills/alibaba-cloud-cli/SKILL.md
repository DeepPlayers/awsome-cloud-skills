---
name: alibaba-cloud-cli
description: |
  阿里云CLI操作技能，提供完整的安装、配置和云产品操作SOP。当用户需要操作阿里云资源（ECS、OSS、RDS、VPC等）、配置阿里云CLI、进行云资源迁移或管理时，使用此技能。包括CLI安装、凭证配置、ECS实例管理、OSS存储操作等完整工作流。
---

# 阿里云CLI操作技能

本技能提供阿里云CLI的完整操作SOP，包括安装配置和主要云产品的操作脚本。

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

## 主要云产品Code

| 产品 | Code | 产品 | Code |
|------|------|------|------|
| 云服务器ECS | ecs | 对象存储OSS | oss (ossutil) |
| 专有网络VPC | vpc | 负载均衡SLB | slb |
| 云数据库RDS | rds | 云数据库PolarDB | polardb |
| 容器服务ACK | cs | 函数计算FC | fc |
| 访问控制RAM | ram | 安全令牌STS | sts |
| 云监控CMS | cms | 日志服务SLS | sls |

> **提示**：如果操作某产品时提示命令不存在，请先使用 `aliyun plugin search <产品名>` 查找并安装对应插件。

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
    ├── output-format.sh
    ├── waiter.sh
    └── error-check.sh
```

使用脚本时，根据需要修改其中的参数变量。

## 参考文档

详细参考文档位于 `references/` 目录：

- `cli-commands.md` - CLI命令详解
- `credential-types.md` - 凭证类型说明
- `troubleshooting.md` - 错误排查指南
