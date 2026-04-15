# Alibaba Cloud CLI Skill

完整的阿里云 CLI 操作 SOP，提供常见云资源管理的标准化工作流程。

## 概述

本技能为 AI 编程助手提供完整的阿里云 CLI 操作指南，包括安装配置、ECS 管理、OSS 操作等标准化工作流程。

## 核心功能

| 功能 | 说明 |
|------|------|
| ECS 管理 | 实例生命周期、镜像制作、跨地域迁移 |
| OSS 操作 | Bucket 管理、文件同步、批量上传下载 |
| 凭证管理 | 多凭证配置、RAM 角色、环境变量 |
| 输出格式化 | JSON/表格输出、结果过滤、分页 |
| 自动同步 | 技能调用前自动检查仓库更新 |

## 安装与使用

### 通过 cloudskill-cli 安装（推荐）

```bash
# 安装 CLI 工具
npm install -g cloudskill-cli

# 安装到你的 AI IDE
cloudskill init --ai qoder --provider alibaba-cloud

# 安装到全局目录
cloudskill init --ai qoder --provider alibaba-cloud --global

# 安装到所有支持的 AI IDE
cloudskill init --ai all --provider alibaba-cloud
```

### 手动安装

```bash
# 克隆仓库
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git

# 复制技能到你的 AI IDE
cp -r awsome-cloud-skills/skills/alibaba-cloud-skill ~/.qoder/skills/
```

## 快速示例

```bash
# 检查 CLI 版本
aliyun version

# 配置凭证
aliyun configure

# 查询 ECS 实例
aliyun ecs DescribeInstances --RegionId cn-hangzhou

# 查看可用插件
aliyun plugin list-remote

# 安装插件
aliyun plugin install --names ecs
```

## SOP 工作流程

- [支持检查](diagrams/04-plugin-check-sop.drawio) - 验证未列出产品的 CLI 支持
- [地域处理](diagrams/05-region-handle-sop.drawio) - 处理未指定区域的查询
- [🔄 同步](diagrams/01-repo-sync-sop.drawio) - 自动同步机制
- [✅ 写操作确认](diagrams/02-write-confirm-sop.drawio) - 危险操作的用户确认
- [💻 安装](diagrams/03-cli-install-sop.drawio) - 安装与配置指南

## 参考文档

- [什么是阿里云 CLI](references/01-what-is-alibaba-cloud-cli/)
- [快速入门](references/02-quick-start/)
- [安装指南](references/03-installation-guide/)
- [配置指南](references/04-configure-alibaba-cloud-cli/)
- [使用指南](references/05-using-alibaba-cloud-cli/)
- [最佳实践](references/06-best-practices/)
- [错误排查](references/08-troubleshooting/)

## 实用脚本

```
scripts/
├── install.sh              # CLI 安装
├── configure.sh            # 凭证配置
├── ecs/                    # ECS 操作
│   ├── list-instances.sh
│   ├── create-instance.sh
│   ├── start-instance.sh
│   ├── stop-instance.sh
│   ├── create-image.sh
│   └── migrate-instance.sh
├── oss/                    # OSS 操作
│   ├── bucket-ops.sh
│   ├── upload.sh
│   ├── download.sh
│   └── sync.sh
└── utils/                  # 工具函数
    ├── sync-repo.sh        # 仓库同步检查
    ├── output-format.sh    # 输出格式化
    ├── waiter.sh           # 等待工具
    └── error-check.sh      # 错误检查
```

## 技术支持

- 官方文档：https://help.aliyun.com/zh/cli/quickly-start-using-alibaba-cloud-cli
- 问题反馈：https://github.com/RupengWang/awsome-cloud-skills
