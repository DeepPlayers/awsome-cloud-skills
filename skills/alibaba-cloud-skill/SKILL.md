---
name: alibaba-cloud-cli
description: |
  Alibaba Cloud CLI skill providing complete installation, configuration, and cloud product operation SOPs. Use this skill when users need to operate Alibaba Cloud resources (ECS, OSS, RDS, VPC, etc.), configure Alibaba Cloud CLI, migrate cloud resources, or manage cloud services. Includes complete workflows for CLI installation, credential configuration, ECS instance management, OSS storage operations, and more.
---

# Alibaba Cloud CLI Skill

This skill provides complete operation SOP for Alibaba Cloud CLI, including installation/configuration and operation scripts for major cloud products.

## ⚠️ Must Read Before Execution: Repository Sync Check

**Before executing any task, you must check and sync remote repository updates:**

Remote repository: `http://gitlab.alibaba-inc.com/ez-tam-ai/awsome-cloud-skills.git`

### Sync Flow

```bash
# 1. Navigate to the project directory (clone first if not already)
# Clone repository (first-time use)
git clone http://gitlab.alibaba-inc.com/ez-tam-ai/awsome-cloud-skills.git
cd awsome-cloud-skills

# Or navigate to existing project directory
cd <your-project-path>

# 2. Check if remote has updates
git fetch origin

# 3. View differences between local and remote
git status

# 4. If remote has updates and no conflicts, execute pull
git pull origin main
# Or: git pull origin master (based on actual branch name)
```

### Sync Rules

| Situation | Handling |
|-----------|----------|
| Local is not a git repository | Prompt user to clone the project |
| Local is git repo but remote not configured | Auto-add remote repository origin |
| Remote URL doesn't match expected | Auto-update remote repository URL |
| Remote has updates, local unchanged | Execute `git pull` to sync |
| Remote has updates, local modified but no conflicts | Execute `git pull` to sync |
| Remote has updates, conflicts exist | **Skip pull**, notify user to resolve manually |
| Remote has no updates | No action needed, continue task |

### Conflict Handling Notice

If conflicts are detected, **do NOT auto-pull**. Notify the user:

> ⚠️ Conflicts detected between local and remote repository. Auto-sync skipped. Please resolve conflicts manually with `git pull`, or contact administrator.

### Sync Check Script Example

```bash
#!/bin/bash
# sync-repo.sh - Repository sync check script

REMOTE_URL="http://gitlab.alibaba-inc.com/ez-tam-ai/awsome-cloud-skills.git"

# Get script directory, locate SKILL.md directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"  # alibaba-cloud-skill directory

# Find git repo root from SKILL directory (max 2 levels up)
REPO_DIR=""
SEARCH_DIR="$SKILL_DIR"
MAX_DEPTH=2
DEPTH=0
while [ "$SEARCH_DIR" != "/" ] && [ $DEPTH -lt $MAX_DEPTH ]; do
    [ -d "$SEARCH_DIR/.git" ] && { REPO_DIR="$SEARCH_DIR"; break; }
    SEARCH_DIR="$(dirname "$SEARCH_DIR")"
    DEPTH=$((DEPTH + 1))
done

if [ -z "$REPO_DIR" ]; then
    echo "Error: SKILL directory is not a git repository. Please clone the project:"
    echo "  git clone $REMOTE_URL"
    exit 1
fi

cd "$REPO_DIR" || exit 1

# Check if remote repository is configured
ORIGIN_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$ORIGIN_URL" ]; then
    echo "Remote not configured, adding..."
    git remote add origin "$REMOTE_URL"
elif [ "$ORIGIN_URL" != "$REMOTE_URL" ]; then
    echo "Remote URL mismatch, updating..."
    git remote set-url origin "$REMOTE_URL"
fi

# Fetch remote update info
git fetch origin 2>/dev/null

# Check for updates
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")

if [ -z "$REMOTE" ]; then
    echo "Upstream branch not set. Please configure remote tracking."
    exit 0
fi

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "Local is up-to-date. No sync needed."
    exit 0
fi

# Check for conflicts
if git diff --quiet && git diff --cached --quiet; then
    echo "Remote has updates, syncing..."
    git pull --no-edit origin HEAD && echo "Sync successful" || echo "Sync failed. Please handle manually."
else
    echo "⚠️ Local uncommitted changes detected. Possible conflicts."
    echo "Please run manually: git stash && git pull && git stash pop"
fi
```

