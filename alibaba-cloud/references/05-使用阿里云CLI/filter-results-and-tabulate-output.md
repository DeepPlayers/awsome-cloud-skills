# 过滤且表格化输出结果

阿里云产品的查询接口会返回JSON结构化数据，不方便阅读。您可以通过使用阿里云CLI的高级过滤功能，获取您感兴趣的字段，且默认表格化输出。

## --output选项字段说明

`--output`选项包含以下字段：

| 字段名 | 描述 | 示例值 |
| :--- | :--- | :--- |
| **cols** | 表格列名。使用`--output`选项时需要以`cols="<column1>,<column2>"`形式确定表格与数据的映射关系。多个列名之间使用逗号`,`隔开。若JSON数据为`object`键值对类型，该字段需要与数据对应键名保持一致。若JSON数据为`array`数组类型，该字段可自定义显示名称，同时您需要手动添加数组元素索引。列名与索引之间使用冒号`:`隔开。 | `cols="InstanceId,Status"` 或 `cols="name:0,type:1"` |
| **rows** | 待过滤数据所在的[JMESPath](http://jmespath.org/)路径。阿里云CLI将通过JMESPath查询语句来指定表格行在JSON结果中的数据来源。 | `rows="Instances.Instance[]"` |
| **num** | 开启行号显示。指定该字段为`true`可开启行号显示。默认值为`false`。 | `num="true"` |

## 过滤示例

### **示例一：过滤根元素字段**

```shell
aliyun ecs DescribeInstances --output cols=RequestId
```

输出结果：

```plaintext
RequestId
---------
2B76ECBD-A296-407E-BE17-7E668A609DDA
```

### **示例二：过滤嵌套字段**

```shell
aliyun ecs DescribeInstances --output cols="InstanceId,Status" rows="Instances.Instance[]"
```

输出结果：

```plaintext
InstanceId             | Status
----------             | ------
i-12345678912345678123 | Stopped
i-abcdefghijklmnopqrst | Running
```

如果需要输出行号，则指定`num=true`：

```plaintext
Num | InstanceId             | Status
--- | ----------             | ------
0   | i-12345678912345678123 | Stopped
1   | i-abcdefghijklmnopqrst | Running
```

### **示例三：过滤数组类型字段**

```shell
aliyun ecs DescribeInstances --output cols="sg1:0,sg2:1" rows="Instances.Instance[].SecurityGroupIds.SecurityGroupId"
```

输出结果：

```plaintext
sg1                     | sg2
---                     | ---
sg-bp11234567891234**** | sg-bp19876543219876****
sg-bp1abcdefghijklm**** | sg-bp1zyxwvutsrqpon****
```
