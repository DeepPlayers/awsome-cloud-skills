---
name: happy-horse-cli
description: HappyHorse 视频生成工具，基于阿里云百炼平台 happyhorse-1.0 系列模型，支持图生视频(i2v)、文生视频(t2v)、参考生视频(r2v)、视频编辑(edit)和批量并发生成(batch)五种模式。batch 模式支持同时生成多个视频，默认最大并发数 10。自动处理本地媒体文件上传（通过 oss2 SDK 上传到 OSS）、异步任务轮询和视频下载。配置一次，永久使用（API Key 和 OSS 信息保存到 ~/.happy-horse.env）。Use when user asks to generate video with HappyHorse, create image-to-video, text-to-video, reference-to-video, batch video generation, or edit videos using 百炼 platform. Do NOT use for: prompt 文案优化（请使用 ai-movie-prompt-optimizer skill）、非 HappyHorse 模型的视频生成、视频剪辑/合并等后期处理。局限性：视频生成为异步任务，通常耗时 1-5 分钟；本地文件上传依赖 oss2 和 OSS 配置；不支持视频拼接和后期剪辑。
hooks:
  PreToolUse:
    - matcher: "(bash.*happyhorse\\.sh|python3.*happyhorse\\.py)"
      type: "command"
      command: "${SKILL_ROOT}/scripts/hook_confirm.sh"
      statusMessage: "即将提交视频生成任务（可能产生 API 费用），是否确认？"
    - matcher: "(bash.*save-env\\.sh|python3.*happyhorse\\.py.*config)"
      type: "command"
      command: "${SKILL_ROOT}/scripts/hook_confirm.sh"
      statusMessage: "即将保存 API 凭证到本地配置文件，是否确认？"
---

# HappyHorse 视频生成

> 本 skill 适用于 Qoder以及其他Agent 平台，需要 python3.8+、oss2、requests 环境支持。

> **免责声明**：AI 生成的视频内容仅供参考，发布前请确认内容合规性。每次视频生成会消耗百炼平台 API 配额，提交任务前请确认操作。

基于百炼平台 `happyhorse-1.0` 系列模型，一键生成 AI 视频。

---

## Prerequisites

- **运行时**：python3.8+
- **Python 库**：`oss2` `requests`（运行 `pip3 install oss2 requests` 安装）
- **API 凭证**：百炼平台 `DASHSCOPE_API_KEY`
- **OSS 配置**（上传本地文件时必填）：`OSS_ACCESS_KEY_ID`、`OSS_ACCESS_KEY_SECRET`、`OSS_BUCKET`、`OSS_REGION`

---

## Required Permissions

| 权限 | 类型 | 用途 | 需确认 |
|------|------|------|--------|
| DashScope API 调用 | 写 | 提交视频生成任务（消耗 API 配额/费用） | **是** |
| DashScope Task 查询 | 读 | 轮询任务状态 | 否 |
| OSS 文件上传 | 写 | 上传本地媒体文件到 OSS | **是** |
| OSS 预签名 URL | 读 | 生成临时访问链接 | 否 |
| 本地文件读取 | 读 | 读取用户图片/视频/prompt 文件 | 否 |
| 凭证写入 | 写 | 将 API Key / OSS 密钥保存到 ~/.happy-horse.env | **是** |

---

## MCP 工具清单

| 中文名 | 工具 ID / 库 | 用途 |
|--------|-------------|------|
| OSS 文件管理 | oss2 (Python SDK) | 上传本地文件到 OSS 并生成预签名 URL |
| 视频生成 API | DashScope API (requests) | 提交 i2v/t2v/r2v/edit 任务 |
| 任务状态查询 | DashScope Task API (requests) | 轮询异步任务状态 |
| JSON 构建 | json (stdlib) | 构建 API 请求体，正确转义特殊字符 |
| 视频下载 | requests | 下载生成的视频文件 |

---

## 安全红线

- **禁止**在终端日志、输出信息中暴露完整 API Key 或 AK/SK
- **禁止**未经用户确认直接提交付费 API 任务
- **禁止**未经用户确认将本地文件上传到 OSS（数据外传）
- **禁止**未经用户确认安装 Python 依赖（如 pip3 install oss2 requests）
- **禁止**将 `~/.happy-horse.env` 的内容打印到对话中

---

## 脚本位置

