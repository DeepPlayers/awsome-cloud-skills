# 在Docker容器中运行阿里云CLI

使用 Docker 可以快速创建一个用于运行阿里云 CLI 的隔离环境，提高运行环境的安全性。本教程将为您介绍如何在 Docker 容器中运行阿里云 CLI。

## 前提条件

- 请确保您已经安装 Docker 18.09 或更高版本。详细安装说明，请参见 [Docker 官方文档](https://docs.docker.com/get-started/get-docker/)。
- 安装完成后，您可以执行 `docker --version` 命令验证 Docker 的安装信息。
- 由于运营商网络原因，可能导致拉取 Docker Hub 镜像变慢。阿里云容器镜像服务 ACR 提供了官方的镜像加速器，具体操作请参见 [官方镜像加速](https://help.aliyun.com/zh/acr/user-guide/accelerate-the-pulls-of-docker-official-images)。

## **方案概览**

1. 创建 `Dockerfile` 文件
2. 构建自定义镜像
3. 启动容器
4. 连接容器

## 步骤一：创建 Dockerfile 文件

### CentOS Dockerfile

```dockerfile
FROM centos:latest

# 获取并安装阿里云 CLI 工具
RUN curl -SLO "https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz"
RUN tar -xvzf aliyun-cli-linux-latest-amd64.tgz
RUN rm aliyun-cli-linux-latest-amd64.tgz
RUN mv aliyun /usr/local/bin/
```

### Alpine Linux Dockerfile

```dockerfile
FROM alpine:latest

RUN apk add --no-cache jq

RUN wget https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz
RUN tar -xvzf aliyun-cli-linux-latest-amd64.tgz
RUN rm aliyun-cli-linux-latest-amd64.tgz
RUN mv aliyun /usr/local/bin/

# alpine 需要额外创建 lib64 的动态链接库软连接
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
```

**注意事项**

- Docker 文件应始终命名为 `Dockerfile`（带有大写字母 D 且没有文件扩展名）。
- 若您使用 ARM 架构系统（例如苹果 M1 芯片），则下载地址需要改为 `https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-arm64.tgz`。

## **步骤二：构建自定义镜像**

```shell
docker build --tag aliyuncli .
```

## **步骤三：启动容器**

```shell
docker run -it -d --name mycli aliyuncli
```

## **步骤四：连接容器**

```shell
docker exec -it mycli /bin/sh
```

在容器内部执行 `aliyun version` 命令，查看阿里云 CLI 版本信息。

## **后续操作**

成功启动并进入 Docker 容器后，您需要为阿里云 CLI 配置身份凭证。更多信息，请参见 [配置凭证](https://help.aliyun.com/zh/cli/configure-credentials) 及 [生成并调用命令](https://help.aliyun.com/zh/cli/sample-commands)。
