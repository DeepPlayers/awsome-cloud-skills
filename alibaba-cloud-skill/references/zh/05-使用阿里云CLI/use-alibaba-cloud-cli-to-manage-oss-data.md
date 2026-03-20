# 使用阿里云CLI管理OSS资源

更新时间：2025-10-11 17:47:41

阿里云CLI集成了对象存储OSS（Object Storage Service）的命令行工具ossutil，您可以在统一的CLI环境中执行OSS资源管理操作。本文为您介绍基于阿里云CLI使用ossutil的相关操作。

## 使用准备

ossutil是阿里云官方提供的OSS命令行工具，支持通过Windows、Linux和macOS系统以命令行方式管理OSS数据。目前，ossutil以插件形式深度集成至阿里云CLI，您可以通过阿里云CLI直接调用ossutil完成对存储空间（Bucket）、文件（Object）等核心资源的管理操作。

自阿里云CLI v3.0.304版本起，深度集成ossutil 2.0，向您提供更稳定、更高效的使用体验。当前阿里云CLI同时兼容ossutil 1.0与ossutil 2.0两个版本，旧版本命令仍可正常使用。建议您将阿里云CLI升级至最新版本，以获得ossutil 2.0的全部新特性与性能提升。

阿里云CLI中ossutil 1.0和ossutil 2.0主要差异如下：

### 命令调用差异

新版本命令由oss升级为ossutil，便于区分功能模块并支持更多高级特性。

| 版本 | 命令格式 |
|-----|---------|
| ossutil 1.0（旧版本） | aliyun oss |
| ossutil 2.0（新版本） | aliyun ossutil |

**说明**

新版本命令由oss变更为ossutil，如需使用ossutil 2.0，请在脚本或自动化任务中注意更新命令。

### 命令差异

**选项差异**

新版本说明：在新版本的阿里云CLI中，ossutil 2.0支持自动检查并升级至最新版本，您无需手动执行update命令。

ossutil 2.0版本与阿里云CLI主程序版本相互独立，更新不受CLI版本绑定限制。

## 命令结构

阿里云CLI中ossutil 2.0命令格式如下：

```
aliyun ossutil command [argument] [flags]
aliyun ossutil command subcommond [argument] [flags]
aliyun ossutil topic
```

- argument：参数，为字符串。
- flags：选项，支持短名字风格-o[=value]/ -o [value]和长名字风格--options[=value]/--options[value]。如果多次指定某个排它参数，则仅最后一个值生效。

命令示例如下：

- 命令：`aliyun ossutil cat oss://bucket/object`
- 多级命令：`aliyun ossutil api get-bucket-cors --bucket bucketexample`
- 帮助主题：`aliyun ossutil filter`

## 命令列表

ossutil 2.0提供了高级命令、API级命令、辅助命令等三类命令。

### 高级命令

用于常用的对对象或者存储空间的操作场景，例如存储空间创建、删除、数据拷贝、对象属性修改等。

| 命令名 | 含义 |
|-------|------|
| mb | 创建存储空间 |
| rb | 删除存储空间 |
| du | 获取存储或者指定前缀所占的存储空间大小 |
| stat | 显示存储空间或者对象的描述信息 |
| mkdir | 创建一个名字有后缀字符/的对象 |
| append | 将内容上传到追加类型的对象末尾 |
| cat | 将对象内容连接到标准输出 |
| ls | 列举存储空间或者对象 |
| cp | 上传、下载或拷贝对象 |
| rm | 删除存储空间里的对象 |
| set-props | 设置对象的属性 |
| presign | 生成对象的预签名URL |
| restore | 恢复冷冻状态的对象为可读状态 |
| revert | 将对象恢复成指定的版本 |
| sync | 将本地文件目录或者对象从源端同步到目的端 |
| hash | 计算文件/对象的哈希值 |

### API级命令

提供了API操作的直接访问，支持该接口的配置参数。

| 命令名 | 含义 |
|-------|------|
| put-bucket-acl | 设置、修改Bucket的访问权限 |
| get-bucket-acl | 获取访问权限 |
| put-bucket-cors | 设置跨域资源共享规则 |
| get-bucket-cors | 获取跨域资源共享规则 |
| delete-bucket-cors | 删除跨域资源共享规则 |

### 辅助命令

例如配置文件的配置、额外的帮助主题等。

