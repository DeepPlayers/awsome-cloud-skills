# 命令结构

本文将介绍阿里云CLI的通用命令结构，以及在调用RPC风格或ROA风格OpenAPI时所需的特定命令结构。

## 通用命令结构

阿里云CLI的通用命令结构如下：

```shell
aliyun <Command> [SubCommand] [Options and Parameters]
```

结构示例中`Command`、`SubCommand`、`Options and Parameters`的详细信息如下所示：

- `Command`：指定一个顶级命令。
  - 可指定阿里云CLI支持的云产品Code`ProductCode`，例如ecs、rds等。
  - 可指定阿里云CLI本身的功能命令，例如configure等。
- `SubCommand`：指定要执行操作的子命令，即具体的某一项操作。
  - 当顶级命令`command`为`configure`时，支持的子命令请参见[配置凭证相关命令](https://help.aliyun.com/zh/cli/other-configure-command-operations)。
  - 当顶级命令`command`为云产品Code，且OpenAPI风格为RPC风格时，子命令通常为可调用的OpenAPI名称。
- `Options and Parameters`：指定用于控制阿里云CLI行为的选项或者OpenAPI参数选项，选项值可以是数字、字符串和JSON结构字符串等。更多参数格式信息，请参见[参数格式](https://help.aliyun.com/zh/cli/parameter-format-overview)。

## **判断OpenAPI风格**

阿里云云产品OpenAPI分为RPC和ROA两种风格类型，大部分产品使用的是RPC风格。不同风格接口的调用方式不同，当您使用阿里云CLI调用接口时需要判断接口类型。您可以通过以下方式判断OpenAPI风格：

- 前往目标云产品文档，单击**开发参考** > **API概览**，在文档中查看云产品支持的OpenAPI风格。
- 在阿里云CLI中，通过在云产品Code`ProductCode`后使用`--help`选项可以获取产品可用OpenAPI列表，不同风格接口显示的帮助信息存在差异。
  - RPC风格OpenAPI将在帮助信息中显示接口简述。
  - ROA风格OpenAPI将在帮助信息中显示访问路径`PathPattern`。
- 在阿里云CLI中，通过在接口名称`APIName`后使用`--help`选项可以获取OpenAPI参数详情。ROA风格OpenAPI会在帮助信息中额外显示接口的请求方式`Method`和访问路径`PathPattern`。

一般情况下，每个产品内所有接口的调用风格是统一的，且每个接口仅支持特定的一种风格。更多关于RPC风格和ROA风格的信息，请参见[OpenAPI 风格](https://help.aliyun.com/zh/sdk/product-overview/openapi-style)。

## **RPC风格命令结构**

### **结构说明**

在阿里云CLI中，调用RPC风格的OpenAPI时，其命令结构如下。

```shell
aliyun <ProductCode> <APIName> [Parameters]
```

- `ProductCode`：云产品Code。例如云服务器 ECS的云产品Code为`ecs`。
- `APIName`：接口名称。例如使用云服务器 ECS的`DescribeRegions`接口。
- `Parameters`：请求参数。

### **命令示例**

- 调用云服务器 ECS `DescribeRegions`接口，查询可用地域信息列表：
  
  ```shell
  aliyun ecs DescribeRegions
  ```

- 调用云服务器 ECS `DescribeInstanceAttribute`接口，查询指定ECS实例的属性信息：
  
  ```shell
  aliyun ecs DescribeInstanceAttribute --InstanceId 'i-uf6f5trc95ug8t33****'
  ```

## **ROA风格命令结构**

### **命令结构**

在阿里云CLI中，调用ROA风格OpenAPI时，基本命令结构如下。

```shell
aliyun <ProductCode> <Method> <PathPattern> [RequestBody] [Parameters]
```

- `ProductCode`：云产品Code。例如容器服务 Kubernetes 版 ACK的云产品Code为`cs`。
- `Method`：请求方式。常用请求方式有`GET`、`PUT`、`POST`、`DELETE`。
- `PathPattern`：请求路径。
- `RequestBody`：请求主体。
  - 使用`--body`选项指定字符串或变量作为请求主体。
  - 使用`--body-file`选项指定文件路径，将目标文件作为请求主体。
- `Parameters`：请求参数。

### **命令示例**

#### GET请求

```shell
aliyun cs GET /regions/cn-hangzhou/clusters --cluster_type Kubernetes
```

#### PUT请求

```shell
aliyun cs PUT /api/v2/clusters/cb95aa626a47740afbf6aa099b65**** --body "{\"api_server_eip\":true,\"api_server_eip_id\":\"eip-wz9fnasl6dsfhmvci****\"}"
```

#### POST请求

```shell
aliyun cs POST /clusters --body-file create.json
```

#### DELETE请求

```shell
aliyun cs DELETE /clusters/cb95aa626a47740afbf6aa099b65****/nodepools/np30db56bcac7843dca90b999c8928****
```
