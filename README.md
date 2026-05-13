# Awesome Cloud Skills

<p align="center">
  <a href="#quick-start"><strong>Quick Start</strong></a> &middot;
  <a href="#available-skills"><strong>Skills</strong></a> &middot;
  <a href="README_ZH.md"><strong>中文文档</strong></a> &middot;
  <a href="https://github.com/RupengWang/awsome-cloud-skills"><strong>GitHub</strong></a>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-blue" alt="Apache License 2.0" /></a>
  <a href="https://github.com/RupengWang/awsome-cloud-skills"><img src="https://img.shields.io/github/stars/RupengWang/awsome-cloud-skills?style=flat" alt="Stars" /></a>
</p>

<br/>

## What is Awesome Cloud Skills?

A collection of **AI agent skills** for cloud services and productivity tools. This project provides standardized skill formats for cloud CLI operations, AI video generation, and Prompt optimization.

**Key Features:**
- 📦 Standardized skill format compatible with multiple AI IDEs
- 🔄 Auto-sync mechanism to keep skills up-to-date
- 📚 Complete reference documentation for each skill
- 🛠️ Ready-to-use operation scripts

<br/>

## Quick Start

### Manual Installation

```bash
# Clone the repository
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git

# Copy desired skill to your AI IDE
cp -r awsome-cloud-skills/skills/<skill-name> ~/.qoder/skills/
```

**Example - Install Alibaba Cloud CLI Skill:**
```bash
cp -r awsome-cloud-skills/skills/alibaba-cloud-cli ~/.qoder/skills/
```

**Example - Install Video Generation Skill:**
```bash
cp -r awsome-cloud-skills/skills/happy-horse-cli ~/.qoder/skills/
```

**Supported AI IDEs:**

| IDE | Skills Directory |
|-----|------------------|
| Qoder | `~/.qoder/skills/` |
| Claude Code | `~/.claude/skills/` |
| Cursor | `~/.cursor/skills/` |
| Windsurf | `~/.codeium/skills/` |

<br/>

## Available Skills

### ☁️ Alibaba Cloud CLI Skill

**Directory:** `skills/alibaba-cloud-cli/`

Complete operation SOP for Alibaba Cloud CLI, providing standardized workflows for common cloud resource management tasks.

**Core Features:**
- ECS lifecycle management, image creation, cross-region migration
- OSS bucket management, file sync, batch upload/download
- Multi-profile credential configuration, RAM roles
- JSON/table output formatting, result filtering
- Auto-sync mechanism before skill invocation

**Installation:**
```bash
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git
cp -r awsome-cloud-skills/skills/alibaba-cloud-cli ~/.qoder/skills/
```

**Learn More:** [Alibaba Cloud CLI SKILL.md](skills/alibaba-cloud-cli/SKILL.md)

---

### 🎬 HappyHorse Video Generation Skill

**Directory:** `skills/happy-horse-cli/`

AI video generation tool based on Alibaba Cloud Bailian platform's happyhorse-1.0 model series, supporting five generation modes.

**Core Features:**
- 🖼️ Image-to-Video (i2v): Generate video from a starting image
- 📝 Text-to-Video (t2v): Generate video from text prompt only
- 👥 Reference-to-Video (r2v): Multi-image reference for character consistency
- ✂️ Video Edit: Modify existing video based on instructions
- 📦 Batch Generation: Submit multiple tasks concurrently, max concurrency 10

**Installation:**
```bash
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git
cp -r awsome-cloud-skills/skills/happy-horse-cli ~/.qoder/skills/
```

**Learn More:** [HappyHorse SKILL.md](skills/happy-horse-cli/SKILL.md)

---

### 🎨 AI Movie Prompt Optimizer Skill

**Directory:** `skills/ai-movie-prompt-optimizer/`

AI video Prompt optimization expert, providing full-scenario prompt optimization and cinematic quality enhancement.

**Core Features:**
- 🔧 Positive Exclusion: Avoid Prompt contamination
- 👁️ Visual Compensation: Replace abstract action descriptions
- 🎥 Three-Level Camera Control: Shot size/angle/focus progression
- 🏷️ Ambiguous Word Replacement: Replace style tags with concrete descriptions
- 🎬 Cinematic Quality Vocabulary: Image quality/lighting/color reference
- 🎙️ AI Dubbing Acoustic Control: Three-axis parameter optimization

**Installation:**
```bash
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git
cp -r awsome-cloud-skills/skills/ai-movie-prompt-optimizer ~/.qoder/skills/
```

**Learn More:** [Prompt Optimizer SKILL.md](skills/ai-movie-prompt-optimizer/SKILL.md)

<br/>

## Project Structure

```
awsome-cloud-skills/
├── skills/                          # All available skills
│   ├── alibaba-cloud-cli/           # Alibaba Cloud CLI operations
│   │   ├── SKILL.md
│   │   ├── diagrams/                # SOP workflow diagrams
│   │   ├── references/              # Reference documentation
│   │   └── scripts/                 # Utility scripts
│   ├── happy-horse-cli/             # HappyHorse video generation
│   │   ├── SKILL.md
│   │   ├── references/              # Reference documentation
│   │   └── scripts/                 # Video generation scripts
│   └── ai-movie-prompt-optimizer/   # AI video Prompt optimization
│       ├── SKILL.md
│       └── references/              # Optimization tips & dubbing guide
├── README.md                        # Project overview (English)
├── README_ZH.md                     # Project overview (Chinese)
└── LICENSE                          # Apache 2.0 License
```

<br/>

## Contributing & Feedback

We welcome contributions and feedback!

### How to Contribute?

- 📝 Contribute SOP workflows you're familiar with
- 🛠️ Contribute utility scripts (e.g., cluster operation scripts)
- 📚 Improve reference documentation
- 🐛 Report issues and bugs

### Contribution Guidelines

1. Refer to existing [SOP templates](skills/alibaba-cloud-cli/diagrams/) for format
2. Follow the standard skill structure (SKILL.md + reference docs)
3. Include reference documentation and examples when possible
4. Submit via Pull Request

### Feedback Channels

- 📖 Official Documentation: https://help.aliyun.com/zh/cli/quickly-start-using-alibaba-cloud-cli
- 🐛 Submit Issue: https://github.com/RupengWang/awsome-cloud-skills
- 💡 Pull Request: https://github.com/RupengWang/awsome-cloud-skills

<br/>

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=RupengWang/awsome-cloud-skills&type=Date)](https://star-history.com/#RupengWang/awsome-cloud-skills&Date)

<br/>

## License

Apache License 2.0 - see [LICENSE](LICENSE) file for details.
