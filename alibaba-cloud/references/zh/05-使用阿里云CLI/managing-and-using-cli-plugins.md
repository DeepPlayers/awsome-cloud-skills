# 管理和使用插件

阿里云CLI 3.3.0起引入插件化架构，将各云产品的命令行调用能力拆分为独立插件。每个插件对应一个云产品，可按需安装、独立更新，CLI主程序保持轻量。所有插件统一使用短横线（kebab-case）命名风格，并自动处理参数序列化，简化调用体验。

## 前提条件

1. 已安装阿里云CLI 3.3.0或更高版本。安装方法，请参见[安装CLI（Linux）](https://help.aliyun.com/zh/cli/install-cli-on-linux)。
2. 确保阿里云CLI已配置凭证。配置方法，请参见[配置凭证](https://help.aliyun.com/zh/cli/configure-credentials)。

## 快速开始

以安装 `ecs` 插件为例，介绍安装插件并查询地域列表的流程。

```bash
# 安装插件（以ecs插件为例）
aliyun plugin install --names ecs

# 调用API查询地域列表
aliyun ecs describe-regions --accept-language zh-CN
```

可通过 `aliyun ecs --help` 查看ecs插件支持的所有命令。

## 插件概述

插件将各云产品的API调用能力封装为独立的可执行程序，由CLI主程序统一调度。主要特性如下：

- **按需安装**：仅安装所需云产品插件，减少CLI体积。
- **独立更新**：插件独立发布版本，无需升级CLI主程序。
- **统一命名**：命令和参数使用短横线命名，例如 `describe-instances`、`--accept-language`。
- **参数简化**：自动处理底层参数序列化，统一使用键值对格式输入。
- **完整帮助**：通过 `--help` 查看参数类型、描述和是否必填。

插件安装在 `~/.aliyun/plugins` 目录下，清单记录在 `manifest.json` 文件中。

### **插件命名规则**

插件命名格式为 `aliyun-cli-<产品Code>`，产品Code与阿里云OpenAPI一致，示例如下：

| 插件名称 | 产品Code | 对应云产品 |
| :--- | :--- | :--- |
| `aliyun-cli-ecs` | `ecs` | 云服务器ECS |
| `aliyun-cli-fc` | `fc` | 函数计算FC |
| `aliyun-cli-rds` | `rds` | 云数据库RDS |

## 安装插件

### 查看和搜索插件

```bash
# 查看远程索引中所有可用的插件
aliyun plugin list-remote

# 搜索包含ecs的插件
aliyun plugin search ecs

# 搜索ecs产品下以describe开头的命令
aliyun plugin search "ecs describe"
```

### 执行安装

```bash
# 安装单个插件
aliyun plugin install --names ecs

# 同时安装多个插件
aliyun plugin install --names fc ecs

# 安装指定版本
aliyun plugin install --names fc --version 1.0.0
```

## 使用插件

命令格式：

```bash
aliyun <产品Code> <命令> [--参数名 值 ...]
```

### 使用示例

#### 查看插件帮助信息

```bash
aliyun ecs --help
aliyun ecs describe-regions --help
```

#### 查询地域列表

```bash
aliyun ecs describe-regions --accept-language zh-CN
```

### 进阶用法

#### 结构化参数输入

- 数组参数：重复使用特定参数。

  ```bash
  aliyun ecs describe-account-attributes \
        --biz-region-id cn-hangzhou \
        --attribute-name max-security-groups \
        --attribute-name instance-network-type
  ```

- 对象参数：使用 `key=value` 格式。

  ```bash
  aliyun ecs describe-instances --biz-region-id cn-hangzhou \
         --tag key=env value=prod
  ```

#### 多版本API

对于支持多API版本的插件，可使用 `--api-version` 参数指定API版本：

```bash
# 使用默认API版本
aliyun ess describe-scaling-groups --biz-region-id cn-hangzhou

# 使用指定API版本
aliyun ess describe-scaling-groups --api-version 2022-02-22 --biz-region-id cn-hangzhou

# 查看支持的API版本列表
aliyun ess list-api-versions
```

通过环境变量设置默认版本：

```bash
echo 'export ALIBABA_CLOUD_ESS_API_VERSION=2022-02-22' >> ~/.bashrc
source ~/.bashrc
```

## 更新和卸载插件

### 更新插件

```bash
# 更新指定插件
aliyun plugin update --name ecs

# 更新所有已安装的插件
aliyun plugin update
```

### 卸载插件

```bash
aliyun plugin uninstall --name ecs
```

## 配置自动安装插件

```bash
# 通过命令启用
aliyun configure set --auto-plugin-install true

# 或通过环境变量启用
echo 'export ALIBABA_CLOUD_CLI_PLUGIN_AUTO_INSTALL=true' >> ~/.bashrc
source ~/.bashrc
```

## 附录

### 插件命令列表

| 命令 | 说明 |
| :--- | :--- |
| `aliyun plugin list` | 列出已安装插件 |
| `aliyun plugin list-remote` | 列出远程可用插件 |
| `aliyun plugin search <命令名>` | 搜索命令对应的插件 |
| `aliyun plugin install --names <名称> [--version <版本>] [--enable-pre]` | 安装插件 |
| `aliyun plugin update [--name <名称>] [--enable-pre]` | 更新插件 |
| `aliyun plugin uninstall --name <名称>` | 卸载插件 |

### 插件环境变量列表

| 环境变量 | 说明 |
| :--- | :--- |
| `ALIBABA_CLOUD_CLI_PLUGINS_DIR` | 自定义插件目录，默认为 `~/.aliyun/plugins` |
| `ALIBABA_CLOUD_CLI_PLUGIN_NO_CACHE` | 设为 `true` 禁用远程索引缓存 |
| `ALIBABA_CLOUD_CLI_PLUGIN_AUTO_INSTALL` | 设为 `true` 启用自动安装 |
| `ALIBABA_CLOUD_CLI_PLUGIN_AUTO_INSTALL_ENABLE_PRE` | 设为 `true` 允许自动安装预发布版本 |
| `ALIBABA_CLOUD_<PRODUCT_CODE>_API_VERSION` | 设置产品插件默认API版本 |
| `ALIBABA_CLOUD_CLI_MAX_LINE_LENGTH` | 调节参数help信息的单行输出长度 |
