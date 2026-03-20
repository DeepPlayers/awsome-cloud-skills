# What is Alibaba Cloud CLI

Updated: 2025-07-01 16:21:32

This article aims to help you quickly understand the concepts and core features of Alibaba Cloud CLI. It also briefly explains the differences between Alibaba Cloud CLI and product-specific CLIs, providing you with a clear reference for tool selection.

## Prerequisites

Before reading this article, you may need to understand the following concepts:

- [What is API?](https://www.aliyun.com/getting-started/what-is/what-is-api)
- [What is SDK?](https://www.aliyun.com/getting-started/what-is/what-is-sdk)

## What is CLI?

CLI (Command Line Interface) is a user interface for interacting with computers through text commands. Users can directly input commands in the command line interface to perform specific operations without relying on a graphical user interface (GUI). CLI is commonly used in system administration, software development, and network configuration. In the computing field, CLI is widely used across various operating systems and software tools.

## What is Alibaba Cloud CLI?

Alibaba Cloud CLI is a general-purpose command line tool built on [OpenAPI](https://help.aliyun.com/zh/openapi/what-is-openapi). You can use Alibaba Cloud CLI to perform daily operations and maintenance tasks such as creating, deleting, modifying, and querying Alibaba Cloud resources through the command line interface.

- **Linux Shell**: On Linux or macOS systems, use common Shell programs (such as [`bash`](https://www.gnu.org/software/bash/), [`zsh`](http://www.zsh.org/), and [`tcsh`](https://www.tcsh.org/)) to run commands.
- **Windows Command Line**: On Windows systems, you can use Command Prompt or PowerShell to run commands.
- **Remote Operations**: Use [Alibaba Cloud CloudShell](https://help.aliyun.com/zh/cloud-shell/using-the-cloud-command-line) to run commands, or use remote terminals (such as SSH) to run commands through Alibaba Cloud ECS instances.

Additionally, you can develop Shell scripts based on Alibaba Cloud CLI for automated management and maintenance of Alibaba Cloud products. Before using it, please ensure that you have activated the cloud products you want to use and understand how to use their OpenAPI.

If you encounter any issues during use, you can submit feedback through tickets or [GitHub Issues](https://github.com/aliyun/aliyun-cli/issues/new) to help us improve the Alibaba Cloud CLI experience together.

## What is the difference between Alibaba Cloud CLI and product-specific CLIs (such as Log Service CLI)?

As a general-purpose command line tool, Alibaba Cloud CLI differs from product-specific CLIs mainly in terms of feature coverage and applicable scenarios.

- **Alibaba Cloud CLI** supports over 100 Alibaba Cloud products including [ECS](https://help.aliyun.com/zh/ecs/user-guide/what-is-ecs), [RDS](https://help.aliyun.com/zh/rds/product-overview/what-is-apsaradb-rds-what-is-apsaradb-rds), [SLB](https://help.aliyun.com/zh/slb/product-overview/slb-overview), and more. Users can manage and operate different resources and services across accounts and products through a unified command set. It is suitable for users who need to manage and operate across multiple products, providing basic but widely applicable features, ideal for scenarios requiring flexible handling of multiple services.

- **Product-specific CLIs** are command line tools designed for specific Alibaba Cloud products, such as [Log Service CLI](https://help.aliyun.com/zh/sls/developer-reference/overview-of-log-service-cli). These tools provide more specialized and customized features for specific products, focusing on meeting the complex scenario requirements of corresponding products. They are more suitable for users with in-depth requirements for a specific product, providing more specialized and customized feature support.

## Product Features

### Cloud Resource Management

Alibaba Cloud CLI is a command line management tool built on [Alibaba Cloud OpenAPI](https://help.aliyun.com/zh/openapi/what-is-openapi). You can directly call the OpenAPI of each cloud product through simple command line methods without logging into the console, efficiently managing and maintaining your cloud resources.

### Multi-product Integration

Alibaba Cloud CLI integrates features of 100+ Alibaba Cloud products including [ECS](https://help.aliyun.com/zh/ecs/user-guide/what-is-ecs), [RDS](https://help.aliyun.com/zh/rds/product-overview/what-is-apsaradb-rds-what-is-apsaradb-rds), [SLB](https://help.aliyun.com/zh/slb/product-overview/slb-overview), and more. You can complete configuration and management operations for multiple cloud products in the same command line interface, achieving a unified and convenient multi-product integration experience.

### Multi-credential Support

Alibaba Cloud CLI supports saving and managing multiple sets of access credential configurations. You can save multiple independent access keys and permission policies into different configurations, and flexibly switch between them when calling OpenAPI, meeting scenario requirements such as permission layering and environment isolation (development, testing, production), achieving safer and more efficient cloud resource management.

### Rate Limiting Backoff

Alibaba Cloud CLI automatically enables the [graceful backoff mechanism based on rate limiting policy](https://help.aliyun.com/zh/sdk/developer-reference/advanced-backoff-mechanism-based-on-the-throttling-policy), significantly reducing unnecessary retry attempts, effectively lowering system resource consumption and improving overall operational efficiency.

### Command Auto-completion

Alibaba Cloud CLI provides command auto-completion functionality for Linux and macOS environments, helping you quickly enter command parameters without memorizing complex syntax. Currently, only [`bash`](https://www.gnu.org/software/bash/) and [`zsh`](http://www.zsh.org/) Shell environments are supported.

### Multiple Output Formats

To facilitate viewing results or working with other programs, Alibaba Cloud CLI supports two output formats: JSON and table. You can freely choose according to your actual needs.

### Online Help

Alibaba Cloud CLI provides detailed online help functionality. Through the `help` command, you can query the currently available operations and their supported parameter information at any time, easily mastering the CLI usage method.

### Multi-system Support

Alibaba Cloud CLI can be installed and run on mainstream operating system platforms including Windows, macOS, and Linux, meeting diverse usage environment requirements.

## Related Documentation

For more information about Alibaba Cloud CLI and Alibaba Cloud OpenAPI, please refer to:

- [GitHub aliyun-cli Repository](https://github.com/aliyun/aliyun-cli)
- [OpenAPI Portal](https://api.aliyun.com/)
- [Alibaba Cloud SDK](https://help.aliyun.com/zh/sdk/product-overview/alibaba-cloud-sdk)
