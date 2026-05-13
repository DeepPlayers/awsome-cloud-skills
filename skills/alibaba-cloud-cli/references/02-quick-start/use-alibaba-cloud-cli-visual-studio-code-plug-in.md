# Using Alibaba Cloud CLI Visual Studio Code Plugin

This article takes calling the `DescribeInstances` interface of Elastic Compute Service (ECS) in VS Code editor as an example to introduce the operation steps of using Alibaba Cloud CLI Visual Studio Code plugin in VS Code editor.

## **Prerequisites**

1. To use Alibaba Cloud CLI plugin in VS Code editor, you need to install Alibaba Cloud CLI and configure identity credentials first. For specific installation and configuration operations, see [Calling OpenAPI with Alibaba Cloud CLI](https://help.aliyun.com/zh/cli/quickly-start-using-alibaba-cloud-cli).
2. This example requires granting the RAM user read-only access to ECS permission policy `AliyunECSReadOnlyAccess`.

## **Overview**

Using Alibaba Cloud CLI plugin in VS Code editor to call ECS `DescribeInstances` interface involves the following steps:

1. Install Plugin: Install `Alibaba Cloud CLI Tools` plugin in VS Code editor.
2. Edit Command: Create a file with `.aliyun` suffix in VS Code editor, and edit the `DescribeInstances` command in the file.
3. Execute Command: Select the command to execute and run it in editor or terminal.

## **Step 1: Install Alibaba Cloud CLI Plugin**

### Download and Install from Plugin Market

1. In the VS Code editor left (Activity Bar) navigation bar, click the Extensions icon.
2. Enter `Alibaba Cloud CLI Tools` in the search box and click **Install**.

### Download via Browser Redirect

1. Visit the official [Marketplace](https://marketplace.visualstudio.com/items?itemName=alibabacloud-openapi.aliyuncli) through browser and click **Install**, which will automatically redirect to VS Code editor extensions page.
2. In the extensions page, click **Install**.

After installation, the Alibaba Cloud CLI plugin icon and current configuration will be displayed in the bottom status bar. Click the icon to switch identity credential configuration.

## **Step 2: Edit Command**

1. Click **File** > **New File...** in VS Code editor, enter the file name `example.aliyun` to create a new file with `.aliyun` suffix.
   
   **Note**
   
   When coding in `.aliyun` files, Alibaba Cloud CLI Visual Studio Code plugin will provide command completion hints, which can greatly improve command line writing efficiency.
   
   - **Command-level auto-completion hints**
   - **Method-level auto-completion hints**
   - **Parameter-level auto-completion hints**

2. Enter the following command according to the completion hints and set command parameters as needed.
   
   ```shell
   aliyun ecs DescribeInstances --InstanceIds "['i-bp118piqciobxjkb****']"
   ```

## **Step 3: Execute Command**

After writing the command, you can choose to execute the CLI command in terminal or editor.

### Execute Full Command in Terminal

Click **run** on the top left of the command to be executed to invoke the terminal and execute the full command.

### Execute Selected Command in Terminal

1. Long press the left mouse button to select the command part to be executed. Right-click on the selected command to bring up the context menu.
2. Click **Alibaba Cloud CLI** > **Run Line in Terminal** to invoke the terminal and execute the selected command part.

### Execute Selected Command in Editor

1. Long press the left mouse button to select the command part to be executed. Right-click on the selected command to bring up the context menu.
2. Click **Alibaba Cloud CLI** > **Run Line in Editor** to execute the selected command part in VS Code editor.