- 主脚本（Python）：`.qoder/skills/happy-horse/scripts/happyhorse.py`
- 主脚本（Bash 旧版）：`.qoder/skills/happy-horse/scripts/happyhorse.sh`
- 环境检查（Bash 旧版）：`.qoder/skills/happy-horse/scripts/check-setup.sh`
- 保存配置（Bash 旧版）：`.qoder/skills/happy-horse/scripts/save-env.sh`
- OSS 安装参考：`.qoder/skills/happy-horse/references/ossutils-quick.md`

---

## 首次使用流程

### Step 1：安装依赖

```bash
pip3 install oss2 requests
```

### Step 2：检查环境

```bash
python3 .qoder/skills/happy-horse/scripts/happyhorse.py check
```

查看输出，确认：
- **oss2 / requests**：Python 依赖是否已安装
- **DASHSCOPE_API_KEY**：百炼 API Key
- **OSS 配置**：上传本地文件时需要

### Step 3：保存缺失配置

向用户询问缺失的配置项，**明确告知将写入本地文件 `~/.happy-horse.env`**，确认后保存：

```bash
# 保存 API Key（必填）
python3 .qoder/skills/happy-horse/scripts/happyhorse.py config --set \
  DASHSCOPE_API_KEY=sk-xxxxxxxx

# 保存 OSS 配置（上传本地文件生成公网链接给百炼时必填）
python3 .qoder/skills/happy-horse/scripts/happyhorse.py config --set \
  OSS_ACCESS_KEY_ID=LTAI5t... \
  OSS_ACCESS_KEY_SECRET=xxxxx \
  OSS_BUCKET=my-bucket \
  OSS_REGION=cn-hangzhou
```

> 配置保存在 `~/.happy-horse.env`，chmod 600 保护，之后每次调用自动加载，无需重复提供。

---

## 五种视频模式

### i2v：图生视频

以图片首帧生成视频。支持 URL 或本地图片（本地自动上传 OSS）。

```bash
# URL 图片
python3 .qoder/skills/happy-horse/scripts/happyhorse.py i2v \
  -i "https://example.com/image.png" \
  -p "让画面缓缓流动，烟雾弥漫" \
  -r 720P -d 5

# 本地图片（自动上传 OSS，获得预签名 URL 后调用 API）
python3 .qoder/skills/happy-horse/scripts/happyhorse.py i2v \
  -i ./images/photo.png \
  -p "让马在草原上驰骋" \
  -d 10 --output-dir ./outputs_i2v
```

**参数：**
- `-i` 图片 URL 或本地路径（必填）
- `-p` prompt 文本或 .txt/.md 文件路径
- `-r` 分辨率：`720P` / `1080P`（默认 `1080P`）
- `-d` 时长：`5` / `10` / `15`（默认 `15`）

### t2v：文生视频

纯文字生成视频，无需图片。

```bash
python3 .qoder/skills/happy-horse/scripts/happyhorse.py t2v \
  -p "一只骏马在秋日草原上奔跑，镜头从侧面跟随，金色光线" \
  -r 1080P -d 5 --ratio 16:9
```

**参数：**
- `-p` prompt 文本或文件路径（必填）
- `--ratio` 比例：`16:9`（默认）/ `9:16` / `1:1`

### r2v：参考生视频

用多张参考图生成视频，适合角色/物品一致性场景。支持最多 9 张参考图。

```bash
python3 .qoder/skills/happy-horse/scripts/happyhorse.py r2v \
  -p "身着红色旗袍的女性 图1，镜头侧面中景展现旗袍... 图2 时流苏耳坠摆动..." \
  --ref ./ref-girl.jpg \
  --ref https://example.com/fan.jpg \
  --ref ./ref-earrings.jpg \
  -d 5
```

**参数：**
- `-p` 含 `图1` `图2` 标记的 prompt（必填）
- `--ref` 参考图 URL 或本地路径，可多次指定（1-9 张，必填）

### edit：视频编辑

对已有视频按指令修改，可附加参考图。

```bash
python3 .qoder/skills/happy-horse/scripts/happyhorse.py edit \
  -v "https://example.com/input.mp4" \
  -p "让视频中的角色穿上条纹毛衣" \
  --ref ./sweater.png \
  -r 720P
```

**参数：**
- `-v` 视频 URL 或本地路径（必填）
- `-p` 编辑指令（必填）
- `--ref` 参考图（可选）

