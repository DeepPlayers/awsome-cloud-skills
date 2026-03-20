# cloudskill-cli

CLI to install cloud skills (Alibaba Cloud CLI, AWS CLI) for AI coding assistants.

## Installation

```bash
npm install -g cloudskill-cli
# or
bun install -g cloudskill-cli
```

## Usage

```bash
# Install skill to specific AI IDE (default: current directory ./{.ai}/skills/)
cloudskill init --ai claude           # Claude Code
cloudskill init --ai qoder            # Qoder
cloudskill init --ai cursor           # Cursor
cloudskill init --ai windsurf        # Windsurf
cloudskill init --ai copilot         # GitHub Copilot
cloudskill init --ai kiro             # Kiro
cloudskill init --ai roocode          # Roo Code
cloudskill init --ai gemini           # Gemini CLI
cloudskill init --ai trae             # Trae
cloudskill init --ai opencode         # OpenCode
cloudskill init --ai continue         # Continue
cloudskill init --ai all              # All AI IDEs

# Install to global home directory (~/.qoder/skills)
cloudskill init --ai qoder --global

# Install to specified project directory
cloudskill init --ai qoder --path /path/to/project

# Specify cloud provider
cloudskill init --provider alibaba-cloud --ai claude  # Alibaba Cloud (default)
cloudskill init --provider aws --ai claude            # AWS
cloudskill init --provider all --ai claude            # All providers

# Options
cloudskill init --force               # Overwrite existing files
cloudskill init --offline             # Skip GitHub download
cloudskill init --legacy              # Use ZIP-based installation

# Other commands
cloudskill versions                   # List available versions
cloudskill update                     # Update to latest version
cloudskill update --ai claude         # Update for specific AI
```

## Installation Modes

| Mode | Command | Target Path |
|------|---------|-------------|
| Local (default) | `cloudskill init --ai qoder` | `./.qoder/skills/` |
| Global | `cloudskill init --ai qoder --global` | `~/.qoder/skills/` |
| Custom Path | `cloudskill init --ai qoder --path /path/to/project` | `/path/to/project/.qoder/skills/` |

## Supported AI IDEs

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

## Supported Cloud Providers

| Provider | Description |
|----------|-------------|
| `alibaba-cloud` | Alibaba Cloud CLI skill (default) |
| `aws` | AWS CLI skill |
| `all` | All cloud providers |

## How It Works

By default, `cloudskill init` copies skills from the bundled source directory to the specified AI IDE's configuration folder. When using `--legacy` flag, it tries to download the latest release from GitHub first, falling back to bundled assets if the download fails.

## Development

```bash
# Install dependencies
bun install

# Run locally
bun run src/index.ts --help

# Build
bun run build

# Link for local testing
bun link
```

## License

MIT
