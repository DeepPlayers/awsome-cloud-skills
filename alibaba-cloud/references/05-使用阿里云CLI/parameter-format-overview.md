# 参数格式

本文介绍使用阿里云CLI时不同数据类型参数需要遵循的格式要求。

## **参数格式要求**

**说明**

阿里云CLI支持在OpenAPI门户中自动生成CLI示例。具体操作，请参见[生成并调用命令](https://help.aliyun.com/zh/cli/sample-commands)。

在OpenAPI门户中自动生成的CLI示例默认采用Linux适用参数格式，若您需要在其他环境下执行CLI命令，请根据实际情况修正参数格式。

### **参数名大小写**

由于OpenAPI参数名严格区分大小写，因此阿里云CLI的参数名输入同样严格区分大小写。

### **参数值大小写**

部分参数值不区分大小写。但为确保书写规范的一致性，建议您严格区分参数值的大小写。

### **Integer类型**

在OpenAPI文档中标注为 `Integer` 类型的参数，可以直接传入。

```shell
aliyun ecs DescribeImages --ImageName Example_Image --Pagesize 10
```

### **String类型**

在OpenAPI文档中标注为 `String` 类型的参数，如果参数值中没有包含特殊字符（如 `$`、`` ` ``、`\`、空格等），可直接传入。否则需要用单引号 `''` 或双引号 `""` 包含后再传入。

- **无特殊字符：**
  
  ```shell
  aliyun ecs DescribeImages --ImageName Example_Image
  ```

- **有特殊字符：**
  
  - Windows命令提示符：
    
    ```shell
    aliyun ecs DescribeImages --ImageName "Example Image"
    ```
  - Linux/macOS/Windows PowerShell：
    
    ```shell
    aliyun ecs DescribeImages --ImageName 'Example Image'
    ```

- **ROA风格API的--body选项特殊情况：**
  
  - Windows命令提示符/Linux/macOS：
    
    ```shell
    aliyun cs PUT /clusters/<ClusterId>/nodepools/<NodepoolId> --body "{\"nodepool_info\":{\"name\":\"default-nodepool\",\"resource_group_id\":\"rg-acfmyvw****\"}}"
    ```
  - Windows PowerShell：
    
    ```shell
    aliyun cs PUT /clusters/<ClusterId>/nodepools/<NodepoolId> --body '{\"nodepool_info\":{\"name\":\"default-nodepool\",\"resource_group_id\":\"rg-acfmyvw****\"}}'
    ```

### **String类型字符串列表**

- **Windows命令提示符：**
  
  ```shell
  aliyun ecs DescribeImages --ImageId "m-23e0o****,m-23wae****"
  ```

- **Linux/macOS/Windows PowerShell：**
  
  ```shell
  aliyun ecs DescribeImages --ImageId 'm-23e0o****,m-23wae****'
  ```

### **String类型JSON数组**

- **Windows：**
  
  ```shell
  aliyun ecs DescribeDisks --DiskIds "['d-23rss****','d-23vsi****','d-23sfq****']"
  ```

- **Linux/macOS：**
  
  ```shell
  aliyun ecs DescribeDisks --DiskIds '["d-23rss****","d-23vsi****","d-23sfq****"]'
  ```

### **String类型JSON数组列表**

- **Windows：**
  
  ```shell
  aliyun slb AddBackendServers --LoadBalancerId 15157b19f18-cn-hangzhou-dg**** --BackendServers "[{'ServerId':'i-23g8a****'},{'ServerId':'i-23bb0****'}]"
  ```

- **Linux/macOS：**
  
  ```shell
  aliyun slb AddBackendServers --LoadBalancerId 15157b19f18-cn-hangzhou-dg**** --BackendServers '[{"ServerId":"i-23g8a****"},{"ServerId":"i-23bb0****"}]'
  ```

### **String类型日期**

OpenAPI文档中标注为 `String` 类型的参数，如果要求参数值是一个按照ISO8601标准表示的UTC时间，需要将时间按 `YYYY-MM-DDThh:mm:ssZ` 格式传入。

```shell
aliyun ecs DescribeInstanceMonitorData --InstanceId i-94ola4btx**** --StartTime 2015-11-28T15:00:00Z --EndTime 2015-11-28T18:00:00Z
```

### **特殊字符**

若您输入的参数值在使用引号包含之后，参数中的特殊字符在命令执行过程中仍出现解析错误。您可尝试将参数格式调整为 `key=value` 的格式，以确保命令正确执行。

**示例**

将 `--PortRange -1/-1` 修改为 `--PortRange=-1/-1`：

```shell
aliyun ecs AuthorizeSecurityGroup --SecurityGroupId 'sg-bp67acfmxazb4p****' --Permissions.1.PortRange=-1/-1 --method POST --force
```
