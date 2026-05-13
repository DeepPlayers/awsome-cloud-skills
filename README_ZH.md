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

专为 AI 编程助手设计的**云服务与生产力工具技能集合**。本项目将云厂商 CLI 操作、AI 视频生成与 Prompt 优化等功能整理成标准化的技能格式。

**核心特性：**
- 📦 标准化技能格式，兼容多种 AI IDE
- 🔄 自动同步机制，保持技能最新
- 📚 每个技能包含完整的参考文档
- 🛠️ 开箱即用的操作脚本

<br/>

## 快速开始

### 手动安装

```bash
# 克隆仓库
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git

# 复制所需技能到你的 AI IDE
cp -r awsome-cloud-skills/skills/<skill-name> ~/.qoder/skills/
```

**示例 - 安装阿里云 CLI 技能：**
```bash
cp -r awsome-cloud-skills/skills/alibaba-cloud-cli ~/.qoder/skills/
```

**示例 - 安装视频生成技能：**
```bash
cp -r awsome-cloud-skills/skills/happy-horse-cli ~/.qoder/skills/
```

**支持的 AI IDE：**

| IDE | 技能目录 |
|-----|----------|
| Qoder | `~/.qoder/skills/` |
| Claude Code | `~/.claude/skills/` |
| Cursor | `~/.cursor/skills/` |
| Windsurf | `~/.codeium/skills/` |

<br/>

## 可用技能

### ☁️ 阿里云 CLI 技能

**目录：** `skills/alibaba-cloud-cli/`

完整的阿里云 CLI 操作 SOP，提供常见云资源管理的标准化工作流程。

**核心功能：**
- ECS 生命周期管理、镜像制作、跨地域迁移
- OSS Bucket 管理、文件同步、批量上传下载
- 多凭证配置、RAM 角色管理
- JSON/表格输出格式化、结果过滤
- 技能调用前自动检查仓库更新

**安装：**
```bash
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git
cp -r awsome-cloud-skills/skills/alibaba-cloud-cli ~/.qoder/skills/
```

**了解更多：** [阿里云技能 SKILL.md](skills/alibaba-cloud-cli/SKILL.md)

---

### 🎬 HappyHorse 视频生成技能

**目录：** `skills/happy-horse-cli/`

基于阿里云百炼平台 happyhorse-1.0 系列模型的 AI 视频生成工具，支持五种生成模式。

**核心功能：**
- 🖼️ 图生视频（i2v）：以图片首帧生成视频
- 📝 文生视频（t2v）：纯文字 Prompt 生成视频
- 👥 参考生视频（r2v）：多图参考保持角色一致性
- ✂️ 视频编辑（edit）：对已有视频按指令修改
- 📦 批量并发生成（batch）：一次提交多个任务，最大并发 10

**安装：**
```bash
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git
cp -r awsome-cloud-skills/skills/happy-horse-cli ~/.qoder/skills/
```

**了解更多：** [HappyHorse SKILL.md](skills/happy-horse-cli/SKILL.md)

---

### 🎨 AI 视频 Prompt 优化技能

**目录：** `skills/ai-movie-prompt-optimizer/`

AI 视频场景 Prompt 优化专家，提供全场景提示词优化与电影级质感提升。

**核心功能：**
- 🔧 正向排除法：规避 Prompt 污染
- 👁️ 视觉代偿法：替代抽象动作描述
- 🎥 三级镜头控制：景别/角度/焦点递进
- 🏷️ 歧义词替换：用具象描述替代风格标签
- 🎬 电影级质感词汇库：画质/光影/色彩速查
- 🎙️ AI 配音三轴声学控制优化

**安装：**
```bash
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git
cp -r awsome-cloud-skills/skills/ai-movie-prompt-optimizer ~/.qoder/skills/
```

**了解更多：** [Prompt 优化 SKILL.md](skills/ai-movie-prompt-optimizer/SKILL.md)

<br/>

## 项目结构

```
awsome-cloud-skills/
├── skills/                          # 所有可用技能
│   ├── alibaba-cloud-cli/           # 阿里云 CLI 操作
│   │   ├── SKILL.md
│   │   ├── diagrams/                # SOP 工作流程图
│   │   ├── references/              # 参考文档
│   │   └── scripts/                 # 实用脚本
│   ├── happy-horse-cli/             # HappyHorse 视频生成
│   │   ├── SKILL.md
│   │   ├── references/              # 参考文档
│   │   └── scripts/                 # 视频生成脚本
│   └── ai-movie-prompt-optimizer/   # AI 视频 Prompt 优化
│       ├── SKILL.md
│       └── references/              # 优化技巧与配音指南
├── README.md                        # 项目概览（英文）
├── README_ZH.md                     # 项目概览（中文）
└── LICENSE                          # Apache 2.0 许可证
```

<br/>

## 贡献与反馈

我们欢迎贡献和反馈！

### 如何贡献？

- 📝 贡献您熟悉的 SOP 流程
- 🛠️ 贡献实用脚本（如集群运维脚本）
- 📚 改进参考文档
- 🐛 报告问题和 Bug

### 贡献指南

1. 参考现有的 [SOP 模板](skills/alibaba-cloud-cli/diagrams/) 了解格式
2. 遵循标准技能结构（SKILL.md + 参考文档）
3. 尽可能包含参考文档和示例
4. 通过 Pull Request 提交

### 反馈渠道

- 📖 官方文档：https://help.aliyun.com/zh/cli/quickly-start-using-alibaba-cloud-cli
- 🐛 提交 Issue：https://github.com/RupengWang/awsome-cloud-skills
- 💡 Pull Request：https://github.com/RupengWang/awsome-cloud-skills

<br/>

## Star 趋势

[![Star History Chart](https://api.star-history.com/svg?repos=RupengWang/awsome-cloud-skills&type=Date)](https://star-history.com/#RupengWang/awsome-cloud-skills&Date)

<br/>

## 许可证

Apache License 2.0 - 详见 [LICENSE](LICENSE) 文件。
