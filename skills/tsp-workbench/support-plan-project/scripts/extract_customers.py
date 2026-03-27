#!/usr/bin/env python3
"""
从钉钉表格提取支持计划客户数据

用法:
    python scripts/extract_customers.py <excel_file> [output_csv]

参数:
    excel_file: 钉钉下载的Excel文件路径
    output_csv: 输出CSV文件路径（默认: customers_list.csv）

输出:
    CSV文件包含列: CID, 客户简称, 客户名称, 履约项目
"""

import sys
import pandas as pd


def extract_customers(excel_file: str, output_csv: str = "customers_list.csv"):
    """从Excel文件提取客户数据"""
    
    # 读取Excel文件
    df = pd.read_excel(excel_file, sheet_name='支持计划客户')
    
    # 提取必要列（CID和客户简称）
    customers = df[['CID', '客户简称']].dropna(subset=['CID'])
    
    # 转换CID为字符串格式
    customers['CID'] = customers['CID'].apply(
        lambda x: str(int(x)) if pd.notna(x) and not isinstance(x, str) else str(x)
    )
    
    # 去重
    customers = customers.drop_duplicates(subset=['CID'])
    
    # 保存CSV
    customers.to_csv(output_csv, index=False, encoding='utf-8')
    
    print(f"成功提取 {len(customers)} 个客户")
    print(f"输出文件: {output_csv}")
    
    return customers


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    
    excel_file = sys.argv[1]
    output_csv = sys.argv[2] if len(sys.argv) > 2 else "customers_list.csv"
    
    extract_customers(excel_file, output_csv)
