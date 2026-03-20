# Awesome cloud skills
<p align="center">
  <a href="#快速开始"><strong>快速开始</strong></a> &middot;
  <a href="alibaba-cloud-skill/SKILL.md"><strong>技能文档</strong></a> &middot;
  <a href="https://github.com/RupengWang/awsome-cloud-skills"><strong>GitHub</strong></a> &middot;
  <a href="alibaba-cloud-skill/references/zh/"><strong>参考文档</strong></a>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-blue" alt="Apache License 2.0" /></a>
  <a href="https://github.com/RupengWang/awsome-cloud-skills/stargazers"><img src="https://img.shields.io/github/stars/RupengWang/awsome-cloud-skills?style=flat" alt="Stars" /></a>
</p>

<br/>

<br/>

## 什么是 Awesome Cloud Skills?

云服务操作技能集合，提供主流云服务商的CLI操作SOP、脚本和参考文档。

## 项目结构

```
.
├── alibaba-cloud-skill/     # 阿里云技能
│   ├── SKILL.md            # 技能定义文件
│   ├── references/         # 参考文档
│   └── scripts/            # 操作脚本
│       ├── ecs/            # ECS实例操作
│       ├── oss/            # OSS存储操作
│       └── utils/          # 工具函数
```

## 阿里云CLI技能

提供阿里云CLI的完整操作SOP，包括：

### 快速开始

```bash
# 检查是否已安装
aliyun version

# macOS安装
brew install aliyun-cli

# Linux安装
/bin/bash -c "$(curl -fsSL https://aliyuncli.alicdn.com/install.sh)"

# 配置凭证
aliyun configure
```

### 主要功能

| 功能 | 说明 |
|------|------|
| ECS管理 | 实例创建、启停、镜像制作、跨地域迁移 |
| OSS操作 | Bucket管理、文件上传下载、目录同步 |
| 凭证管理 | 多凭证配置、RAM角色、环境变量 |
| 输出格式化 | JSON/表格式输出、结果过滤 |
| 自动同步 | Skill调用前自动检查远程仓库更新 |

### 常用命令

```bash
# 查询ECS实例
aliyun ecs DescribeInstances --RegionId cn-hangzhou

# 查询可用插件
aliyun plugin list-remote

# 安装插件
aliyun plugin install --names ecs
```

## 自动同步机制

当Agent调用此技能时，会自动检查远程仓库是否有更新：

- 远程仓库：`http://gitlab.alibaba-inc.com/ez-tam-ai/awsome-cloud-skills.git`
- 自动配置远程仓库（如未配置）
- 自动同步最新更新（如无冲突）
- 冲突时跳过同步并提醒用户

详见 [alibaba-cloud-skill/SKILL.md](alibaba-cloud-skill/SKILL.md) 中的「执行前必读：仓库同步检查」章节。

## 参考文档

详细文档位于 `alibaba-cloud-skill/references/zh/` 目录：

- [什么是阿里云CLI](alibaba-cloud-skill/references/zh/01-什么是阿里云CLI/)
- [快速入门](alibaba-cloud-skill/references/zh/02-快速入门/)
- [安装指南](alibaba-cloud-skill/references/zh/03-安装指南/)
- [配置阿里云CLI](alibaba-cloud-skill/references/zh/04-配置阿里云CLI/)
- [使用阿里云CLI](alibaba-cloud-skill/references/zh/05-使用阿里云CLI/)
- [最佳实践](alibaba-cloud-skill/references/zh/06-最佳实践/)
- [错误排查](alibaba-cloud-skill/references/zh/08-错误排查/)

## 脚本说明

操作脚本位于 `alibaba-cloud-skill/scripts/` 目录：

```
scripts/
├── install.sh           # CLI安装脚本
├── configure.sh         # 凭证配置脚本
├── ecs/
│   ├── list-instances.sh    # 列出实例
│   ├── create-instance.sh   # 创建实例
│   ├── start-instance.sh    # 启动实例
│   ├── stop-instance.sh     # 停止实例
│   ├── create-image.sh      # 创建镜像
│   └── migrate-instance.sh  # 跨地域迁移
├── oss/
│   ├── bucket-ops.sh    # Bucket操作
│   ├── upload.sh        # 上传文件
│   ├── download.sh      # 下载文件
│   └── sync.sh          # 同步目录
└── utils/
    ├── sync-repo.sh     # 仓库同步检查（优先执行）
    ├── output-format.sh # 输出格式化
    ├── waiter.sh        # 等待工具
    └── error-check.sh   # 错误检查
```

## 许可证

Apache License 2.0 - 详见 [LICENSE](LICENSE) 文件。
