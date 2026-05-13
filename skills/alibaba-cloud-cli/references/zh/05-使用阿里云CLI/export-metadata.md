# 导出元数据

阿里云 CLI 支持导出命令元数据与 OpenAPI 元数据，本文为您介绍导出元数据的操作步骤。

## **注意事项**

- 云产品的 OpenAPI 元数据是指与 API 相关的所有描述性信息的集合，详情请参见 [OpenAPI 元数据](https://help.aliyun.com/zh/sdk/product-overview/openapi-metadata)。
- 元数据导出功能仅用于调试或开发用途，建议在导出完成后关闭该功能。
- 元数据文件默认保存在 Shell 的工作目录下，如需更改保存路径，请切换工作目录至目标路径。
- 元数据会随阿里云 CLI 版本更新产生变更，建议您升级阿里云 CLI 至最新版本后执行导出操作。

## **操作步骤**

### **步骤一：启用导出功能**

在 Shell 环境中设置临时环境变量 `GENERATE_METADATA`，环境变量值为 `YES`。

- Linux/macOS
  
  ```bash
  export GENERATE_METADATA=YES
  ```
- Windows PowerShell
  
  ```powershell
  $env:GENERATE_METADATA = "YES"
  ```
- Windows CMD
  
  ```shell
  set GENERATE_METADATA=YES
  ```

### **步骤二：导出元数据**

设置环境变量后执行任意阿里云 CLI 命令，命令执行后阿里云 CLI 将开始导出元数据。例如：

```bash
aliyun
```

所有生成的元数据文件都将保存在当前工作目录下的 `cli-metadata` 目录中。

生成元数据文件包含主要子目录和文件：

```plaintext
cli-metadata/
├── metadatas/                   # 阿里云 CLI 支持 OpenAPI 元数据汇总目录
│   ├── products.json            # 产品列表及基本信息
│   └── <product-name>/          # 每个产品对应一个子目录
│       └── <api-name>.json      # 每个 API 接口的详细定义文件
│
├── en-US/                       # 英文版元数据
│   ├── products.json
│   └── <product-name>/
│       ├── <api-name>.json
│       └── version.json
│
├── zh-CN/                       # 中文版元数据
│   ├── products.json
│   └── <product-name>/
│       ├── <api-name>.json
│       └── version.json
│   
├── commands.json                # CLI 命令结构定义文件
└── version                      # 当前使用的阿里云 CLI 版本号
```

### **步骤三：关闭元数据导出功能**

- Linux/macOS
  
  ```bash
  unset GENERATE_METADATA
  ```
- Windows PowerShell
  
  ```powershell
  $env:GENERATE_METADATA = ""
  ```
- Windows CMD
  
  ```shell
  set GENERATE_METADATA=
  ```
