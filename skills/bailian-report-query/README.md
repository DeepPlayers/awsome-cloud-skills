# 百炼平台报表查询 Skill

## 简介

这是一个专门用于查询百炼平台报表数据的 Qoder Skill，通过 ChatBI 开放 API 实现指标数据的快速查询。

## 支持的报表

本 Skill **仅支持**以下两个报表页面的查询：

### 1. 用户模型调用计量
- **URL**: https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1315847
- **资源 ID**: 1315847
- **主要指标**: 模型调用量（token 用量）
- **典型场景**: 查询用户/模型的 token 用量统计

### 2. 用户模型调用次数-日
- **URL**: https://fbi.alibaba-inc.com/fbi/pro/5611/view.htm?pageId=1706516
- **资源 ID**: 1706516
- **主要指标**: 调用总数、成功率、状态码分布、限流情况
- **典型场景**: 查询调用次数、成功率、网关统计

## 安装位置

本 Skill 已安装到个人技能目录：
```
~/.qoder/skills/bailian-report-query/
```

## 文件结构

```
bailian-report-query/
├── SKILL.md              # Skill 主文件（指令和说明）
├── config.yaml           # ChatBI 配置文件
├── requirements.txt      # Python 依赖
└── scripts/              # 执行脚本
    ├── chat_bi_session.py     # 会话管理
    ├── create_chat.py         # 提交问题
    ├── query_chat_result.py   # 轮询结果
    ├── search_report.py       # URL 解析
    └── utils.py               # 公共工具
```

## 使用方法

在 Qoder 中直接提问即可自动触发此 Skill，例如：

- "用户id：1781574661016173昨天模型调用量最高的前5个模型是哪些？"
- "查询昨天用户id为1781574661016173的调用总数和成功率"
- "最近7天qwen3-max模型的调用成功率趋势如何？"

## 能力边界

### ✅ 支持
- 指标值查询（调用量、调用次数、成功率等）
- 维度筛选和聚合（按用户、模型、时间等）
- 排序和 TopN 查询
- 同环比数据查询

### ❌ 不支持
- 复杂的数据洞察分析、归因分析、异动分析
- 数据趋势深度解读、报表解读
- 生成数据报告（网页报告、数字文档、ppt 等）
- 查询除上述两个页面外的其他报表

## 依赖环境

- Python 3
- 依赖包：`pip install -r requirements.txt`

## 配置说明

配置文件 `config.yaml` 包含：
- 服务域名：https://fbi.alibaba-inc.com
- 应用认证信息（app_name, app_secret）
- 员工 ID 和助手 ID
- 查询模式（quick/think）
- 结果格式（markdown/json）

## 工作流程

1. **确认报表** - 验证是否为支持的两个报表页面
2. **解析 URL**（可选）- 从 URL 提取资源 ID
3. **管理会话** - 自动创建或复用 ChatBI 会话
4. **提交问题** - 向 ChatBI 发送查询请求
5. **轮询结果** - 异步获取并展示查询结果

## 注意事项

1. 数据为 T+1 更新，最新数据为昨天
2. 会话创建超过 1 小时后自动失效
3. 轮询最大等待时间为 30 分钟
4. 建议轮询间隔为 3 秒，避免请求过于频繁

## 与其他 Skill 的区别

- **fbi_ask_data**: 通用的 FBI 报表查询，支持任意报表和数据集
- **bailian-report-query**（本 Skill）: 专门针对百炼平台的两个核心报表优化，提供更精准的查询能力

## 维护和更新

如需更新 Skill 版本或修改配置，请编辑：
- `SKILL.md` - 更新版本号和功能说明
- `config.yaml` - 修改认证信息或查询参数

## 许可证

内部使用，请勿外传。