| 命令名 | 含义 |
|-------|------|
| help | 获取帮助信息 |
| config | 创建配置文件用以存储配置项和访问凭证 |
| version | 显示版本信息 |
| probe | 探测命令 |

## 命令行选项

ossutil 2.0中的命令行选项分为全局命令行选项和局部命令行选项。全局命令行选项适用于所有命令，局部命令行选项仅适用于特定的命令。命令行选项的优先级最高，可以覆盖配置文件设置或环境变量设置的参数。

- 查询命令行选项
- 使用命令行选项
- 支持的全局命令行选项

### 命令选项类型

| 选项类型 | 选项 | 说明 |
|---------|------|------|
| 字符串 | --option string | 字符串参数可以包含ASCII字符集中的字母及数字字符、符号和空格。如果字符串中包含空格，需要使用引号包括。例如：--acl private。 |
| 布尔值 | --option | 打开或关闭某一选项。例如：--dry-run。 |
| 整数 | --option Int | 无符号整数。例如：--read-timeout 10。 |
| 时间戳 | --option Time | ISO 8601格式，即DateTime或Date。例如：--max-mtime 2006-01-02T15:04:05。 |
| 字节单位后缀 | --option SizeSuffix | 默认单位是字节（B），也可以使用单位后缀形式，支持的单位后缀为：K（KiB）=1024字节、M（MiB）、G（GiB）、G（GiB）、T（TiB）、P（PiB）、E（EiB）。例如：最小size为1024字节 --min-size 1024 或 --min-size 1K |
| 时间单位后缀 | --option Duration | 时间单位，默认单位是秒。支持的单位后缀为：ms 毫秒，s 秒，m 分钟，h 小时，d 天，w 星期，M 月，y 年。支持小数。例如：1.5天 --min-age 1.5d |
| 字符串列表 | --option strings | 支持单个或者多个同名选项，支持以逗号（,）分隔的多个值。支持多选项输入的单值。例如：--metadata user=jack,email=ja**@test.com --metadata address=china |
| 字符串数组 | --option stringArray | 支持单个或者多个同名选项，只支持多选项输入的单值。例如：--include *.jpg --include *.txt。 |

### 从非命令行中加载数据

一般情况下，参数的值都放在命令行里，当参数值比较复杂时，需要从文件加载参数值；当需要串联多个命令操作时，需要标准输中加载参数值。所以，对需要支持多种加载参数值的参数，做了如下约定：

- 以file://开始的，表示从文件路径中加载。
- 当参数值为-时，表示从标准输入中加载。

例如，设置存储空间的跨域设置，以JSON参数格式为例，通过文件方式加载跨域参数。cors-configuration.json文件如下：

```json
{
  "CORSRule": {
    "AllowedOrigin": ["www.aliyun.com"],
    "AllowedMethod": ["PUT","GET"],
    "MaxAgeSeconds": 10000
  }
}
```

```bash
aliyun ossutil api put-bucket-cors --bucket examplebucket --cors-configuration file://cors-configuration.json
```

通过选项参数值加载跨域参数，cors-configuration.json的紧凑形式如下：

```json
{"CORSRule":{"AllowedOrigin":["www.aliyun.com"],"AllowedMethod":["PUT","GET"],"MaxAgeSeconds":10000}}
```

```bash
aliyun ossutil api put-bucket-cors --bucket examplebucket --cors-configuration "{\"CORSRule\":{\"AllowedOrigin\":[\"www.aliyun.com\"],\"AllowedMethod\":[\"PUT\",\"GET\"],\"MaxAgeSeconds\":10000}}"
```

从标准输入加载参数的示例如下：

```bash
cat cors-configuration.json | aliyun ossutil api put-bucket-cors --bucket examplebucket --cors-configuration -
```

## 控制命令输出

### 输出格式

对ossutil api下的子命令，以及du、stat、ls命令，支持通过--output-format参数调整其输出格式，当前支持的格式如下：

| 格式名称 | 说明 |
|---------|------|
| raw | 以原始方式输出，即服务端返回什么内容，则输出什么内容。 |
| json | 输出采用JSON字符串的格式。 |
| yaml | 输出采用YAML字符串的格式。 |

例如：以get-bucket-cors为例，原始内容如下：

```bash
aliyun ossutil api get-bucket-cors --bucket bucketexample
```

输出：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration>
  <CORSRule>
    <AllowedOrigin>www.aliyun.com</AllowedOrigin>
    <AllowedMethod>PUT</AllowedMethod>
    <AllowedMethod>GET</AllowedMethod>
    <MaxAgeSeconds>10000</MaxAgeSeconds>
  </CORSRule>
  <ResponseVary>false</ResponseVary>
