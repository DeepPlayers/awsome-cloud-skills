# Nano编辑器

Nano 是一个简单易用的文本编辑器，具有界面简洁和操作直观的优点。本教程介绍 Nano 编辑器的部分常用操作和常用快捷键。

## **安装情况**

- 本文档以**Nano 2.9.3**版本为例进行介绍。
- 大多数 Linux 发行版中通常已预装 Nano 编辑器，在终端中执行`nano --version`命令可查看 Nano 版本信息。若您的系统未安装 Nano 编辑器，则需要手动安装。具体操作，请参见 [Nano 官网文档](https://www.nano-editor.org/dist/latest/faq.html#2)。
- 云命令行（Cloud Shell）是阿里云提供的网页版命令行工具，您可以在云命令行中使用预安装的 Nano 编辑器完成文本编辑任务。更多信息，请参见 [什么是云命令行](https://help.aliyun.com/zh/cloud-shell/what-is-the-cloud-command-line)。

## **注意事项**

- 快捷键示例说明：
  - `^<chr>`：表示在按住`CONTROL`键后，键入字符`<chr>`。
  - `M-<chr>`：表示在按住`META`、`EDIT`或`ALT`键后，键入字符`<chr>`。
- 部分快捷键可能与其他软件或系统快捷键产生冲突。当您遇到快捷键冲突时，可使用`Esc`键替换：
  - 双击`Esc`键后，键入字符`<chr>`。等效于`^<chr>`。
  - 单击`Esc`键后，键入字符`<chr>`。等效于`M-<chr>`。

## **常用操作**

### **启动和退出**

- 启动 Nano：执行`nano`命令
- 退出 Nano：使用快捷键`^X`

### **文件管理**

- 打开或创建文件：
  ```bash
  nano fileName
  nano /etc/fileName
  ```
- 保存文件：快捷键`^S`
- 另存为文件：快捷键`^O`后输入文件路径

### **移动光标**

- 向左移动：`^B`/`right`
- 向右移动：`^F`/`left`
- 向上移动：`^P`/`up`
- 向下移动：`^N`/`down`
- 跳转行数：`^_`后输入目标行号
- 向前翻页：`^Y`
- 向后翻页：`^V`

### **文本编辑**

- 删除文本：`退格键`删除光标左侧字符，`^D`删除光标右侧字符
- 选中文本：`M-A`进入选择模式
- 复制文本：`M-6`
- 剪切文本：`^K`
- 粘贴文本：`^U`
- 查找文本：`^W`
- 替换文本：`^\`或`^R`
- 撤销：`M-U`
- 重做：`M-E`

### **修改配置**

您可以通过编辑`~/.nanorc`文件自定义 Nano 编辑器配置：

- 开启行号显示：插入文本`set linenumbers`
- 开启自动缩进：插入文本`set autoindent`
- 更多可用配置项，请参见 [Nano 官网文档](https://www.nano-editor.org/dist/v2.1/nanorc.5.html)。

## **示例：开启行号显示**

```bash
nano ~/.nanorc
```

输入文本`set linenumbers`，使用`^S`保存，`^X`退出。
