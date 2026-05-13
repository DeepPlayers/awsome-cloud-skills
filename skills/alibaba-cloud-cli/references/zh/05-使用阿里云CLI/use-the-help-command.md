# 获取帮助信息

阿里云 CLI 集成了产品和 API 信息，输入 `--help` 选项可获取详细的命令帮助信息。

## 获取支持产品列表及可用命令行选项

在 `aliyun` 命令后使用 `--help` 选项，获取通用命令行选项及支持产品列表。

```shell
aliyun --help
```

## 获取产品可用 OpenAPI 列表

在产品 code 后使用 `--help` 选项，可以获取产品可用 OpenAPI 列表。在列表中，RPC 风格的 OpenAPI 会显示接口的功能描述，而 ROA 风格的 OpenAPI 则显示对应的访问路径。

> **说明**
>
> 阿里云 CLI 会在接口描述前显示不同的标识：
> - `[Anonymous]`：匿名接口，无需身份验证即可调用。
> - `[Deprecated]`：弃用接口，建议切换至更新的替代接口。

### RPC 风格

```shell
aliyun ecs --help
```

### ROA 风格

```shell
aliyun cs --help
```

## 获取 OpenAPI 参数详情

在接口名称后使用 `--help` 选项，获取 OpenAPI 可用参数的详细信息，包括参数名称、参数类型等。ROA 风格 OpenAPI 会额外显示请求方式及访问路径。

### RPC 风格

```shell
aliyun ecs DescribeRegions --help
```

预期返回参数信息包括：
- `--AcceptLanguage String Optional` - 根据汉语、英语和日语筛选返回结果。取值范围：zh-CN、en-US、ja。默认值为 zh-CN。
- `--InstanceChargeType String Optional` - 实例的计费方式。取值范围：PrePaid（包年包月）、PostPaid（按量付费）。默认值为 PostPaid。
- `--ResourceType String Optional` - 资源类型。取值范围：instance、disk、reservedinstance、scu。默认值：instance。

### ROA 风格

```shell
aliyun cs AttachInstances --help
```

预期返回信息包括：
- Product: CS (容器服务 Kubernetes 版)
- Method: POST
- PathPattern: /clusters/[ClusterId]/attach
- `--ClusterId String Required` - 集群 ID。
- `--body Struct Optional` - 请求体参数。