</CORSConfiguration>
```

转成JSON如下：

```bash
aliyun ossutil api get-bucket-cors --bucket bucketexample --output-format json
```

输出：

```json
{
  "CORSRule": {
    "AllowedMethod": [
      "PUT",
      "GET"
    ],
    "AllowedOrigin": "www.aliyun.com",
    "MaxAgeSeconds": "10000"
  },
  "ResponseVary": "false"
}
```

### 筛选输出

ossutil提供了基于JSON的内置客户端筛选功能，通过--output-query value选项使用。

**说明**

- 该选项仅支持ossutil api下的子命令。
- 该功能基于JMESPath语法，当使用该功能时，会把返回的内容转成JSON，然后再使用JMESPath进行筛查，最后按照指定的输出格式输出。有关JMESPath语法的说明，请参见JMESPath Specification。

例如：以get-bucket-cors为例，只输出AllowedMethod内容，示例如下：

```bash
aliyun ossutil api get-bucket-cors --bucket bucketexample --output-query CORSRule.AllowedMethod --output-format json
```

输出：

```json
[
  "PUT",
  "GET"
]
```

### 友好显示

对于高级命令（du、stat），提供了--human-readable选项，对字节、数量数据，提供了以人类可读方式输出信息。即字节数据转成Ki|Mi|Gi|Ti|Pi后缀格式（1024 base），数量数据转成k|m|g|t|p后缀格式(1000 base)。

例如：原始模式

```bash
aliyun ossutil stat oss://bucketexample
```

输出：

```
ACL                         : private
AccessMonitor               : Disabled
ArchiveObjectCount          : 2
ArchiveRealStorage          : 10
ArchiveStorage              : 131072
...
StandardObjectCount         : 119212
StandardStorage             : 66756852803
Storage                     : 66756852813
StorageClass                : Standard
TransferAcceleration        : Disabled
```

友好模式

```bash
aliyun ossutil stat oss://bucketexample --human-readable
```

输出：

```
ACL                         : private
AccessMonitor               : Disabled
ArchiveObjectCount          : 2
ArchiveRealStorage          : 10
ArchiveStorage              : 131.072k
...
StandardObjectCount         : 119.212k
StandardStorage             : 66.757G
Storage                     : 66.757G
StorageClass                : Standard
TransferAcceleration        : Disabled
```

## 命令返回码

通过进程等方式调用ossutil时，无法实时查看回显信息。ossutil支持在进程运行结束后，根据不同的运行结果生成不同的返回码，具体的返回码及其含如下。您可以通过以下方式获取最近一次运行结果的返回码，然后根据返回码分析并处理问题。

Linux/Windows/macOS执行命令获取返回码：`echo $?`

| 返回码 | 含义 |
|-------|------|
| 0 | 命令操作成功，发送到服务端的请求执行正常，服务端返回200响应。 |
| 1 | 参数错误，例如缺少必需的子命令或参数，或使用了未知的命令或参数。 |
| 2 | 该命令已成功解析，并已对指定服务发出了请求，但该服务返回了错误（非2xx响应）。 |
| 3 | 调用OSS GO SDK时，遇到的非服务端错误。 |
| 4 | 批量操作时，例如cp、rm部分请求发生了错误。 |
| 5 | 中断错误。命令执行过程中，您通过ctrl+c取消了某个命令。 |

## 操作示例

**示例1**：上传本地文件upload.rar到bucket存储空间中，上传速度为20 MB/s，默认单位为字节每秒（B/s）。

```bash
aliyun ossutil cp D:\upload.rar oss://bucket/ --bandwidth-limit 20971520
```

**示例2**：上传本地文件file.rar到bucket存储空间中，上传速度为50 MB/s，指定单位为兆字节每秒（MB/s）。

```bash
aliyun ossutil cp D:\file.rar oss://bucket/dir -r --bandwidth-limit 50M
```

**示例3**：将bucket存储空间中的download.rar文件下载到当前目录，并将下载速度限制为20 MB/s。

```bash
aliyun ossutil cp oss://bucket/download.rar . --bandwidth-limit 20971520
```

## 常见问题

如您在使用ossutil时发现异常，可参考以下文档进行错误排查。

- ossutil 1.0常见问题
- ossutil 2.0常见问题
