# 查看版本更新与变更详情

阿里云CLI定期更新，可能包含接口参数调整或其他重要变更。为帮助您快速了解这些变化，本文为您介绍查看阿里云CLI更新内容的操作步骤。

## 查看主要变更

阿里云CLI的每个版本都会在GitHub Releases页面中发布对应的变更日志。这里列出了每个版本的新增功能、修复问题、依赖库更新等主要变更。

具体操作步骤：

1. 访问阿里云CLI的 [GitHub Releases](https://github.com/aliyun/aliyun-cli/releases) 页面，查找目标版本的发布说明。
2. 在发布说明中，您可以查看版本号、主要变更及对应 commit 链接、版本对比链接。
3. 如需查看详细变更信息，可单击主要变更后的 commit 链接，在 Files changed 标签页中查看对应的代码变更。

## 查看API元数据变更

> **说明**
> 本文所述API元数据专为构建阿里云CLI而设计，与通过OpenAPI门户获取的 [OpenAPI元数据](https://help.aliyun.com/zh/sdk/product-overview/openapi-metadata) 存在差异。

### 在线查看

1. 访问阿里云CLI的 [GitHub Releases](https://github.com/aliyun/aliyun-cli/releases) 页面，查找目标版本的发布说明。
2. 单击 Full Changelog 后的版本对比链接，进入GitHub的对比页面。
3. 在该页面中查看 `aliyun-openapi-meta` 子模块差异。重点关注：
   - `metadatas/<PRODUCT_NAME>/<API_Name>.json` - API接口定义
   - `metadatas/product.json` - 云产品信息

### 本地对比

1. 从当前版本中 [导出元数据](https://help.aliyun.com/zh/cli/export-metadata)。
2. [更新阿里云CLI](https://help.aliyun.com/zh/cli/update-cli) 至目标版本，再次执行导出操作。
3. 对比版本更新前后 `metadatas` 目录下的元数据差异。

## 元数据结构示例

**API元数据文件示例：**

```json
{
  "name": "DescribeInstances",
  "protocol": "HTTP|HTTPS",
  "method": "GET|POST",
  "pathPattern": "",
  "parameters": [
    {
      "name": "AdditionalAttributes",
      "position": "Query",
      "type": "RepeatList",
      "required": false
    }
  ]
}
```

**云产品元数据文件示例：**

```json
{
  "products": [
    {
      "code": "ECS",
      "version": "2014-05-26",
      "name": {
        "en": "Elastic Compute Service",
        "zh": "云服务器 ECS"
      },
      "location_service_code": "ecs",
      "regional_endpoints": {
        "cn-hangzhou": "ecs-cn-hangzhou.aliyuncs.com"
      },
      "global_endpoint": "",
      "api_style": "rpc",
      "apis": [
        "DescribeInstances"
      ]
    }
  ]
}
```
