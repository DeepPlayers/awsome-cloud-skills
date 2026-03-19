# 命令行选项

本文将为您列举阿里云CLI调用OpenAPI时可用的命令行选项及其作用，帮助您修改命令默认行为或开启部分功能。

## **选项格式**

命令行选项 `options` 可用于OpenAPI通用命令之后，格式如下：

```shell
aliyun <Command> <SubCommand> --options [optionParams]
```

## 可用选项列表

| **选项** | **说明** |
| :--- | :--- |
| **--profile,-p** | 指定配置名称后，阿里云CLI将忽略默认身份凭证配置及环境变量设置，优先使用指定的配置调用命令。示例：`aliyun ecs DescribeInstances --profile akProfile` |
| **--region** | 指定有效地域ID后，阿里云CLI将忽略默认身份凭证配置及环境变量设置中的地域信息，优先使用指定的地域调用命令。示例：`aliyun ecs DescribeInstances --region cn-beijing` |
| **--endpoint** | 指定调用命令时使用的接入点地址。示例：`aliyun cms DescribeMonitorGroups --endpoint metrics.cn-qingdao.aliyuncs.com` |
| **--endpoint-type** | 指定endpoint类型，支持vpc或空值（默认公网访问）。示例：`aliyun ecs DescribeInstances --endpoint-type vpc` |
| **--version** | 指定调用命令时访问的API版本。使用时需结合 `--force` 选项。示例：`aliyun cms QueryMetricList --version 2017-03-01 --force` |
| **--header** | 为命令添加指定的请求头，可重复添加。示例：`aliyun <product> <ApiName> --header X-foo=bar` |
| **--body** | 在调用ROA风格API命令时，传入字符串格式参数作为请求主体。 |
| **--body-file** | 在调用ROA风格API命令时，传入指定文件作为请求主体。该选项优先级高于 `--body` 选项。 |
| **--read-timeout** | 指定命令的I/O超时时间，单位为秒。 |
| **--connect-timeout** | 指定命令的连接超时时间，单位为秒。 |
| **--retry-count** | 指定命令的重试次数。 |
| **--secure** | 强制使用HTTPS协议调用OpenAPI。 |
| **--insecure** | 强制使用HTTP协议调用OpenAPI。 |
| **--quiet,-q** | 关闭正常调用命令时的返回结果输出。 |
| **--help** | 获取该命令的帮助信息。更多详情，请参见[获取帮助信息](https://help.aliyun.com/zh/cli/use-the-help-command)。 |
| **--output,-o** | 提取OpenAPI返回结果中的字段，且以表格形式展示返回结果输出。更多详情，请参见[过滤且表格化输出结果](https://help.aliyun.com/zh/cli/filter-results-and-tabulate-output)。 |
| **--pager** | 在调用各云产品的分页类接口时，不分页获取所有的结果。更多详情，请参见[聚合分页数据](https://help.aliyun.com/zh/cli/aggregation-of-paging-interface-results)。 |
| **--force** | 强制调用元数据列表以外的API和参数。更多详情，请参见[强制调用接口](https://help.aliyun.com/zh/cli/force-call-apis)。 |
| **--waiter** | 开启结果轮询，直到某个字段出现特定值时停止轮询。更多详情，请参见[结果轮询](https://help.aliyun.com/zh/cli/result-polling)。 |
| **--dryrun** | 完整打印向服务器发起的请求信息，用于调试和验证，不会对云上资源进行实际更改。更多详情，请参见[模拟调用功能](https://help.aliyun.com/zh/cli/simulate-a-call)。 |
