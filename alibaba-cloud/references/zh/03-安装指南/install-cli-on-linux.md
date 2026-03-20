# 在 Linux 上安装阿里云 CLI

本文为您介绍在 Linux 系统中安装阿里云 CLI 的操作步骤。

## 安装步骤

在 Linux 系统中，您可以通过以下方式安装阿里云 CLI。

### 通过 Bash 脚本安装

阿里云 CLI 提供一键安装脚本，简化安装操作。您可参考以下示例快速安装阿里云 CLI。

- **安装最新版本**
  
  若未指定版本，安装脚本将默认获取并安装阿里云 CLI 的最新可用版本。
  
  ```bash
  /bin/bash -c "$(curl -fsSL https://aliyuncli.alicdn.com/install.sh)"
  ```

- **安装历史版本**
  
  使用 `-V` 选项可指定阿里云 CLI 的安装版本。访问 [GitHub Release](https://github.com/aliyun/aliyun-cli/releases) 页面可查看历史可用版本。
  
  ```bash
  /bin/bash -c "$(curl -fsSL https://aliyuncli.alicdn.com/install.sh)" -- -V 3.0.277
  ```

- **显示使用说明**
  
  使用 `-h` 选项可在终端中查看阿里云 CLI 安装脚本的使用说明。
  
  ```bash
  /bin/bash -c "$(curl -fsSL https://aliyuncli.alicdn.com/install.sh)" -- -h
  ```

### 通过 TGZ 安装包安装

1. **下载安装包**
   
   您可以通过以下方式下载安装包。
   
   - **下载最新版本：**
     
     > **说明**
     > 您可以执行 `uname -m` 命令查看 Linux 系统架构。如果终端输出 `arm64` 或 `aarch64`，表示您的系统架构为 ARM64。输出其他信息则表示您的系统架构为 AMD64。
     
     执行以下命令，下载适用于 Linux AMD64 系统的最新版本安装包：
     
     ```bash
     curl https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz -o aliyun-cli-linux-latest.tgz
     ```
     
     执行以下命令，下载适用于 Linux ARM64 系统的最新版本安装包：
     
     ```bash
     curl https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-arm64.tgz -o aliyun-cli-linux-latest.tgz
     ```
   
   - **下载历史版本：**
     
     访问 [GitHub Release](https://github.com/aliyun/aliyun-cli/releases) 页面可下载历史版本安装包。Linux 系统适用安装包包名格式为 `aliyun-cli-linux-<version>-<architecture>.tgz`。

2. **解压安装包**
   
   在安装包所在目录执行以下命令，解压安装包以获取可执行文件 `aliyun`：
   
   ```shell
   tar xzvf aliyun-cli-linux-latest.tgz
   ```

3. **配置全局调用**
   
   执行以下命令，移动可执行文件至 `/usr/local/bin` 目录下，实现阿里云 CLI 的全局调用：
   
   ```bash
   sudo mv ./aliyun /usr/local/bin/
   ```

## 验证安装结果

在终端会话中执行如下命令，验证阿里云 CLI 是否安装成功：

```shell
aliyun version
```

系统显示类似如下阿里云 CLI 版本号，表示安装成功：

```shell
3.0.277
```
