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

A collection of **AI agent skills** for cloud services and productivity tools. This project provides standardized skill formats for cloud CLI operations, knowledge base search, and more.

**Key Features:**
- 📦 Standardized skill format compatible with multiple AI IDEs
- 🔄 Auto-sync mechanism to keep skills up-to-date
- 📚 Complete reference documentation for each skill
- 🛠️ Ready-to-use operation scripts
- 🎯 Intent recognition and smart filtering

<br/>

## Quick Start

### Manual Installation

```bash
# Clone the repository
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git

# Copy desired skill to your AI IDE
cp -r awsome-cloud-skills/skills/<skill-name> ~/.qoder/skills/
```

**Example - Install Alibaba Cloud Skill:**
```bash
cp -r awsome-cloud-skills/skills/alibaba-cloud-skill ~/.qoder/skills/
```

**Example - Install DingDoc Knowledge Search Skill:**
```bash
cp -r awsome-cloud-skills/skills/dingdoc_knowledge_search ~/.qoder/skills/
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

**Directory:** `skills/alibaba-cloud-skill/`

Complete operation SOP for Alibaba Cloud CLI, providing standardized workflows for common cloud resource management tasks.

**Core Features:**
- ECS lifecycle management, image creation, cross-region migration
- OSS bucket management, file sync, batch upload/download
- Multi-profile credential configuration, RAM roles
- JSON/table output formatting, result filtering
- Auto-sync mechanism before skill invocation

**Installation:**
```bash
# Clone and copy to your AI IDE
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git
cp -r awsome-cloud-skills/skills/alibaba-cloud-skill ~/.qoder/skills/
```

**Learn More:** [Alibaba Cloud Skill README](skills/alibaba-cloud-skill/README.md)

---

### 🔍 DingDoc Knowledge Search Skill

**Directory:** `skills/dingdoc_knowledge_search/`

Intelligent search for DingTalk knowledge base with intent recognition and weighted filtering.

**Core Features:**
- 🧠 Intent recognition: Identifies core entities and operation conditions
- 🎯 Weighted keyword strategy: Distinguishes primary and secondary keywords
- 🔎 Smart filtering: Search core terms first, then filter with conditions
- 📊 Relevance scoring: Multi-dimensional scoring for accuracy
- 📝 Auto-save: Automatically saves results as Markdown when > 10 docs
- 🛡️ Environment check: Auto-detects MCP Server installation

**Version:** V3.0.0 (Latest)
**Accuracy:** 90%+ (Improved from 70% in V2)

**Installation:**
```bash
# Clone and copy to your AI IDE
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git
cp -r awsome-cloud-skills/skills/dingdoc_knowledge_search ~/.qoder/skills/
```

**Learn More:** [DingDoc Skill README](skills/dingdoc_knowledge_search/README.md)

---

### 📊 Bailian Report Query Skill

**Directory:** `skills/bailian-report-query/`

Query Bailian platform report data through ChatBI Open API for model usage metrics and statistics.

**Core Features:**
- 📈 Model invocation metrics (token usage)
- 📊 Invocation counts, success rates, status code distribution
- 🔍 Filter and aggregate by user, model, time dimensions
- 📉 Success rate trends, throttling analysis, gateway statistics
- ⚡ Async query with automatic session management

**Supported Reports:**
- Report 1: User Model Invocation Metrics (pageId=1315847)
- Report 2: User Model Invocation Counts - Daily (pageId=1706516)

**Installation:**
```bash
# Clone and copy to your AI IDE
git clone git@gitlab.alibaba-inc.com:ez-tam-ai/awsome-cloud-skills.git
cp -r awsome-cloud-skills/skills/bailian-report-query ~/.qoder/skills/
```

**Learn More:** [Bailian Report Skill README](skills/bailian-report-query/README.md)

---

### Coming Soon

- 🟦 Azure Cloud CLI Skill (In Development)
- 🟧 AWS Cloud CLI Skill (Planned)
- 🟩 Google Cloud CLI Skill (Planned)

<br/>

## Project Structure

```
awsome-cloud-skills/
├── skills/                      # All available skills
│   ├── alibaba-cloud-skill/     # Alibaba Cloud CLI operations
│   │   ├── SKILL.md
│   │   ├── README.md
│   │   ├── diagrams/            # SOP workflow diagrams
│   │   ├── references/          # Reference documentation
│   │   └── scripts/             # Utility scripts
│   ├── dingdoc_knowledge_search/  # DingTalk knowledge search
│   │   ├── SKILL.md
│   │   ├── README.md
│   │   ├── config.json
│   │   └── examples.md
│   └── bailian-report-query/    # Bailian platform reports
│       ├── SKILL.md
│       ├── README.md
│       ├── config.yaml
│       └── scripts/             # Query scripts
├── README.md                    # Project overview (English)
├── README_ZH.md                 # Project overview (Chinese)
└── LICENSE                      # Apache 2.0 License
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

1. Refer to existing [SOP templates](skills/alibaba-cloud-skill/diagrams/) for format
2. Follow the standard skill structure (SKILL.md + README.md)
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
