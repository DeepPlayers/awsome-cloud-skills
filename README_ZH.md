# Awesome Cloud Skills

<p align="center">
  <a href="#快速开始"><strong>快速开始</strong></a> &middot;
  <a href="#可用技能"><strong>技能列表</strong></a> &middot;
  <a href="README.md"><strong>English</strong></a> &middot;
  <a href="https://github.com/RupengWang/awsome-cloud-skills"><strong>GitHub</strong></a>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-blue" alt="Apache License 2.0" /></a>
  <a href="https://github.com/RupengWang/awsome-cloud-skills"><img src="https://img.shields.io/github/stars/RupengWang/awsome-cloud-skills?style=flat" alt="Stars" /></a>
</p>

<br/>

## 什么是 Awesome Cloud Skills？

专为 AI 编程助手设计的**云服务操作技能集合**。本项目将主流云厂商的 CLI 操作 SOP、实用脚本和参考文档整理成标准化的技能格式。

**核心特性：**
-️ 标准化技能格式，兼容多种 AI IDE
-🔄机制，保持技能最新
-️ 完整的参考文档
-️ 开箱即用的操作脚本

<br/>

## 快速开始

### 使用 cloudskill-cli 安装（推荐）

```bash
# 安装 CLI 工具
npm install -g cloudskill-cli

# 安装阿里云技能到你的 AI IDE
cloudskill init --ai qoder --provider alibaba-cloud

# 安装到全局目录
cloudskill init --ai qoder --provider alibaba-cloud --global

# 安装到所有支持的 AI IDE
cloudskill init --ai all --provider alibaba-cloud
```

**支持的 AI IDE：**

| IDE | 命令 |
|-----|------|
| Claude Code | `--ai claude` |
| Qoder | `--ai qoder` |
| Cursor | `--ai cursor` |
| Windsurf | `--ai windsurf` |
| GitHub Copilot | `--ai copilot` |
| Kiro | `--ai kiro` |
| Roo Code | `--ai roocode` |
| Gemini CLI | `--ai gemini` |
| Trae | `--ai trae` |
| OpenCode | `--ai opencode` |
| Continue | `--ai continue` |

**安装模式：**

```bash
# 本地安装（项目级）
cloudskill init --ai qoder --provider alibaba-cloud

# 全局安装（用户级）
cloudskill init --ai qoder --provider alibaba-cloud --global

# 自定义路径
cloudskill init --ai qoder --provider alibaba-cloud --path /path/to/project
```

<br/>

## 可用技能

###☁阿里云技能 (alibaba-cloud-skill)

**概述：**

完整的阿里云 CLI 操作 SOP，提供常见云资源管理的标准化工作流程。

**核心功能：**

| 功能 | 说明 |
|------|------|
| ECS 管理 | 实例生命周期、镜像制作、跨地域迁移 |
| OSS 操作 | Bucket 管理、文件同步、批量上传下载 |
| 凭证管理 | 多凭证配置、RAM 角色、环境变量 |
| 输出格式化 | JSON/表格输出、结果过滤、分页 |
| 自动同步 | 技能调用前自动检查仓库更新 |

**安装与使用：**

```bash
# 通过 cloudskill-cli 安装（推荐）
cloudskill init --ai qoder --provider alibaba-cloud

# 手动安装
git clone https://github.com/RupengWang/awsome-cloud-skills.git
cp -r awsome-cloud-skills/skills/alibaba-cloud-skill ~/.qoder/skills/
```

**快速示例：**

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

**SOP 工作流程：**

- [支持检查](skills/alibaba-cloud-skill/diagrams/04-plugin-check-sop.drawio) - 验证未列出产品的 CLI 支持
- [处理](skills/alibaba-cloud-skill/diagrams/05-region-handle-sop.drawio) - 处理未指定区域的查询
- [🔄同步](skills/alibaba-cloud-skill/diagrams/01-repo-sync-sop.drawio) - 自动同步机制
- [✅ 写操作确认](skills/alibaba-cloud-skill/diagrams/02-write-confirm-sop.drawio) - 危险操作的用户确认
- [💻安装](skills/alibaba-cloud-skill/diagrams/03-cli-install-sop.drawio) - 安装与配置指南

**参考文档：**

- [什么是阿里云 CLI](skills/alibaba-cloud-skill/references/zh/01-什么是阿里云CLI/)
- [快速入门](skills/alibaba-cloud-skill/references/zh/02-快速入门/)
- [安装指南](skills/alibaba-cloud-skill/references/zh/03-安装指南/)
- [配置指南](skills/alibaba-cloud-skill/references/zh/04-配置阿里云CLI/)
- [使用指南](skills/alibaba-cloud-skill/references/zh/05-使用阿里云CLI/)
- [最佳实践](skills/alibaba-cloud-skill/references/zh/06-最佳实践/)
- [错误排查](skills/alibaba-cloud-skill/references/zh/08-错误排查/)

**实用脚本：**

```
skills/alibaba-cloud-skill/scripts/
├.sh              # CLI 安装
├.sh            # 凭证配置
├/                    # ECS 操作
│   ├── list-instances.sh
│   ├── create-instance.sh
│   ├── start-instance.sh
│   ├── stop-instance.sh
│   ├── create-image.sh
│ └-instance.sh
├/                    # OSS 操作
│   ├── bucket-ops.sh
│   ├── upload.sh
│   ├── download.sh
│ └.sh
└/                  # 工具函数
    ├── sync-repo.sh        # 仓库同步检查
    ├── output-format.sh    # 输出格式化
    ├── waiter.sh           # 等待工具
  └-check.sh      # 错误检查
```

### 即将推出

-☁ CLI 技能（开发中）
- CLI 技能（计划中）
-☁ Cloud CLI 技能（计划中）

<br/>

## 贡献与反馈

如果您在使用过程中遇到问题或有改进建议，欢迎：

- 参考官方文档：https://help.aliyun.com/zh/cli/quickly-start-using-alibaba-cloud-cli
- 提交 Issue 或 Pull Request：https://github.com/RupengWang/awsome-cloud-skills

### 如何贡献？

- 贡献您熟悉的 SOP 流程，参考[现有的 SOP 模板](skills/alibaba-cloud-skill/diagrams/)
- 贡献实用的 Scripts 工具脚本，比如 ACS 集群运维脚本等

<br/>

## Star 趋势

[![Star History Chart](https://api.star-history.com/svg?repos=RupengWang/awsome-cloud-skills&type=Date)](https://star-history.com/#RupengWang/awsome-cloud-skills&Date)

<br/>

## 许可证

Apache License 2.0 - 详见 [LICENSE](LICENSE) 文件。
