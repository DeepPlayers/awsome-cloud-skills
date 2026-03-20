# Calling OpenAPI with Alibaba Cloud CLI

This article will introduce you to the specific operation process of using Alibaba Cloud CLI to call OpenAPI, including installation, credential configuration, command generation and invocation steps.

## **Overview**

Using Alibaba Cloud CLI to call OpenAPI involves four steps:

1. **Install Alibaba Cloud CLI**: Select and install the appropriate version based on your device's operating system.
2. **Configure Alibaba Cloud CLI**: Configure identity credentials in Alibaba Cloud CLI, mainly including AccessKey information and region information. Alibaba Cloud CLI will use the credentials in the configuration to call OpenAPI.
3. **Generate CLI Commands**: Enter parameters in the OpenAPI Portal to generate CLI command examples with parameters, copy and paste them into a Shell tool to run.
4. **Call API**: Enter commands in the Shell tool and use command options as needed, run the command to call the corresponding OpenAPI.

## **Prerequisites**

* Before using Alibaba Cloud CLI, if you don't have an account yet, please visit [Alibaba Cloud Official Website](https://www.aliyun.com/) to register an Alibaba Cloud account (main account), and it is recommended that you create a RAM user specifically for API access. For specific operations, see [Create a RAM User](https://help.aliyun.com/zh/ram/user-guide/create-a-ram-user).
* Some products require activating cloud product services before calling their OpenAPI. You can activate the cloud product services you need in the following two ways, taking SMS service as an example:
    * Visit the [Activation Assistant](https://api.aliyun.com/user_center/open) to activate cloud product services with one click. Search for SMS service, select SMS service, and click **Activate Now**.
    * Visit each cloud product console to activate cloud product services. For example, click **Activate** in the [SMS Service Console](https://www.aliyun.com/product/sms).
* Before using Alibaba Cloud CLI, you need to confirm whether the cloud product you want to integrate supports Alibaba Cloud CLI. The confirmation methods are as follows:
    * Check the cloud product documentation center, and view Alibaba Cloud CLI support status in **Developer Reference** > **Integration Overview**.
    * Execute the `aliyun --help` command in [Cloud Shell](https://shell.aliyun.com/), Alibaba Cloud's online service, to get the list of products supported by Alibaba Cloud CLI.

## **Step 1: Install Alibaba Cloud CLI**

Before using Alibaba Cloud CLI, you need to install it first. Alibaba Cloud CLI provides installation services for Windows, Linux, and macOS operating systems. Please select the corresponding installation service based on your device's operating system.

* Windows: [Install Alibaba Cloud CLI on Windows](https://help.aliyun.com/zh/cli/install-cli-on-windows).
* Linux: [Install Alibaba Cloud CLI on Linux](https://help.aliyun.com/zh/cli/install-cli-on-linux).
* macOS: [Install Alibaba Cloud CLI on macOS](https://help.aliyun.com/zh/cli/install-cli-on-macos).

You can also use [Cloud Shell](https://shell.aliyun.com/), the cloud command line provided by Alibaba Cloud, to debug Alibaba Cloud CLI commands. For more information about cloud command line, see [What is Cloud Shell](https://help.aliyun.com/zh/cloud-shell/what-is-the-cloud-command-line).

## Step 2: Configure Alibaba Cloud CLI

> **Important**
>
> To ensure account security, it is recommended that you create a RAM user specifically for API access and obtain identity credentials. For more security recommendations on credentials, see [Credential Security Solution](https://help.aliyun.com/zh/openapi/accesskey-security-solution).

Before using Alibaba Cloud CLI, you need to configure identity credentials, region ID, and other information in Alibaba Cloud CLI. Alibaba Cloud CLI supports multiple identity credentials. For details, see [Identity Credential Types](https://help.aliyun.com/zh/cli/configure-credentials#30ab0f9c3eovm). This article uses AK type credentials as an example. The specific operation steps are as follows:

1. You need to create a RAM user and grant permissions to manage corresponding products as needed. For specific operations, see [Create a RAM User](https://help.aliyun.com/zh/ram/create-a-ram-user-1#task-187540) and [Grant Permissions to RAM User](https://help.aliyun.com/zh/ram/user-guide/grant-permissions-to-the-ram-user).
2. After creating and authorizing the RAM user, you need to create the corresponding AccessKey for the RAM user and record the `AccessKey ID` and `AccessKey Secret` for subsequent identity credential configuration. For specific operations, see [Create AccessKey](https://help.aliyun.com/zh/ram/user-guide/create-an-accesskey-pair#title-ebf-nrl-l0i).
3. You need to obtain and record the available region ID for subsequent identity credential configuration. Alibaba Cloud CLI will use the region you specify to initiate API calls. For available regions, see [Regions and Availability Zones List](https://help.aliyun.com/document_detail/40654.html#title-u71-7kb-w8p).
    
    > **Note**
    >
    > When using Alibaba Cloud CLI, you can use the `--region` option to specify a region to initiate command calls. This option will ignore the region information in the default identity credential configuration and environment variable settings when used. For details, see [API Command Available Options](https://help.aliyun.com/zh/cli/command-line-options).

4. Use the RAM user's AccessKey to configure AK type credentials, and name the configuration file `AkProfile`. For specific operations, see [Configuration Example](https://help.aliyun.com/zh/cli/configure-credentials#237984d36ci83).

## **Step 3: Generate CLI Commands**

> **Note**
>
> [OpenAPI Portal](https://api.aliyun.com/) can generate all Alibaba Cloud CLI commands online. It is recommended that you use this method to get the command examples you need. If you need more detailed operation steps, see [Generate Commands](https://help.aliyun.com/zh/cli/sample-commands#fc9b6069afmg0).

In the API debugging interface, you can search for the API you need to use in the **search box on the left**. Fill in the parameters in **Parameter Configuration** according to the API documentation information, and click the **CLI Example** tab on the right side of **Parameter Configuration** to generate command examples with parameters.

* Click the **Run Command** button to invoke [Cloud Shell](https://help.aliyun.com/zh/cloud-shell/what-is-the-cloud-command-line) and quickly complete command debugging.
* Click the **Copy** button to copy the CLI example to the clipboard, which can be pasted into a local Shell tool to run.
    * When copying CLI examples to a local Shell tool for debugging, please pay attention to the parameter format. For detailed information about Alibaba Cloud CLI command parameter usage format, see [Parameter Format Overview](https://help.aliyun.com/zh/cli/parameter-format-overview).
    * The OpenAPI Portal generated example will add the `--region` option by default. When copying the command to local invocation, Alibaba Cloud CLI will ignore the region information in the default identity credential configuration and environment variable settings, and prioritize using the specified region to call the command. You can delete or keep this option as needed.

## **Step 4: Call API**

### **Command Structure**

The general command line structure of Alibaba Cloud CLI is as follows. For more details, see [Command Structure](https://help.aliyun.com/zh/cli/sample-commands#1640a5c2c077i).

```shell
aliyun <command> <subcommand> [options and parameters]
```

### **Common Command Options**

In Alibaba Cloud CLI, you can use command line options as needed to modify the default behavior of commands or provide additional functionality for commands. Common command line options are as follows:

* `--profile <profileName>`: After using the `--profile` option and specifying a valid configuration name `profileName`, Alibaba Cloud CLI will ignore the default identity credential configuration and environment variable settings, and prioritize using the specified configuration for command calls.
* `--help`: Type `--help` at the command level where you need to get help, and you can get help information for that command. For more details, see [Get Help Information](https://help.aliyun.com/zh/cli/use-the-help-command).

For more detailed information, see [API Command Available Options](https://help.aliyun.com/zh/cli/command-line-options).

### **Invoke Commands**

After generating commands, you can copy the command examples and paste them into a Shell tool to run the commands. Taking the following command as an example, call the `CreateInstance` command in Elastic Compute Service ECS to create a pay-as-you-go ECS instance.

```shell
aliyun ecs CreateInstance
    --InstanceName myvm1
    --ImageId centos_7_03_64_40G_alibase_20170625.vhd
    --InstanceType ecs.n4.small
    --SecurityGroupId sg-xxxxxx123
    --VSwitchId vsw-xxxxxx456
    --InternetChargeType PayByTraffic
    --Password xxx
```

For more command invocation details, see [Invocation Examples](https://help.aliyun.com/zh/cli/sample-commands#e0a41cfdf4zop), or **CLI Integration Examples** under each cloud product documentation center.
