# 结果轮询

在阿里云云产品中的某些API返回的结果会随时间的推移而变化。您可以通过结果轮询，直到某个字段出现特定值时停止轮询，并返回数据。

## --waiter选项字段说明

您可以通过使用`--waiter`选项进行结果轮询。该选项包含以下两个子字段。

| 字段名 | 描述 |
| :--- | :--- |
| expr | 表示通过[JMESPath](http://jmespath.org/)查询语句指定的JSON结果中的被轮询字段。 |
| to | 表示被轮询字段的目标值。 |

## 示例

### 示例场景

执行创建ECS实例的命令后，调用`DescribeInstances`接口查询该实例的详细信息。使用`--waiter`选项后，阿里云CLI将以一定时间间隔进行实例状态轮询。直到实例创建完成并启动，处于`Running`状态后停止轮询，`DescribeInstances`接口成功返回数据。

### 示例命令

执行如下命令，当实例处于`Running`状态时，停止轮询，并返回数据。

```shell
aliyun ecs DescribeInstances --InstanceIds '["i-12345678912345678123"]' --waiter expr='Instances.Instance[0].Status' to='Running'
```
