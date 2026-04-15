---
name: bailian-report-query
version: "1.0.0"
description: |
  百炼平台报表查询技能，支持查询用户模型调用计量和调用次数统计。
  仅支持两个报表页面：
  - 页面1（用户模型调用计量）：https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1315847
  - 页面2（用户模型调用次数-日）：https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1706516
  适用场景：
  - 查询指定用户/时间的模型调用量（token 用量）
  - 查询指定用户/时间的模型调用次数、成功率、状态码分布
  - 按模型、用户、时间等维度筛选和聚合查询
  - 查询调用成功率趋势、限流情况、网关统计指标
  不适用场景：
  - 复杂的数据洞察分析、归因分析、异动分析（请使用 fbi_data_analysis 技能）
  - 数据趋势深度解读、报表解读
  - 生成数据报告（网页报告、数字文档、ppt 等）
  - 查询除上述两个页面外的其他报表
  功能支持：通过 ChatBI 开放 API 提交问题，异步轮询获取结果。支持资源 URL 解析、会话自动管理。
---

# 百炼平台报表查询技能

通过 ChatBI 开放 API 查询百炼平台两个指定报表的指标数据。适用于模型调用量、调用次数、成功率等结构化数据查询。

## 支持的报表页面

### 页面1：用户模型调用计量

**URL**: `https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1315847`

**资源 ID**: `1315847`  
**资源类型**: `report`

**主要查询维度**：
- 用户 ID（用户id）
- 模型名称（模型）
- 时间范围（日期，T+1 更新）
- 用量（token 调用量）

**典型查询场景**：
- 某用户某天的模型调用量 Top N
- 某模型在指定时间的总用量
- 按用户/模型维度的用量统计

### 页面2：用户模型调用次数-日

**URL**: `https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1706516`

**资源 ID**: `1706516`  
**资源类型**: `report`

**主要查询维度**：
- 用户 ID（用户id）
- 模型名称（模型）
- 时间范围（日期，T+1 更新）

**主要指标字段**：
- 调用总数
- 非限流调用总数
- 调用成功数200
- 成功率200
- 成功数200+4xx-429
- 成功率200+4xx-429
- 调用用户数
- 调用模型数
- 成功率趋势
- 状态码分布

**典型查询场景**：
- 某用户某天的调用次数及成功率
- 某模型的调用成功率和限流情况
- 调用状态码分布分析
- 网关统计指标查询

## 前置条件

> **⚠️ 环境依赖：本技能的所有脚本均为 Python 编写，执行前必须确保当前环境已安装 Python 3。**
> 可通过 `python3 --version` 或 `python --version` 检查是否已安装。
> 若未安装，请先安装 Python 3 环境，并通过 `pip install -r requirements.txt` 安装所需依赖包。

### 认证配置

本技能支持**三种认证方式**（按优先级）：

1. **FBI 接口动态获取**（推荐）
   - 前提：已在浏览器中登录 FBI 系统
   - 系统会自动从接口获取最新认证信息
   - 缓存有效期：30 分钟

2. **环境变量**（CI/CD 场景）
   - 设置 `use_env_property: true` in config.yaml
   - 配置 `ACCESS_TOKEN` 环境变量

3. **本地配置文件**（降级方案）
   - 在 `config.yaml` 中手动填写认证信息
   - 适用于无法访问 FBI 接口的场景

> **首次使用指南：**
> 1. 在浏览器中访问：https://fbi.alibaba-inc.com/ai/FbiCopilotAssistantAction/queryChatBISkillProperty
> 2. 完成登录认证
> 3. 系统会自动获取并缓存认证信息
> 4. 如需手动刷新认证：`python scripts/auth_manager.py --refresh`

## 工作流程

> **⚠️ 关键规则：每条命令都必须以 `cd <技能安装绝对路径>/scripts && ` 开头。**
> 每条 shell 命令都是独立进程，前一条命令的 `cd` 不会影响后一条命令的工作目录。
> 如果不加 `cd` 前缀，会因为找不到脚本文件而报错 `No such file or directory`。
> 下文所有示例中的 `cd scripts` 均需替换为技能安装的实际绝对路径。

按以下步骤顺序执行：

### Step 1：确认报表页面

本技能**仅支持**以下两个报表页面：

1. **用户模型调用计量**：`https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1315847`
2. **用户模型调用次数-日**：`https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1706516`

如果用户提供的 URL 不是这两个页面，**必须明确告知用户**：
```
抱歉，本技能仅支持以下两个报表页面的查询：
1. 用户模型调用计量：https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1315847
2. 用户模型调用次数-日：https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1706516

请确认您要查询的报表是否在上述列表中。如需查询其他报表，请使用 fbi_ask_data 技能。
```

如果用户直接提供了问题但未指定报表，根据查询内容自动选择：
- 查询**调用量/用量/token**相关 → 使用页面1（1315847）
- 查询**调用次数/成功率/状态码**相关 → 使用页面2（1706516）

### Step 2：解析资源 URL（可选）

当用户提供了 FBI 资源 URL 时，解析获取资源 ID 和资源类型。若用户已直接提供资源 ID 或未涉及资源关联，可跳过此步骤。

运行 `search_report.py` 解析资源 URL：

```bash
cd scripts && python search_report.py "<资源URL>"
```

**支持的 URL 示例**：
- 页面1：`https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1315847`
- 页面2：`https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1706516`

从返回结果中获取 `resource_id` 和 `resource_type`，用于 Step 4 提交问题时关联资源。

