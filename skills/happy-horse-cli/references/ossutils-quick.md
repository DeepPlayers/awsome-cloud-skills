# ossutil 2.0 快速安装指南

## 下载地址

| 系统 | 架构 | 下载 |
|------|------|------|
| macOS | ARM64 (Apple Silicon) | https://gosspublic.alicdn.com/ossutil/v2/2.2.2/ossutil-2.2.2-mac-arm64.zip |
| macOS | x86_64 | https://gosspublic.alicdn.com/ossutil/v2/2.2.2/ossutil-2.2.2-mac-amd64.zip |
| Linux | x86_64 | https://gosspublic.alicdn.com/ossutil/v2/2.2.2/ossutil-2.2.2-linux-amd64.zip |
| Linux | ARM64 | https://gosspublic.alicdn.com/ossutil/v2/2.2.2/ossutil-2.2.2-linux-arm64.zip |

## macOS 安装（ARM64）

```bash
curl -o /tmp/ossutil.zip https://gosspublic.alicdn.com/ossutil/v2/2.2.2/ossutil-2.2.2-mac-arm64.zip
unzip /tmp/ossutil.zip -d /tmp/
chmod 755 /tmp/ossutil-2.2.2-mac-arm64/ossutil
sudo mv /tmp/ossutil-2.2.2-mac-arm64/ossutil /usr/local/bin/
ossutil version  # 验证安装
```

## macOS 安装（x86_64）

```bash
curl -o /tmp/ossutil.zip https://gosspublic.alicdn.com/ossutil/v2/2.2.2/ossutil-2.2.2-mac-amd64.zip
unzip /tmp/ossutil.zip -d /tmp/
chmod 755 /tmp/ossutil-2.2.2-mac-amd64/ossutil
sudo mv /tmp/ossutil-2.2.2-mac-amd64/ossutil /usr/local/bin/
ossutil version
```

## Linux 安装（x86_64）

```bash
curl -o /tmp/ossutil.zip https://gosspublic.alicdn.com/ossutil/v2/2.2.2/ossutil-2.2.2-linux-amd64.zip
unzip /tmp/ossutil.zip -d /tmp/
chmod 755 /tmp/ossutil-2.2.2-linux-amd64/ossutil
sudo mv /tmp/ossutil-2.2.2-linux-amd64/ossutil /usr/local/bin/
ossutil version
```

## 关键命令

```bash
# 上传文件（显式传入凭证）
ossutil cp local_file.png oss://bucket/path/file.png \
  -i $OSS_ACCESS_KEY_ID \
  -k $OSS_ACCESS_KEY_SECRET \
  --region cn-hangzhou

# 生成预签名 URL（有效期 86400 秒 = 24h）
ossutil presign oss://bucket/path/file.png \
  --timeout 86400 \
  -i $OSS_ACCESS_KEY_ID \
  -k $OSS_ACCESS_KEY_SECRET \
  --region cn-hangzhou

# 列举 bucket 内容
ossutil ls oss://bucket/ -i $OSS_ACCESS_KEY_ID -k $OSS_ACCESS_KEY_SECRET --region cn-hangzhou
```

## 注意事项

- region 参数为必填（v2 使用 v4 签名，region 不可省略）
- Bucket 需要提前创建好
- 上传的文件建议保存在公网可访问的 bucket（或通过预签名 URL 访问）
- 完整文档参见：`happy_horse/reference/ossutils2.0.md`