---

## Quick Start

### 1. Check Environment

First verify if Alibaba Cloud CLI is installed:

```bash
aliyun version
```

### 2. Install CLI (if not installed)

Choose installation method based on your operating system:

**macOS (Homebrew recommended):**
```bash
brew install aliyun-cli
```

**Linux (one-line install):**
```bash
/bin/bash -c "$(curl -fsSL https://aliyuncli.alicdn.com/install.sh)"
```

**Windows (PowerShell):**
```powershell
# Using Chocolatey
choco install aliyun-cli

# Or download installer
# https://aliyuncli.alicdn.com/aliyun-cli-windows-latest-amd64.zip
```

### 3. Configure Credentials

**Interactive configuration (recommended for beginners):**
```bash
aliyun configure
```

**Non-interactive configuration:**
```bash
aliyun configure set \
  --profile default \
  --mode AK \
  --access-key-id <AccessKeyId> \
  --access-key-secret <AccessKeySecret> \
  --region cn-hangzhou
```

## Command Structure

### RPC Style API (Most Products)

```bash
aliyun <ProductCode> <APIName> [Parameters]
```

Examples:
```bash
# Query available ECS regions
aliyun ecs DescribeRegions

# Query ECS instances
aliyun ecs DescribeInstances --RegionId cn-hangzhou
```

### ROA Style API (Container Service, etc.)

```bash
aliyun <ProductCode> <Method> <PathPattern> [RequestBody] [Parameters]
```

Examples:
```bash
# Query ACK clusters
aliyun cs GET /regions/cn-hangzhou/clusters
```

## Common Command Options

| Option | Description | Example |
|--------|-------------|---------|
| `--profile, -p` | Specify credential profile | `--profile akProfile` |
| `--region` | Specify region | `--region cn-beijing` |
| `--output, -o` | Format output | `--output cols=InstanceId,Status rows=Instances.Instance[]` |
| `--pager` | Aggregate paginated results | `--pager` |
| `--waiter` | Poll for results | `--waiter expr='Status' to='Available'` |
| `--dryrun` | Simulate call | `--dryrun` |
| `--force` | Force call | Use with `--version` |

## Plugin Management (CLI 3.3.0+)

Since CLI 3.3.0, Alibaba Cloud CLI uses a plugin-based architecture. Each cloud product's command-line capabilities are split into separate plugins. **If a product command doesn't exist, you need to install the corresponding plugin first.**

### Finding and Installing Plugins

```bash
# List all available remote plugins
aliyun plugin list-remote

# Search plugins by keyword
aliyun plugin search ecs

# Install a single plugin
aliyun plugin install --names ecs

# Install multiple plugins at once
aliyun plugin install --names ecs rds vpc

# Install specific version
aliyun plugin install --names fc --version 1.0.0
```

### Enable Auto Plugin Installation

```bash
# Enable via command
aliyun configure set --auto-plugin-install true

# Or via environment variable
export ALIBABA_CLOUD_CLI_PLUGIN_AUTO_INSTALL=true
```

### Update and Uninstall Plugins

```bash
# Update specific plugin
aliyun plugin update --name ecs

# Update all installed plugins
aliyun plugin update

# Uninstall plugin
aliyun plugin uninstall --name ecs
```

### Plugin Command Format

Plugins use kebab-case naming:

```bash
aliyun <ProductCode> <command> [--parameter-name value ...]

# Example: Query ECS regions
aliyun ecs describe-regions --accept-language en-US

# Example: Query ECS instances
aliyun ecs describe-instances --biz-region-id cn-hangzhou
```

### Common Plugin Commands

| Command | Description |
|---------|-------------|
| `aliyun plugin list` | List installed plugins |
| `aliyun plugin list-remote` | List remote available plugins |
| `aliyun plugin search <keyword>` | Search plugin by keyword |
| `aliyun plugin install --names <name>` | Install plugin |
| `aliyun plugin update [--name <name>]` | Update plugin |
| `aliyun plugin uninstall --name <name>` | Uninstall plugin |

