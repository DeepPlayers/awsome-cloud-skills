# 认证配置说明

## 概述

bailian-report-query 技能支持三种认证方式，系统会按优先级自动选择可用的认证源。

## 认证优先级

```
1. FBI 接口动态获取（推荐）
   ↓ 如果失败
2. 环境变量（CI/CD 场景）
   ↓ 如果未配置
3. 本地配置文件（降级方案）
```

---

## 方式一：FBI 接口动态获取（推荐）

### 适用场景
- 日常开发和使用
- 已登录 FBI 系统的环境
- 需要自动获取最新认证信息

### 配置方法

1. **首次认证**
   ```bash
   # 在浏览器中访问以下链接完成登录
   https://fbi.alibaba-inc.com/ai/FbiCopilotAssistantAction/queryChatBISkillProperty
   ```

2. **自动获取**
   - 系统会在首次查询时自动从接口获取认证信息
   - 认证信息会缓存 30 分钟
   - 缓存文件：`scripts/auth_cache.json`

3. **手动管理**
   ```bash
   # 查看认证状态
   python scripts/auth_manager.py --status
   
   # 强制刷新认证
   python scripts/auth_manager.py --refresh
   
   # 清除认证缓存
   python scripts/auth_manager.py --clear
   ```

### config.yaml 配置
```yaml
# 认证字段留空，系统会自动从接口获取
app_name: ""
app_secret: ""
emp_id: ""
assistant_id: ""
```

---

## 方式二：环境变量

### 适用场景
- CI/CD 自动化流程
- 服务器部署
- 无法使用浏览器认证的环境

### 配置方法

1. **修改 config.yaml**
   ```yaml
   use_env_property: true
   ```

2. **设置环境变量**
   ```bash
   export ACCESS_TOKEN='{"fbi_app_name":"chatbi_personal","fbi_app_secret":"xxx","fbi_emp_id":"123456","fbi_assistant_id":"xxx"}'
   ```

3. **验证**
   ```bash
   python scripts/utils.py
   ```

---

## 方式三：本地配置文件

### 适用场景
- 离线环境
- 无法访问 FBI 接口
- 需要固定认证信息

### 配置方法

在 `config.yaml` 中填写认证信息：

```yaml
app_name: "chatbi_personal"
app_secret: "f76a517c-8596-4d20-b404-fc7797f711bf"
emp_id: "475345"
assistant_id: "b7adef38c39b41eb914d15dfaf238a61"
```

> **获取认证信息的方法：**
> 1. 在浏览器中访问：https://fbi.alibaba-inc.com/ai/FbiCopilotAssistantAction/queryChatBISkillProperty
> 2. 复制返回的 JSON 中的 `returnValue` 字段
> 3. 填写到 config.yaml 中

---

## 认证管理工具

### auth_manager.py 使用说明

```bash
# 查看认证状态
python scripts/auth_manager.py --status

# 输出示例：
# {
#   "status": "valid",
#   "cached_at": "2026-04-15 10:30:00",
#   "expires_in": 1500,
#   "properties": {
#     "app_name": "chatbi_personal",
#     "app_secret": "f76a517c-8596-4d20-b404-fc7797f711bf",
#     "emp_id": "475345",
#     "assistant_id": "b7adef38c39b41eb914d15dfaf238a61"
#   }
# }

# 强制刷新认证
python scripts/auth_manager.py --refresh

# 清除认证缓存
python scripts/auth_manager.py --clear
```

---

## 常见问题

### Q1: 提示"未登录或登录已过期"

**原因**：Python requests 无法使用浏览器的 cookie

**解决方案**：
1. 方案一：使用本地配置文件（方式三）
2. 方案二：使用环境变量（方式二）
3. 方案三：在浏览器环境中执行（如 Qoder Skill）

### Q2: 认证缓存多久过期？

缓存有效期为 **30 分钟**。过期后会自动重新获取。

### Q3: 如何查看当前使用的认证方式？

```bash
python scripts/auth_manager.py --status
```

查看输出中的 `status` 字段：
- `valid`：使用 FBI 接口缓存
- `expired`：缓存已过期，将重新获取
- `none`：无缓存，将从接口或配置文件获取

### Q4: 认证失败如何排查？

1. 检查 FBI 系统是否已登录
2. 检查网络连接是否正常
3. 查看错误提示信息
4. 尝试使用本地配置文件作为降级方案

---

## 安全建议

1. **不要将认证信息提交到代码仓库**
   - 将 `config.yaml` 加入 `.gitignore`
   - 使用环境变量管理敏感信息

2. **定期刷新认证**
   - 建议每天刷新一次认证信息
   - 使用 `auth_manager.py --refresh` 手动刷新

3. **监控认证状态**
   - 定期检查认证是否有效
   - 配置自动告警机制（CI/CD 场景）

---

## 技术实现

### 认证流程

```
read_config()
    ↓
尝试从 FBI 接口获取（auth_manager.fetch_auth_properties）
    ↓ 成功
使用动态认证信息
    ↓ 失败
尝试从环境变量读取（use_env_property=true）
    ↓ 成功
使用环境变量认证
    ↓ 失败/未配置
使用本地配置文件
    ↓ 失败
抛出错误，提示用户配置认证信息
```

### 缓存机制

- 缓存文件：`scripts/auth_cache.json`
- 缓存格式：JSON
- 有效期：30 分钟
- 自动刷新：过期后自动重新获取

### 字段映射

接口返回字段 → 配置字段：
```
app_name      → app_name
app_secret    → app_secret
emp_id        → emp_id
assistant_id  → assistant_id
server_domain → server_domain
model         → model
```