### batch：批量并发生成

使用 JSON 配置文件，一次提交多个视频任务，脚本自动并发轮询并下载。**默认最大并发数 10。**

```bash
# 基本用法
python3 .qoder/skills/happy-horse/scripts/happyhorse.py batch \
  --config ./tasks.json

# 自定义并发数
python3 .qoder/skills/happy-horse/scripts/happyhorse.py batch \
  --config ./tasks.json --max-concurrency 5

# 指定输出目录
python3 .qoder/skills/happy-horse/scripts/happyhorse.py batch \
  --config ./tasks.json --output-dir ./outputs
```

**参数：**
- `--config` JSON 配置文件路径（必填）
- `--max-concurrency` 最大并发数（默认 `10`）
- `--output-dir` 输出目录（覆盖 JSON 中的 `output_dir`）

**JSON 配置文件格式：**

```json
{
  "max_concurrency": 10,
  "output_dir": "./outputs",
  "tasks": [
    {
      "mode": "t2v",
      "prompt": "一只猫在草地上奔跑，夕阳逆光",
      "resolution": "720P",
      "duration": 10,
      "ratio": "16:9",
      "output": "cat-running.mp4"
    },
    {
      "mode": "i2v",
      "image": "./images/photo.png",
      "prompt": "让画面中的马缓缓奔跑起来",
      "resolution": "1080P",
      "duration": 15,
      "output": "horse-gallop.mp4"
    },
    {
      "mode": "r2v",
      "prompt": "图1 中角色站立在草原上，微风吹动衣角...",
      "refs": ["./characters/hero.png", "https://example.com/bg.jpg"],
      "resolution": "720P",
      "duration": 10,
      "ratio": "16:9",
      "output": "hero-scene.mp4"
    },
    {
      "mode": "video-edit",
      "video": "./input.mp4",
      "prompt": "让角色穿上红色外套",
      "refs": ["./red-jacket.jpg"],
      "resolution": "720P",
      "output": "edited-video.mp4"
    }
  ]
}
```

**字段说明：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `max_concurrency` | int | 否 | 最大并发数，默认 10 |
| `output_dir` | string | 否 | 全局输出目录，可被每个 task 的 `output` 覆盖 |
| `tasks` | array | 是 | 任务列表 |
| `tasks[].mode` | string | 是 | 模式：`i2v` / `t2v` / `r2v` / `video-edit`（JSON中保持 `video-edit`） |
| `tasks[].prompt` | string | 是(t2v/r2v/video-edit) | prompt 文本或 .txt/.md 文件路径 |
| `tasks[].image` | string | 是(i2v) | 首帧图片 URL 或本地路径 |
| `tasks[].video` | string | 是(video-edit) | 输入视频 URL 或本地路径 |
| `tasks[].refs` | array | 否(r2v可选) | 参考图列表，支持本地路径和 URL |
| `tasks[].resolution` | string | 否 | 分辨率，默认 `720P` |
| `tasks[].duration` | int | 否 | 时长（秒），默认 `15` |
| `tasks[].ratio` | string | 否 | 比例，默认 `16:9` |
| `tasks[].seed` | int | 否 | 随机种子 |
| `tasks[].watermark` | bool | 否 | 是否加水印，默认 false |
| `tasks[].output` | string | 否 | 输出文件名，默认 `output-batch-XXX.mp4` |

**批量模式工作流程：**

1. Python 解析 JSON 配置，验证所有任务
2. Python 逐文件上传本地媒体到 OSS（串行，避免带宽争抢）
3. Python 逐任务提交到百炼 API（提交操作很快，无需并行）
4. **并发轮询**：每次轮询（5s 间隔）检查所有待处理任务状态
5. 任意任务完成即下载视频，失败则记录错误
6. 全部完成（或超时）后输出汇总报告

**进度输出示例：**

```
📋 共 4 个任务待处理
   最大并发: 10

========================================
  提交任务到百炼 API
========================================
🚀 提交任务 [0] t2v...
✅ 任务 [0] 已提交 task_id: abc-123
🚀 提交任务 [1] i2v...
✅ 任务 [1] 已提交 task_id: def-456
...

📊 已提交: 4 / 4 个任务

========================================
  开始并发轮询 4 个任务...
========================================
📊 进度: ✅0 ❌0 ⏳4 / 总计4
📊 进度: ✅1 ❌0 ⏳3 / 总计4
📊 进度: ✅3 ❌0 ⏳1 / 总计4
✅ [0] 完成！./outputs/cat-running.mp4
...

========================================
  批量任务完成: ✅4 ❌0 / 总计4
  输出目录: ./outputs
========================================
```

