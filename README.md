# Awesome Cloud Skills

A collection of cloud service operation skills, providing CLI operation SOPs, scripts, and reference documentation for major cloud providers.

## Project Structure

```
.
├── alibaba-cloud/          # Alibaba Cloud Skills
│   ├── SKILL.md            # Skill definition file
│   ├── references/         # Reference documentation
│   └── scripts/            # Operation scripts
│       ├── ecs/            # ECS instance operations
│       ├── oss/            # OSS storage operations
│       └── utils/          # Utility functions
```

## Alibaba Cloud CLI Skill

Provides complete operation SOP for Alibaba Cloud CLI, including:

### Quick Start

```bash
# Check if installed
aliyun version

# macOS installation
brew install aliyun-cli

# Linux installation
/bin/bash -c "$(curl -fsSL https://aliyuncli.alicdn.com/install.sh)"

# Configure credentials
aliyun configure
```

### Key Features

| Feature | Description |
|---------|-------------|
| ECS Management | Instance creation, start/stop, image creation, cross-region migration |
| OSS Operations | Bucket management, file upload/download, directory sync |
| Credential Management | Multi-credential configuration, RAM roles, environment variables |
| Output Formatting | JSON/table output, result filtering |
| Auto Sync | Automatic remote repository update check before skill invocation |

### Common Commands

```bash
# Query ECS instances
aliyun ecs DescribeInstances --RegionId cn-hangzhou

# List available plugins
aliyun plugin list-remote

# Install plugins
aliyun plugin install --names ecs
```

### Checking CLI Support for Unlisted Products

When the product you need to operate is not explicitly covered in this skill, or you encounter "command not found" errors, follow this SOP:

```bash
# Step 1: Check if the product provides CLI support
aliyun plugin list-remote

# Step 2: Search for the plugin by product name
aliyun plugin search <product-keyword>

# Step 3: Install the confirmed plugin
aliyun plugin install --names <plugin-name>

# Step 4: Check supported operations via --help
aliyun <product-code> --help
```

**Example - Check DMS product CLI support:**

```bash
# Search and install DMS plugin
aliyun plugin search dms
aliyun plugin install --names dms

# Check available commands
aliyun dms --help
```

### Handling Queries Without Specified Region

> **Scope**: This SOP applies to all Alibaba Cloud products that require a RegionId parameter, not limited to ECS.

When a query operation requires a `RegionId` parameter but the customer hasn't specified a region, follow this SOP:

```bash
# Step 1: Ask the user to confirm the region
# Inquire which region they want to operate in

# Step 2: If the user is unsure, list available regions (ECS provides universal region listing)
aliyun ecs DescribeRegions --accept-language en-US

# For other products, use the same ECS interface to get Region list
aliyun ecs DescribeRegions --output json | jq -r '.Regions.Region[].RegionId'
```

**Query across multiple regions:**

```bash
# Get all available regions
REGIONS=$(aliyun ecs DescribeRegions --output json | jq -r '.Regions.Region[].RegionId')

# Iterate through each region
for REGION in $REGIONS; do
    echo "=== Region: $REGION ==="
    # RDS instance query example
    aliyun rds DescribeDBInstances --RegionId "$REGION"
done
```

**Examples for different products:**

```bash
# ECS instances
aliyun ecs DescribeInstances --RegionId cn-hangzhou --output table

# RDS instances
aliyun rds DescribeDBInstances --RegionId cn-hangzhou --output table

# VPC resources
aliyun vpc DescribeVpcs --RegionId cn-hangzhou --output table
```

## Auto Sync Mechanism

When an Agent invokes this skill, it automatically checks for remote repository updates:

- Remote repository: `http://gitlab.alibaba-inc.com/ez-tam-ai/awsome-cloud-skills.git`
- Auto-configures remote repository (if not configured)
- Auto-syncs latest updates (if no conflicts)
- Skips sync and alerts user on conflicts

See the "Pre-execution: Repository Sync Check" section in [alibaba-cloud/SKILL.md](alibaba-cloud/SKILL.md).

## Reference Documentation

Detailed documentation is located in the `alibaba-cloud/references/` directory:

- [What is Alibaba Cloud CLI](alibaba-cloud/references/01-什么是阿里云CLI/)
- [Quick Start](alibaba-cloud/references/02-快速入门/)
- [Installation Guide](alibaba-cloud/references/03-安装指南/)
- [Configure Alibaba Cloud CLI](alibaba-cloud/references/04-配置阿里云CLI/)
- [Using Alibaba Cloud CLI](alibaba-cloud/references/05-使用阿里云CLI/)
- [Best Practices](alibaba-cloud/references/06-最佳实践/)
- [Troubleshooting](alibaba-cloud/references/08-错误排查/)

## Scripts

Operation scripts are located in the `alibaba-cloud/scripts/` directory:

```
scripts/
├── install.sh           # CLI installation script
├── configure.sh         # Credential configuration script
├── ecs/
│   ├── list-instances.sh    # List instances
│   ├── create-instance.sh   # Create instance
│   ├── start-instance.sh    # Start instance
│   ├── stop-instance.sh     # Stop instance
│   ├── create-image.sh      # Create image
│   └── migrate-instance.sh  # Cross-region migration
├── oss/
│   ├── bucket-ops.sh    # Bucket operations
│   ├── upload.sh        # Upload files
│   ├── download.sh      # Download files
│   └── sync.sh          # Sync directory
└── utils/
    ├── sync-repo.sh     # Repository sync check (execute first)
    ├── output-format.sh # Output formatting
    ├── waiter.sh        # Wait utility
    └── error-check.sh   # Error checking
```

## License

Apache License 2.0 - see [LICENSE](LICENSE) file for details.
