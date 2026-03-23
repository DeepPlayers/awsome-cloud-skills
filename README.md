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

A collection of **cloud service operation skills** designed for AI coding assistants. This project organizes CLI operation SOPs, utility scripts, and reference documentation for major cloud providers into standardized skill formats.

**Key Features:**
-️ Standardized skill format compatible with multiple AI IDEs
-🔄-sync mechanism to keep skills up-to-date
-️ Complete reference documentation
-️ Ready-to-use operation scripts

<br/>

## Quick Start

### Install via cloudskill-cli (Recommended)

```bash
# Install CLI tool
npm install -g cloudskill-cli

# Install Alibaba Cloud skill to your AI IDE
cloudskill init --ai qoder --provider alibaba-cloud

# Install to global directory
cloudskill init --ai qoder --provider alibaba-cloud --global

# Install to all supported AI IDEs
cloudskill init --ai all --provider alibaba-cloud
```

**Supported AI IDEs:**

| IDE | Command |
|-----|---------|
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

**Installation Modes:**

```bash
# Local (project-specific)
cloudskill init --ai qoder --provider alibaba-cloud

# Global (user-wide)
cloudskill init --ai qoder --provider alibaba-cloud --global

# Custom path
cloudskill init --ai qoder --provider alibaba-cloud --path /path/to/project
```

<br/>

## Available Skills

###☁ Alibaba Cloud Skill (alibaba-cloud-skill)

**Overview:**

Complete operation SOP for Alibaba Cloud CLI, providing standardized workflows for common cloud resource management tasks.

**Core Features:**

| Feature | Description |
|---------|-------------|
| ECS Management | Instance lifecycle, image creation, cross-region migration |
| OSS Operations | Bucket management, file sync, batch upload/download |
| Credential Management | Multi-profile configuration, RAM roles, environment variables |
| Output Formatting | JSON/table output, result filtering, pagination |
| Auto Sync | Automatic repository update check before skill invocation |

**Installation & Usage:**

```bash
# Via cloudskill-cli (Recommended)
cloudskill init --ai qoder --provider alibaba-cloud

# Manual installation
git clone https://github.com/RupengWang/awsome-cloud-skills.git
cp -r awsome-cloud-skills/skills/alibaba-cloud-skill ~/.qoder/skills/
```

**Quick Examples:**

```bash
# Check CLI version
aliyun version

# Configure credentials
aliyun configure

# Query ECS instances
aliyun ecs DescribeInstances --RegionId cn-hangzhou

# List available plugins
aliyun plugin list-remote

# Install plugin
aliyun plugin install --names ecs
```

**SOP Workflows:**

- [ Support Check](skills/alibaba-cloud-skill/diagrams/04-plugin-check-sop.drawio) - Verify CLI support for unlisted products
- [ Handling](skills/alibaba-cloud-skill/diagrams/05-region-handle-sop.drawio) - Handle queries without specified region
- [🔄 Sync](skills/alibaba-cloud-skill/diagrams/01-repo-sync-sop.drawio) - Auto-sync mechanism
- [✅ Write Operation Confirmation](skills/alibaba-cloud-skill/diagrams/02-write-confirm-sop.drawio) - User confirmation for destructive operations
- [💻 Installation](skills/alibaba-cloud-skill/diagrams/03-cli-install-sop.drawio) - Installation & configuration guide

**Reference Documentation:**

- [What is Alibaba Cloud CLI](skills/alibaba-cloud-skill/references/01-what-is-alibaba-cloud-cli/)
- [Quick Start](skills/alibaba-cloud-skill/references/02-quick-start/)
- [Installation Guide](skills/alibaba-cloud-skill/references/03-installation-guide/)
- [Configuration](skills/alibaba-cloud-skill/references/04-configure-alibaba-cloud-cli/)
- [Usage Guide](skills/alibaba-cloud-skill/references/05-using-alibaba-cloud-cli/)
- [Best Practices](skills/alibaba-cloud-skill/references/06-best-practices/)
- [Troubleshooting](skills/alibaba-cloud-skill/references/08-troubleshooting/)

**Utility Scripts:**

```
skills/alibaba-cloud-skill/scripts/
├ install.sh              # CLI installation
├ configure.sh            # Credential configuration
├ ecs/                    # ECS operations
│   ├── list-instances.sh
│   ├── create-instance.sh
│   ├── start-instance.sh
│   ├── stop-instance.sh
│   ├── create-image.sh
│  └ migrate-instance.sh
├ oss/                    # OSS operations
│   ├── bucket-ops.sh
│   ├── upload.sh
│   ├── download.sh
│  └ sync.sh
└ utils/                  # Utilities
    ├── sync-repo.sh        # Repository sync check
    ├── output-format.sh    # Output formatting
    ├── waiter.sh           # Wait utility
   └ error-check.sh      # Error checking
```

### Coming Soon

-☁ Azure Cloud CLI Skill (In Development)
-🔷 AWS Cloud CLI Skill (Planned)
-☁ Google Cloud CLI Skill (Planned)

<br/>

## Contributing & Feedback

If you encounter issues or have suggestions for improvement, feel free to:

- Refer to the official documentation: https://help.aliyun.com/zh/cli/quickly-start-using-alibaba-cloud-cli
- Submit an Issue or Pull Request: https://github.com/RupengWang/awsome-cloud-skills

### How to Contribute?

- Contribute SOP workflows you're familiar with, refer to [existing SOP templates](skills/alibaba-cloud-skill/diagrams/)
- Contribute utility scripts, such as ACS cluster operation scripts

<br/>

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=RupengWang/awsome-cloud-skills&type=Date)](https://star-history.com/#RupengWang/awsome-cloud-skills&Date)

<br/>

## License

Apache License 2.0 - see [LICENSE](LICENSE) file for details.