---

## 通用参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-r/--resolution` | 分辨率 | `1080P` |
| `-d/--duration` | 时长（秒） | `15` |
| `--ratio` | 比例（t2v/r2v） | `16:9` |
| `-s/--seed` | 随机种子 | 无 |
| `-w/--watermark` | 添加水印 | false |
| `-o/--output` | 输出文件路径 | 自动生成 |
| `--output-dir` | 输出目录 | `.` |
| `--clear-cache` | 清理过期的 OSS 上传缓存 | — |

---

## 本地文件上传与缓存机制

### 上传流程

当 `-i`、`-v`、`--ref` 传入本地文件路径时：

1. **查缓存**：检查 `~/.happy-horse-oss-cache.json` 中是否已有该文件的有效预签名 URL
2. 缓存命中 → 直接复用已有 URL（跳过上传），输出 `♻️ 缓存命中` 标记
3. 缓存未命中 → `oss2` SDK 上传 → `bucket.sign_url` 生成 24h 预签名 URL
4. 新生成的 URL 自动写入缓存

### 缓存校验规则

缓存条目被视为"有效"需满足**全部**条件：

| 校验项 | 说明 |
|--------|------|
| 文件存在 | 原始本地文件未被删除 |
| 文件未修改 | mtime 和文件大小与上传时一致 |
| 未过期 | 预签名 URL 仍在 24h 有效期内（预留 10 分钟缓冲） |
| 配置一致 | OSS Bucket / Region 与当前环境变量匹配 |

> 任意条件不满足 → 视为过期，自动重新上传。

### 缓存文件

- **路径**：`~/.happy-horse-oss-cache.json`
- **权限**：chmod 600（仅当前用户可读写）
- **格式**：

```json
{
  "/absolute/path/to/file.png": {
    "oss_path": "oss://bucket/happyhorse/file-20260508.png",
    "presigned_url": "https://bucket.oss-cn-shanghai.aliyuncs.com/...",
    "uploaded_at": 1746697800,
    "expires_at": 1746784200,
    "file_mtime": 1746690000,
    "file_size": 123456,
    "bucket": "my-bucket",
    "region": "cn-shanghai"
  }
}
```

### 清理过期缓存

```bash
# 手动清理所有过期/无效的缓存条目
python3 .qoder/skills/happy-horse/scripts/happyhorse.py clear-cache
```

输出示例：`缓存清理完成: 3 条移除, 5 条保留 (原 8 条)`

> 缓存会在每次上传时自动维护；手动清理仅用于释放磁盘空间或强制重新上传。

**前提：** OSS 配置已保存到 `~/.happy-horse.env`

---

## Agent 工作流程

### 单任务模式

1. 用户提出视频生成需求（描述内容、提供图片/视频）
2. 运行 `python3 happyhorse.py check` 检查环境（只读，可直接执行）
3. 如有缺失配置 → 询问用户 → **告知将写入 `~/.happy-horse.env`，获得确认后** 运行 `python3 happyhorse.py config --set`
4. 如 oss2/requests 未安装 → **告知需要 pip3 install，获得确认后** 执行安装
5. **告知即将消耗 API 配额，获得用户确认后**，根据需求选择模式，运行 `happyhorse.py`
6. 等待轮询完成（最长约 10 分钟），输出视频保存路径

### 批量模式

1. 用户提出批量视频生成需求（如"为 10 个场景各生成一段视频"）
2. 运行 `python3 happyhorse.py check` 检查环境
3. 根据用户需求，创建 JSON 配置文件（使用上述格式）
4. **告知即将消耗 API 配额（N 个任务 × 费用），获得用户确认后**，运行：
   ```bash
   python3 .qoder/skills/happy-horse/scripts/happyhorse.py batch \
     --config ./tasks.json --max-concurrency 10
   ```
5. 脚本自动完成：上传文件 → 提交任务 → 并发轮询 → 下载视频
6. 输出汇总报告（成功/失败数量、文件路径）

---

## 参考

- OSS 安装速查：`.qoder/skills/happy-horse/references/ossutils-quick.md`
