#!/usr/bin/env python3
"""
将履约项目数据导出为Excel报告

用法:
    python scripts/export_excel.py <json_file> [output_xlsx]

参数:
    json_file: 包含履约项目数据的JSON文件
    output_xlsx: 输出Excel文件路径（默认: 支持计划客户履约项目进度.xlsx）

输入JSON格式:
    [
        {
            "CID": "123",
            "客户简称": "领健",
            "项目名称": "xxx-支持计划",
            "服务周期": "2024-03-05 ~ 2026-06-30",
            "成本消耗进度": "11.21%",
            "时间进度": "25.27%"
        },
        ...
    ]
"""

import sys
import json
import pandas as pd


def split_service_period(period_str: str):
    """拆分服务周期为开始日期和结束日期"""
    if period_str == "-" or not period_str or "~" not in period_str:
        return "-", "-"
    
    parts = period_str.split("~")
    if len(parts) == 2:
        return parts[0].strip(), parts[1].strip()
    return "-", "-"


def export_excel(json_file: str, output_xlsx: str = "支持计划客户履约项目进度.xlsx"):
    """将JSON数据导出为Excel"""
    
    # 读取JSON数据
    with open(json_file, 'r', encoding='utf-8') as f:
        all_data = json.load(f)
    
    # 创建DataFrame
    df = pd.DataFrame(all_data)
    
    # 拆分服务周期为两个字段
    if '服务周期' in df.columns:
        df[['服务周期开始日期', '服务周期结束日期']] = df['服务周期'].apply(
            lambda x: pd.Series(split_service_period(x))
        )
        # 删除原服务周期列
        df = df.drop(columns=['服务周期'])
    
    # 调整列顺序：CID, 客户简称, 项目名称, 服务产品, 服务周期开始日期, 服务周期结束日期, 成本消耗进度, 时间进度, 履约项目URL
    column_order = ['CID', '客户简称', '项目名称', '服务产品', '服务周期开始日期', '服务周期结束日期', '成本消耗进度', '时间进度', '履约项目URL']
    # 只保留存在的列
    column_order = [col for col in column_order if col in df.columns]
    df = df[column_order]
    
    # 保存Excel
    df.to_excel(output_xlsx, index=False, sheet_name='履约项目进度')
    
    print(f"成功导出 {len(df)} 条记录")
    print(f"输出文件: {output_xlsx}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    
    json_file = sys.argv[1]
    output_xlsx = sys.argv[2] if len(sys.argv) > 2 else "履约项目.xlsx"
    
    export_excel(json_file, output_xlsx)