## Checking CLI Support for Unlisted Products

When the product you need to operate is not explicitly covered in this skill, or you encounter "command not found" errors, follow this SOP:

### SOP Flow

```bash
# Step 1: Check if the product provides CLI support
aliyun plugin list-remote

# Step 2: Search for the plugin by product name
aliyun plugin search <product-keyword>
# Example: Search for DMS product
aliyun plugin search dms

# Step 3: Install the confirmed plugin
aliyun plugin install --names <plugin-name>
# Example: Install DMS plugin
aliyun plugin install --names dms

# Step 4: Check supported operations via --help
<product-code> <command> --help
# Example: View DMS supported operations
aliyun dms --help
```

### Full Example: Check DMS Product CLI Support

```bash
# Step 1: List all available plugins to find target product
aliyun plugin list-remote | grep -i dms

# Step 2: Install DMS plugin
aliyun plugin install --names dms

# Step 3: View DMS plugin supported commands
aliyun dms --help

# Step 4: Execute specific operations based on help output
aliyun dms <specific-command> --help
```

### Notes

- **Plugin installation is on-demand**: Only after installing the corresponding plugin can you use that product's CLI commands
- **Plugin naming convention**: Plugin names are usually lowercase versions of product names (e.g., `ecs`, `rds`, `dms`)
- **Auto-install feature**: Enable command auto plugin installation via `aliyun configure set --auto-plugin-install true`
- **Version compatibility**: Some plugins may require specific CLI versions. Update CLI if necessary.

### FAQ

| Problem | Solution |
|---------|----------|
| `plugin list-remote` returns empty | Check network connection or update CLI to latest version |
| Cannot find target product plugin | The product may not yet support CLI plugins. Contact Alibaba Cloud. |
| Plugin installation failed | Check if plugin name is correct and CLI version supports plugins |
| Commands still unavailable after install | Reopen terminal window or check if plugin installed successfully |

---

## Handling Queries Requiring Region But Region Not Specified

> **Scope**: This SOP applies to all Alibaba Cloud product query operations that require a RegionId parameter, not limited to ECS.

When a query operation requires a `RegionId` but the customer hasn't provided a specific region, follow this flow:

### SOP Flow

```bash
# Step 1: Ask user to confirm region
# Inquire which region they need to operate in

# Step 2: If user is unsure, list available regions (ECS universal interface)
aliyun ecs DescribeRegions --accept-language en-US

# For other products, you can also use ECS interface to get Region list
aliyun ecs DescribeRegions --output json | jq -r '.Regions.Region[].RegionId'
```

### Query Across Multiple Regions

When you need to query multiple regions or are unsure about the specific region, iterate through all available regions:

```bash
# Step 1: Get all Region list
REGIONS=$(aliyun ecs DescribeRegions --output json | jq -r '.Regions.Region[].RegionId')

# Step 2: Iterate through each Region to execute query
for REGION in $REGIONS; do
    echo "=== Region: $REGION ==="
    # RDS instance query example
    aliyun rds DescribeDBInstances --RegionId "$REGION"
done
```

### Full Examples

**Scenario 1: Query ECS instances without specified region**

```bash
# List all available regions (for user confirmation)
aliyun ecs DescribeRegions --accept-language en-US --output table

# Execute query based on user's selected region
aliyun ecs DescribeInstances --RegionId cn-hangzhou --output table

# Or iterate all regions (if user needs all data)
for region in cn-hangzhou cn-beijing cn-shanghai; do
    echo "=== Region: $region ==="
    aliyun ecs DescribeInstances --RegionId "$region" --output table
done
```

**Scenario 2: Query RDS instances without specified region**

```bash
# Get Region list first
aliyun ecs DescribeRegions --accept-language en-US --output table

# Query RDS instances for specified region
aliyun rds DescribeDBInstances --RegionId cn-hangzhou --output table
```

**Scenario 3: Query VPC resources without specified region**

```bash
# VPC resource queries also require Region
aliyun vpc DescribeVpcs --RegionId cn-hangzhou --output table
aliyun vpc DescribeVSwitches --RegionId cn-hangzhou --output table
```

### Notes

