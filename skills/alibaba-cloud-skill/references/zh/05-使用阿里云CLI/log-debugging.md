# 命令日志

当您通过阿里云CLI访问API时，可以打开日志输出功能以打印请求日志。日志可帮助您分析请求及响应内容是否正确。

> **说明**
>
> OSS命令日志功能的开启方式与阿里云CLI不同。如需为OSS命令开启日志功能，请参见OSS命令日志功能。

## 阿里云CLI日志功能

在终端中，可以通过设置环境变量开启阿里云CLI的日志功能。新增环境变量示例如下：

| 变量 | 示例 | 说明 |
| :--- | :--- | :--- |
| **DEBUG** | 变量名：`DEBUG`，变量值：`sdk` | 当变量`DEBUG`的值为`sdk`时，表示开启阿里云CLI的日志功能。如需禁用日志输出，请删除该环境变量。 |

配置环境变量的具体操作，请参见[在Linux、macOS和Windows系统配置环境变量](https://help.aliyun.com/zh/sdk/developer-reference/configure-the-alibaba-cloud-accesskey-environment-variable-on-linux-macos-and-windows-systems)。

### **使用示例**

开启日志功能后，以如下命令为例：

```shell
aliyun ecs DescribeRegions
```

阿里云CLI将在命令执行后显示完整的请求和响应信息，包括HTTP方法、请求头、签名参数、响应状态码等。

## OSS命令日志功能

OSS命令可以使用`--loglevel`选项开启命令日志，并对日志输出级别进行定义。

可选值：

- 默认为空，不进行输出
- `info`：输出提示信息日志
- `debug`：输出详细日志信息

日志将会输出到文件，文件路径将在终端显示，例如以下命令：

```plaintext
aliyun oss ls --loglevel info
log file is /Users/user/Documents/ossutil.log
```
