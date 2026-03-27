---
name: support-plan
description: 支持计划客户履约项目进度报告生成工具。从Excel表格获取客户CID列表，批量访问GTS.work获取履约项目成本/时间消耗进度，导出Excel报告。触发词：支持计划、履约项目、进度报告。
---

# support-plan-progress

## Inputs

- **客户清单Excel文件**: 本地Excel文件路径
  - 默认: `/Users/yaohao/agent/工作提效/客户清单/新东区泛企业客户清单.xlsx`
- **工作目录**: 输出文件保存路径
  - 默认: `/Users/yaohao/agent/工作提效/客户清单/`
- **目标日期**: 筛选服务周期包含该日期的项目（默认为当天）

## Outputs

- Excel文件: `履约项目-YYYYMMDD.xlsx`（YYYYMMDD为当日年月日，如20260326）
- 包含列: CID, 客户简称, 项目名称, 服务产品, 服务周期开始日期, 服务周期结束日期, 成本消耗进度, 时间进度, 履约项目URL

## Workflow

### 步骤1: 提取客户数据

从本地Excel文件 `新东区泛企业客户清单.xlsx` 的【支持计划客户】sheet中提取数据:

```bash
python /Users/yaohao/agent/工作提效/客户清单/scripts/extract_customers.py 新东区泛企业客户清单.xlsx customers_list.csv
```

输出: `customers_list.csv`，包含列: CID, 客户简称

### 步骤2: 批量获取履约项目数据

使用browser-agent批量访问，每批处理6个客户（可并行）。

先根据CID查询，筛选出履约项目。CID查询URL: `https://gts.work/toolstack/customer/detail/operationProject?cid={CID}`

**筛选条件**（优先级从高到低）：
1. **优先匹配**：服务周期包含目标日期（开始日期 <= 目标日期 <= 结束日期），且项目名称包含"支持计划"
2. **备选匹配**：如果无优先匹配项，则选择项目名称包含"支持计划"且**履约阶段为"进行中"**的项目
3. **排除项**：排除项目名称包含"主动服务"等其他非支持计划类型

根据项目名称字段的data-row-key获取履约项目ID
URL格式: `https://gts.work/toolstack/tech/public/project/detail/performance?productCode=supportplan&id={履约项目ID}`

**页面重定向处理**:
1. 首次访问上述URL会自动重定向到: `https://gts.work/toolstack/tech/public/project/detail/performance?aiScene=report&id={履约项目ID}&productCode=supportplan&triggerAiAssistant=true`
2. 需要点击 `data-node-key="info"` 的元素（【基础信息】标签）进行跳转
3. 最终页面URL: `https://gts.work/toolstack/tech/public/project/detail/info?id={履约项目ID}&productCode=supportplan`

提取字段:
- 项目名称
- 服务产品
- 服务周期（格式: YYYY-MM-DD ~ YYYY-MM-DD）
- 成本消耗进度（百分比）
- 时间进度（百分比）



### 步骤3: 整理数据并导出Excel

将收集的数据保存为JSON文件，然后执行:

```bash
python /Users/yaohao/agent/工作提效/客户清单/scripts/export_excel.py data.json 履约项目-YYYYMMDD.xlsx
```
（YYYYMMDD替换为当日年月日，如20260326）

**注意**: 脚本会自动将【服务周期】拆分为【服务周期开始日期】和【服务周期结束日期】两个字段

JSON数据格式示例:
```json
[
  {
    "CID": "88072128",
    "客户简称": "领健",
    "项目名称": "xxx-支持计划",
    "服务产品": "企业支持计划",
    "服务周期": "2024-03-05 ~ 2026-06-30",
    "成本消耗进度": "11.21%",
    "时间进度": "25.27%",
    "履约项目URL": "https://gts.work/toolstack/tech/public/project/detail/performance?id=xxx&productCode=supportplan"
  }
]
```

## 页面结构说明

### GTS.work履约项目页面

页面元素定位:
- 项目卡片: 每个履约项目显示为卡片形式
- 项目名称: 卡片标题
- 服务周期: 格式为 "YYYY-MM-DD ~ YYYY-MM-DD"
- 成本消耗: 显示为百分比进度条，如 "45%"
- 时间进度: 显示为百分比进度条，如 "60%"

无数据提示: 如果客户没有履约项目，页面显示"暂无数据"

## 注意事项

1. **登录要求**: 首次访问GTS.work需要阿里内网登录认证
2. **截图理解**: 使用百炼 qwen3.5-plus 模型解析页面截图，API Key 从环境变量 `DASHSCOPE_API_KEY` 读取
3. **项目名称过滤**: 优先保留名称包含"支持计划"且服务周期包含目标日期的项目；如无，则选择名称包含"支持计划"且履约阶段为"进行中"的项目
4. **日期筛选**: 优先提取服务周期包含当天日期的项目
5. **备选规则**: 对于服务周期已结束但履约阶段仍为"进行中"的支持计划项目，也应纳入统计
6. **无数据处理**: 对于没有符合条件项目的客户，记录为"-"
7. **批量处理**: 建议每批处6个客户并行处理，避免请求过于密集
8. **成本超支**: 部分客户成本消耗可能超过100%，属正常情况
9. **权限问题**: 部分客户可能因权限限制无法访问，记录为"-"

## 示例输出

| CID | 客户简称 | 项目名称 | 服务产品 | 服务周期开始日期 | 服务周期结束日期 | 成本消耗进度 | 时间进度 | 履约项目URL | 更新时间 |
|-----|---------|---------|---------|-----------------|-----------------|-------------|---------|-------------|----------|
| 88072128 | 领健 | 上海领健-支持计划 | 企业支持计划 | 2024-03-05 | 2026-06-30 | 11.21% | 25.27% | https://gts.work/toolstack/tech/public/project/detail/performance?id=xxx | 2026-03-26 |
| 24706422 | 复星 | 上海复星-顶级支持计划 | 顶级支持计划 | 2022-03-04 | 2025-10-30 | 108.79% | 58.79% | https://gts.work/toolstack/tech/public/project/detail/performance?id=xxx | 2026-03-26 |
| 29367362 | 美年 | - | - | - | - | - | - | - | 2026-03-26 |

## 依赖

- Python 3.x
- pandas
- openpyxl (Excel读写)
- browser-agent (浏览器自动化)

## 工具脚本

**extract_customers.py**: 从本地Excel文件提取客户数据
```bash
python /Users/yaohao/agent/工作提效/客户清单/scripts/extract_customers.py <excel_file> [output_csv]
```

**export_excel.py**: 将履约项目数据导出为Excel报告
```bash
python /Users/yaohao/agent/工作提效/客户清单/scripts/export_excel.py <json_file> [output_xlsx]
```