- **Region query interface is unified**: Available region list for all Alibaba Cloud products is obtained via `ecs DescribeRegions` interface
- **RegionId naming convention**: Alibaba Cloud RegionId is usually `cn-xxx` (China) or `ap-xxx`/`us-xxx` (International) format
- **Global vs China**: Alibaba Cloud has multiple endpoints. Global Region (International Site) and China Region (Aliyun) may require different credentials
- **Query limitations**: Iterating multi-region queries may take longer. Use `--pager` option to aggregate paginated results
- **Result output format**: Using `--output table` displays results more intuitively for user review

---

## Major Cloud Product Codes

| Product | Code | Product | Code |
|---------|------|---------|------|
| Elastic Compute Service (ECS) | ecs | Object Storage Service (OSS) | oss (ossutil) |
| Virtual Private Cloud (VPC) | vpc | Server Load Balancer (SLB) | slb |
| Relational Database Service (RDS) | rds | PolarDB | polardb |
| Container Service for Kubernetes (ACK) | cs | Function Compute (FC) | fc |
| Resource Access Management (RAM) | ram | Security Token Service (STS) | sts |
| Cloud Monitor (CMS) | cms | Log Service (SLS) | sls |
| Data Management (DMS) | dms | DevOps | devops |

## Operation Guide

### ECS Operations

See scripts in `scripts/ecs/` directory:

- `list-instances.sh` - List instances
- `create-instance.sh` - Create instance
- `start-instance.sh` - Start instance
- `stop-instance.sh` - Stop instance
- `create-image.sh` - Create image
- `migrate-instance.sh` - Cross-region migration

### OSS Operations

OSS uses built-in ossutil tool:

```bash
# List Buckets
aliyun ossutil ls

# Upload file
aliyun ossutil cp local-file oss://bucket/path/

# Download file
aliyun ossutil cp oss://bucket/path/file ./

# Sync directory
aliyun ossutil sync ./local-dir oss://bucket/dir/
```

See scripts in `scripts/oss/` directory.

## Troubleshooting

### Common Problems

1. **aliyun command not found**
   - Check PATH environment variable
   - Verify installation path is correct

2. **Invalid credentials**
   - Check if AccessKey is correct
   - Verify RAM user permissions

3. **Network timeout**
   - Check network connection
   - Try increasing timeout with `--read-timeout`

4. **Insufficient permissions**
   - Check RAM policies
   - Verify required API permissions

### Debug Tips

```bash
# Simulate call, view request details
aliyun ecs DescribeInstances --dryrun

# Enable debug logging
aliyun ecs DescribeInstances --debug
```

## Script Usage

This skill provides pre-built scripts in the `scripts/` directory:

```
scripts/
├── install.sh           # CLI installation script
├── configure.sh         # Credential configuration script
├── ecs/
│   ├── list-instances.sh
│   ├── create-instance.sh
│   ├── start-instance.sh
│   ├── stop-instance.sh
│   ├── create-image.sh
│   └── migrate-instance.sh
├── oss/
│   ├── bucket-ops.sh
│   ├── upload.sh
│   ├── download.sh
│   └── sync.sh
└── utils/
    ├── sync-repo.sh     # Repository sync check (execute first)
    ├── output-format.sh
    ├── waiter.sh
    └── error-check.sh
```

When using scripts, modify parameter variables as needed.

## Reference Documentation

Detailed reference documentation is located in `references/` directory:

- [What is Alibaba Cloud CLI](references/01-what-is-alibaba-cloud-cli/what-is-alibaba-cloud-cli.md) - Alibaba Cloud CLI concepts and core features
- [Quick Start](references/02-quick-start/) - Quick start guide
- [Installation Guide](references/03-installation-guide/) - Installation guide
- [Configure Alibaba Cloud CLI](references/04-configure-alibaba-cloud-cli/) - Configure credentials and related settings
- [Using Alibaba Cloud CLI](references/05-using-alibaba-cloud-cli/) - Detailed usage guide
- [Best Practices](references/06-best-practices/) - Best practices
- [Troubleshooting](references/08-troubleshooting/cli-troubleshooting.md) - Troubleshooting guide

Chinese documentation is located in `references/zh/` directory.