### Step 3：获取或创建会话

```bash
# 获取或创建会话（自动从 chat_bi_session_id.md 读取或创建新会话）
cd scripts && python chat_bi_session.py [会话名称]

# 清除已有会话，强制创建新会话
cd scripts && python chat_bi_session.py --clear
```

**说明**：
- 会话 ID 自动持久化到 `../chat_bi_session_id.md`
- 首次运行自动创建新会话并保存
- 后续运行自动复用已有会话（会话创建超过 1 小时后自动失效）

### Step 4：提交问题

```bash
# 基础用法
cd scripts && python create_chat.py "<用户问题>"

# 关联资源（报表），资源信息为 JSON 格式
cd scripts && python create_chat.py "<用户问题>" '{"resourceId": "<id>", "resourceType": "report"}'
```

**资源类型说明**：

| resourceType | 说明  | 示例                                                    |
|-------------|-----|-------------------------------------------------------|
| `report`    | 报表  | `'{"resourceId": "1315847", "resourceType": "report"}'`   |

**输出示例**：

```
正在提交问题：用户id：1781574661016173昨天模型调用量最高的前5个模型是哪些？
关联资源：1315847（类型：report）
提交成功！
answerMessageId: 698a514b4fef43c896678fad642dc07c
questionMessageId: cd2a96fb896041bfbff8208ba9b0daaa
```

### Step 5：轮询获取结果

```bash
# 基础用法
cd scripts && python query_chat_result.py "<answerMessageId>"

# 指定轮询间隔（秒）
cd scripts && python query_chat_result.py "<answerMessageId>" "5"
```

**说明**：
- 默认轮询间隔 3 秒
- 最大等待时间 30 分钟
- 实时打印思考过程

## 完整示例

### 示例 1：查询用户模型调用量 Top 5

```bash
# Step 2: 通过 URL 解析资源 ID
cd scripts && python search_report.py "https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1315847"
# 输出：resource_id: 1315847, resource_type: report

# Step 3: 创建会话
cd scripts && python chat_bi_session.py

# Step 4: 提交问题并关联报表
cd scripts && python create_chat.py "用户id：1781574661016173昨天模型调用量最高的前5个模型是哪些？" '{"resourceId": "1315847", "resourceType": "report"}'
# 输出：answerMessageId: xxx

# Step 5: 轮询结果
cd scripts && python query_chat_result.py "xxx"
```

### 示例 2：查询用户调用次数和成功率

```bash
# Step 3: 创建会话
cd scripts && python chat_bi_session.py

# Step 4: 提交问题并关联调用次数报表
cd scripts && python create_chat.py "用户id：1781574661016173昨天的调用总数和成功率是多少？" '{"resourceId": "1706516", "resourceType": "report"}'

# Step 5: 轮询结果
cd scripts && python query_chat_result.py "<answerMessageId>"
```

### 示例 3：查询模型调用状态码分布

```bash
# Step 3: 创建会话
cd scripts && python chat_bi_session.py

# Step 4: 提交问题
cd scripts && python create_chat.py "昨天qwen3-max模型的调用状态码分布情况" '{"resourceId": "1706516", "resourceType": "report"}'

# Step 5: 轮询结果
cd scripts && python query_chat_result.py "<answerMessageId>"
```

## 提问最佳实践

提交问数问题时，建议按以下范式组织问题，以获得最准确的查询结果：

**提问范式：** `【时间范围】内，【筛选条件】下，【指标】按【聚合方式】统计，按【分组维度】展示，【对比方式】，【排序/TopN】`

**最佳提问示例**：

1. **查调用量**  
   `用户id：1781574661016173昨天模型调用量最高的前5个模型是哪些？`

2. **查调用次数**  
   `查询昨天用户id为1781574661016173的调用总数和成功率。`

3. **查成功率趋势**  
   `最近7天qwen3-max模型的调用成功率趋势如何？`

4. **查状态码分布**  
   `昨天qwen3.6-plus模型的调用状态码分布情况。`

5. **多条件组合查询**  
   `查询2024年3月内，用户id=1781574661016173下，各模型的调用总数按降序排列，返回前10名。`

## 重要提示

1. **不要重复创建任务**：ChatBI 问答是耗时任务，同一个问题获取到 `answerMessageId` 后，后续应使用该 ID 轮询，而非重新调用 `create_chat`

2. **轮询间隔**：建议设置为 **3 秒**，避免请求过于频繁

3. **超时判定**：轮询总时间超过 **30 分钟** 仍未返回结果则认为失败

4. **版本校验**：`chat_bi_session.py` 和 `create_chat.py` 执行时会自动校验技能版本。若提示版本过期，请提示用户重新下载最新的技能包并安装

5. **数据更新**：报表数据为 T+1 更新，最新数据为昨天（当前日期 - 1 天）

6. **能力边界**：
   - ✅ 支持：指标值查询、维度筛选聚合、排序、TopN、同环比
   - ❌ 不支持：复杂数据洞察、归因分析、异动分析、生成报告
   - ❌ 不支持：除页面1和页面2外的其他报表查询

## 处理建议

1. **会话管理**：使用 `chat_bi_session.py` 自动管理会话，无需手动维护会话 ID
2. **结果保存**：重要查询结果建议保存 `answerMessageId`，便于后续追溯
3. **结果展示**：最终结果中的详细执行过程 url 请在对话中展示给用户
4. **不支持的查询**：对于无法查询的条件或超出能力边界的请求，必须明确告知用户限制原因
