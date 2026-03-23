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
-🔄同步机制，保持技能最新
- 完整的参考文档
- 开箱即用的操作脚本

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

**安装模式：

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

###☁ 阿里云技能 (alibaba-cloud-skill)

**概述：**

完整的阿里云 CLI 操作 SOP，提供常见云资源管理的标准化工作流程。

**核心功能：**

| 功能 | 说明 |
|------|
