#!/usr/bin/env python3
"""
批量获取 GTS.work 履约项目数据
使用 Selenium 自动化浏览器操作
"""

import json
import time
from datetime import date
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options


def load_customers(csv_file):
    """从 CSV 文件加载客户列表"""
    customers = []
    with open(csv_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()[1:]  # 跳过标题行
        for line in lines:
            line = line.strip()
            if not line:
                continue
            parts = line.split(',')
            if len(parts) >= 2:
                cid = parts[0].strip().replace('\n', '')
                name = parts[1].strip()
                customers.append({'CID': cid, '客户简称': name})
    return customers


def check_service_period(period_str, target_date):
    """检查服务周期是否包含目标日期"""
    if not period_str or period_str == '-' or '~' not in period_str:
        return False
    
    try:
        parts = period_str.split('~')
        if len(parts) != 2:
            return False
        
        start_str = parts[0].strip()
        end_str = parts[1].strip()
        
        # 简单字符串比较 (YYYY-MM-DD 格式可以直接比较)
        target = target_date.strftime('%Y-%m-%d')
        return start_str <= target <= end_str
    except:
        return False


def extract_customer_data(driver, cid, customer_name, target_date):
    """提取单个客户的履约项目数据"""
    base_url = f"https://gts.work/toolstack/customer/detail/operationProject?cid={cid}"
    
    try:
        # 访问客户履约项目页面
        driver.get(base_url)
        time.sleep(3)  # 等待页面加载
        
        # 查找履约项目卡片
        projects = []
        
        # 尝试查找项目卡片 (根据实际情况调整选择器)
        project_cards = driver.find_elements(By.CSS_SELECTOR, '[data-row-key]')
        
        for card in project_cards:
            try:
                project_name_elem = card.find_element(By.CSS_SELECTOR, '.project-name, .card-title, h3, h4')
                project_name = project_name_elem.text.strip()
                
                # 筛选：项目名称必须包含"支持计划"
                if '支持计划' not in project_name:
                    continue
                
                # 提取服务周期
                period_elem = card.find_element(By.XPATH, "//*[contains(text(), '~')]")
                period = period_elem.text.strip()
                
                # 检查服务周期是否包含目标日期
                if not check_service_period(period, target_date):
                    continue
                
                # 获取履约项目 ID
                project_id = card.get_attribute('data-row-key')
                
                # 访问履约项目详情页面
                detail_url = f"https://gts.work/toolstack/tech/public/project/detail/performance?id={project_id}&productCode=supportplan"
                driver.get(detail_url)
                time.sleep(3)
                
                # 点击【基础信息】标签
                try:
                    basic_info_tab = driver.find_element(By.XPATH, "//*[text()='基础信息']")
                    basic_info_tab.click()
                    time.sleep(2)
                except:
                    pass  # 可能已经在基础信息页面
                
                # 提取详细信息
                service_product = "-"
                cost_progress = "-"
                time_progress = "-"
                
                # 尝试提取服务产品、成本进度、时间进度
                # 根据实际页面结构调整选择器
                info_items = driver.find_elements(By.CSS_SELECTOR, '.ant-descriptions-item-content, .info-item')
                for item in info_items:
                    text = item.text
                    if '服务产品' in text:
                        service_product = text
                    elif '成本' in text and '%' in text:
                        cost_progress = text
                    elif '时间' in text and '%' in text:
                        time_progress = text
                
                projects.append({
                    'CID': cid,
                    '客户简称': customer_name,
                    '项目名称': project_name,
                    '服务产品': service_product,
                    '服务周期': period,
                    '成本消耗进度': cost_progress,
                    '时间进度': time_progress,
                    '履约项目 URL': detail_url
                })
                
                # 返回客户页面继续处理下一个项目
                driver.get(base_url)
                time.sleep(2)
                
            except Exception as e:
                print(f"提取项目信息失败：{str(e)}")
                continue
        
        # 如果没有找到符合条件的项目
        if not projects:
            projects.append({
                'CID': cid,
                '客户简称': customer_name,
                '项目名称': '-',
                '服务产品': '-',
                '服务周期': '-',
                '成本消耗进度': '-',
                '时间进度': '-',
                '履约项目 URL': '-'
            })
        
        return projects
        
    except Exception as e:
        print(f"处理客户 {cid} 失败：{str(e)}")
        return [{
            'CID': cid,
            '客户简称': customer_name,
            '项目名称': '-',
            '服务产品': '-',
            '服务周期': '-',
            '成本消耗进度': '-',
            '时间进度': '-',
            '履约项目 URL': '-'
        }]


def main():
    # 配置 Chrome 选项
    chrome_options = Options()
    chrome_options.add_argument('--headless')  # 无头模式
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--window-size=1920,1080')
    
    # 初始化浏览器
    driver = webdriver.Chrome(options=chrome_options)
    
    try:
        # 登录 GTS (需要手动登录或已有 cookie)
        print("请先在浏览器中登录 GTS 系统...")
        driver.get("https://gts.work/toolstack/customer/list")
        time.sleep(5)
        
        # 等待用户确认已登录
        input("登录完成后按回车继续...")
        
        # 加载客户列表
        customers = load_customers('customers_list.csv')
        print(f"加载了 {len(customers)} 个客户")
        
        # 目标日期
        target_date = date.today()
        
        # 批量处理客户
        all_data = []
        for i, customer in enumerate(customers, 1):
            print(f"\n处理第 {i}/{len(customers)} 个客户：{customer['客户简称']} (CID: {customer['CID']})")
            data = extract_customer_data(driver, customer['CID'], customer['客户简称'], target_date)
            all_data.extend(data)
            print(f"  -> 找到 {len([d for d in data if d['项目名称'] != '-'])} 个符合条件的项目")
        
        # 保存 JSON
        output_file = f"履约项目数据-{target_date.strftime('%Y%m%d')}.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(all_data, f, ensure_ascii=False, indent=2)
        
        print(f"\n✓ 完成！数据已保存到：{output_file}")
        print(f"总客户数：{len(customers)}")
        print(f"有项目的客户数：{len([d for d in all_data if d['项目名称'] != '-'])}")
        
    finally:
        driver.quit()


if __name__ == "__main__":
    main()
