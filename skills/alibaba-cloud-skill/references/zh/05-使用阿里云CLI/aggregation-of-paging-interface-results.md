# 聚合分页数据

调用分页类接口时，默认情况下仅返回单页查询结果。使用 `--pager` 选项可聚合分页数据，实现全量数据的一次性获取。

## 字段说明

`--pager` 选项包含以下字段：

| 字段 | 描述 | 默认值 |
| :--- | :--- | :--- |
| PageNumber | 列表当前页码。 | `PageNumber` |
| PageSize | 每页最大结果数量。 | `PageSize` |
| TotalCount | 列表总行数。 | `TotalCount` |
| NextToken | 查询凭证。 | `NextToken` |
| path | 目标数据的 [JMESPath](http://jmespath.org/) 路径。 | 自动识别数组类型数据路径。 |

> **说明**
> 若接口返回字段与默认值不一致，可能导致解析异常。建议您根据实际返回数据结构，手动映射字段参数。

## 示例

### 完整指定字段

```shell
aliyun ecs DescribeInstances --pager PageNumber=PageNumber PageSize=PageSize TotalCount=TotalCount path=Instances.Instance
```

### 使用默认值简化命令

若字段参数值与默认值一致，无需显式指定：

```bash
aliyun ecs DescribeInstances --pager
```

聚合后仅输出聚合字段。若需通过过滤功能查看特定字段，请注意过滤路径应为聚合后的 JMESPath 路径。更多信息，请参见[过滤且表格化输出结果](https://help.aliyun.com/zh/cli/filter-results-and-tabulate-output)。
