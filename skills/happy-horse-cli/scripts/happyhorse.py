#!/usr/bin/env python3
# ============================================================
# HappyHorse 统一视频生成工具
# 基于百炼平台 happyhorse-1.0 系列模型
# 用法: python3 happyhorse.py <mode> [options]
# mode: i2v | t2v | r2v | edit | batch | check | config | clear-cache
# ============================================================

import argparse
import json
import os
import sys
import time
from datetime import datetime
from typing import Optional, List

import requests
import oss2

# Module-level path resolution (safe even when __file__ is absent)
_SCRIPT_PATH = os.path.abspath(sys.argv[0]) if '__file__' not in dir() else os.path.abspath(__file__)
_SCRIPT_DIR = os.path.dirname(_SCRIPT_PATH)

# ============================================================
# Config: ~/.happy-horse.env 读写
# ============================================================
class Config:
    ENV_FILE = os.path.expanduser("~/.happy-horse.env")

    def __init__(self):
        self.dashscope_api_key = ""
        self.oss_access_key_id = ""
        self.oss_access_key_secret = ""
        self.oss_bucket = ""
        self.oss_region = ""
        self._load()

    def _load(self):
        if not os.path.exists(self.ENV_FILE):
            return
        with open(self.ENV_FILE) as f:
            for line in f:
                line = line.strip()
                if '=' in line and not line.startswith('#'):
                    key, _, value = line.partition('=')
                    key = key.strip()
                    value = value.strip().strip('"').strip("'")
                    if key == 'DASHSCOPE_API_KEY':
                        self.dashscope_api_key = value
                    elif key == 'OSS_ACCESS_KEY_ID':
                        self.oss_access_key_id = value
                    elif key == 'OSS_ACCESS_KEY_SECRET':
                        self.oss_access_key_secret = value
                    elif key == 'OSS_BUCKET':
                        self.oss_bucket = value
                    elif key == 'OSS_REGION':
                        self.oss_region = value

    def save(self, **kwargs):
        existing = {}
        if os.path.exists(self.ENV_FILE):
            with open(self.ENV_FILE) as f:
                for line in f:
                    line = line.strip()
                    if '=' in line and not line.startswith('#'):
                        k, _, v = line.partition('=')
                        existing[k.strip()] = v.strip()

        for k, v in kwargs.items():
            existing[k] = v
            attr = k.lower()
            if hasattr(self, attr):
                setattr(self, attr, v)

        os.makedirs(os.path.dirname(self.ENV_FILE), exist_ok=True)
        with open(self.ENV_FILE, 'w') as f:
            for k, v in existing.items():
                f.write(f"{k}={v}\n")
        os.chmod(self.ENV_FILE, 0o600)

    def has_oss(self):
        return all([self.oss_access_key_id, self.oss_access_key_secret,
                    self.oss_bucket, self.oss_region])

    def has_api_key(self):
        return bool(self.dashscope_api_key)


# ============================================================
# OSSCache: OSS 上传缓存管理
# ============================================================
class OSSCache:
    CACHE_FILE = os.path.expanduser("~/.happy-horse-oss-cache.json")

    def __init__(self):
        self._ensure_file()

    def _read(self) -> dict:
        try:
            with open(self.CACHE_FILE) as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            return {}

    def _write(self, data: dict):
        with open(self.CACHE_FILE, 'w') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        os.chmod(self.CACHE_FILE, 0o600)

    def _ensure_file(self):
        if not os.path.exists(self.CACHE_FILE):
            self._write({})

    def check(self, abs_path: str, bucket: str, region: str) -> Optional[str]:
        cache = self._read()
        entry = cache.get(abs_path)
        if not entry:
            return None

        try:
            stat = os.stat(abs_path)
        except OSError:
            return None

        if stat.st_mtime != entry.get('file_mtime', 0):
            return None
        if stat.st_size != entry.get('file_size', 0):
            return None

        now_ts = time.time()
        if now_ts >= entry.get('expires_at', 0) - 600:
            return None

        if entry.get('bucket') != bucket:
            return None
        if entry.get('region') != region:
            return None

        return entry['presigned_url']

    def save(self, abs_path: str, oss_path: str, presigned_url: str,
             bucket: str, region: str):
        cache = self._read()
        try:
            stat = os.stat(abs_path)
        except OSError:
            print(f"⚠️  无法获取文件状态: {abs_path}", file=sys.stderr)
            return

        now_ts = time.time()
        cache[abs_path] = {
            "oss_path": oss_path,
            "presigned_url": presigned_url,
            "uploaded_at": now_ts,
            "expires_at": now_ts + 24 * 3600 - 300,
            "file_mtime": stat.st_mtime,
            "file_size": stat.st_size,
            "bucket": bucket,
            "region": region
        }
        self._write(cache)

    def clear_expired(self, bucket: str, region: str):
        cache = self._read()
        now_ts = time.time()
        cleaned = {}
        removed = 0

        for path, entry in cache.items():
            if now_ts >= entry.get('expires_at', 0):
                removed += 1
                continue
            try:
                stat = os.stat(path)
                if stat.st_mtime != entry.get('file_mtime', 0):
                    removed += 1
                    continue
                if stat.st_size != entry.get('file_size', 0):
                    removed += 1
                    continue
            except OSError:
                removed += 1
                continue
            if entry.get('bucket') != bucket:
                removed += 1
                continue
            if entry.get('region') != region:
                removed += 1
                continue
            cleaned[path] = entry

        total = len(cache)
        kept = len(cleaned)
        self._write(cleaned)
        print(f"缓存清理完成: {removed} 条移除, {kept} 条保留 (原 {total} 条)")


# ============================================================
# OSSUploader: oss2 SDK 上传
# ============================================================
class OSSUploader:
    def __init__(self, config: Config):
        self.config = config
        self.cache = OSSCache()
        self.auth = oss2.Auth(config.oss_access_key_id, config.oss_access_key_secret)
        endpoint = f"oss-{config.oss_region}.aliyuncs.com"
        self.bucket = oss2.Bucket(self.auth, endpoint, config.oss_bucket)

    def upload(self, local_file: str, label: str = "文件") -> str:
        abs_path = os.path.abspath(local_file)

        cached_url = self.cache.check(abs_path, self.config.oss_bucket, self.config.oss_region)
        if cached_url:
            print(f"♻️  缓存命中，复用预签名 URL: {label}", file=sys.stderr)
            return cached_url

        filename = os.path.basename(local_file)
        name, ext = os.path.splitext(filename)
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        oss_key = f"happyhorse/{name}-{timestamp}{ext}"

        print(f"📤 上传 {label} 到 OSS: oss://{self.config.oss_bucket}/{oss_key}", file=sys.stderr)

        try:
            self.bucket.put_object_from_file(oss_key, local_file)
        except Exception as e:
            print(f"❌ OSS 上传失败: {e}", file=sys.stderr)
            sys.exit(1)

        print("🔗 生成预签名 URL（有效期 24h）...", file=sys.stderr)

        try:
            presigned_url = self.bucket.sign_url('GET', oss_key, 86400, slash_safe=True)
        except Exception as e:
            print(f"❌ 预签名 URL 生成失败: {e}", file=sys.stderr)
            sys.exit(1)

        self.cache.save(abs_path, f"oss://{self.config.oss_bucket}/{oss_key}",
                        presigned_url, self.config.oss_bucket, self.config.oss_region)

        return presigned_url


# ============================================================
# DashScopeAPI: 百炼平台 API 客户端
# ============================================================
class DashScopeAPI:
    API_BASE = "https://dashscope.aliyuncs.com/api/v1/services/aigc/video-generation/video-synthesis"
    TASK_API = "https://dashscope.aliyuncs.com/api/v1/tasks"
    POLL_INTERVAL = 5
    MAX_POLLS = 120

    def __init__(self, config: Config):
        self.config = config
        self.session = requests.Session()
        self.session.headers.update({
            "Authorization": f"Bearer {config.dashscope_api_key}",
            "Content-Type": "application/json"
        })

    def submit_task(self, body: dict, label: str = "") -> Optional[str]:
        headers = {"X-DashScope-Async": "enable"}
        try:
            resp = self.session.post(self.API_BASE, json=body, headers=headers)
            data = resp.json()
        except Exception as e:
            print(f"❌ {label}任务提交失败: {e}", file=sys.stderr)
            return None

        task_id = data.get('output', {}).get('task_id', '')
        if not task_id:
            print(f"❌ {label}任务提交失败: {resp.text[:200]}", file=sys.stderr)
            return None
        return task_id

    def poll_task(self, task_id: str, label: str = "") -> Optional[str]:
        for poll_count in range(1, self.MAX_POLLS + 1):
            time.sleep(self.POLL_INTERVAL)

            try:
                resp = self.session.get(f"{self.TASK_API}/{task_id}")
                data = resp.json()
            except Exception:
                continue

            status = data.get('output', {}).get('task_status', '')

            if status == "SUCCEEDED":
                video_url = data.get('output', {}).get('video_url', '')
                if not video_url:
                    print(f"❌ {label}任务成功但未获取到视频 URL", file=sys.stderr)
                    return None
                return video_url
            elif status == "FAILED":
                err_msg = data.get('output', {}).get('message', '未知错误')
                print(f"❌ {label}任务失败：{err_msg}", file=sys.stderr)
                return None

            if poll_count % 5 == 0:
                print(f"   {label}状态: {status} (轮询 {poll_count}/{self.MAX_POLLS})", file=sys.stderr)

        print(f"❌ {label}轮询超时（{self.MAX_POLLS}次），task_id: {task_id}", file=sys.stderr)
        return None

    def download_video(self, url: str, output_path: str):
        os.makedirs(os.path.dirname(output_path) or '.', exist_ok=True)
        try:
            resp = requests.get(url, stream=True, timeout=300)
            resp.raise_for_status()
            with open(output_path, 'wb') as f:
                for chunk in resp.iter_content(chunk_size=8192):
                    f.write(chunk)
            print(f"✅ 完成！视频已保存：{output_path}")
        except Exception as e:
            print(f"❌ 下载失败: {e}", file=sys.stderr)
            sys.exit(1)

    def get_task_status(self, task_id: str) -> Optional[dict]:
        """查询单个任务状态，返回 API 响应 dict 或 None"""
        try:
            resp = self.session.get(f"{self.TASK_API}/{task_id}")
            return resp.json()
        except Exception:
            return None


# ============================================================
# HappyHorseApp: 主应用
# ============================================================
class HappyHorseApp:
    def __init__(self):
        self.config = Config()

    def _get_uploader(self):
        if not self.config.has_oss():
            print("❌ OSS 配置不完整", file=sys.stderr)
            missing = []
            if not self.config.oss_access_key_id:
                missing.append("OSS_ACCESS_KEY_ID")
            if not self.config.oss_access_key_secret:
                missing.append("OSS_ACCESS_KEY_SECRET")
            if not self.config.oss_bucket:
                missing.append("OSS_BUCKET")
            if not self.config.oss_region:
                missing.append("OSS_REGION")
            print(f"   缺少: {', '.join(missing)}", file=sys.stderr)
            sys.exit(1)
        return OSSUploader(self.config)

    def _get_api(self):
        if not self.config.has_api_key():
            print("❌ 缺少 DASHSCOPE_API_KEY", file=sys.stderr)
            print(f"   请运行: python3 {_SCRIPT_PATH} config --set DASHSCOPE_API_KEY=sk-xxx", file=sys.stderr)
            sys.exit(1)
        return DashScopeAPI(self.config)

    def _resolve_url(self, input_path: str, uploader, label: str = "文件") -> str:
        if os.path.isfile(input_path):
            return uploader.upload(input_path, label)
        return input_path

    def _read_prompt(self, prompt: str) -> str:
        if os.path.isfile(prompt):
            print(f"📄 从文件读取 prompt：{prompt}", file=sys.stderr)
            with open(prompt) as f:
                return f.read().strip()
        return prompt

    # ================================================================
    # check: 环境检查
    # ================================================================
    def check_setup(self):
        print("===============================")
        print("  HappyHorse 环境检查报告")
        print("===============================")
        print()

        print("【运行环境】")
        print(f"  状态: ✅ Python {sys.version.split()[0]}")
        try:
            import oss2
            print(f"  oss2: ✅ 已安装 ({oss2.__version__})")
        except ImportError:
            print("  oss2: ❌ 未安装 (pip3 install oss2)")
        try:
            import requests
            print(f"  requests: ✅ 已安装 ({requests.__version__})")
        except ImportError:
            print("  requests: ❌ 未安装 (pip3 install requests)")
        print()

        print("【配置文件】")
        if os.path.exists(Config.ENV_FILE):
            print(f"  路径: ✅ {Config.ENV_FILE}")
        else:
            print(f"  路径: ❌ {Config.ENV_FILE}（不存在，将在保存配置时自动创建）")
        print()

        print("【API Key 配置】")
        if self.config.dashscope_api_key:
            ak = self.config.dashscope_api_key
            masked = f"{ak[:8]}****{ak[-4:]}"
            print(f"  DASHSCOPE_API_KEY: ✅ 已设置 ({masked})")
        else:
            print("  DASHSCOPE_API_KEY: ❌ 未设置（百炼平台 API Key，必填）")
        print()

        print("【OSS 配置（上传本地文件时必填）】")
        for attr, label in [("oss_access_key_id", "OSS_ACCESS_KEY_ID"),
                            ("oss_access_key_secret", "OSS_ACCESS_KEY_SECRET"),
                            ("oss_bucket", "OSS_BUCKET"),
                            ("oss_region", "OSS_REGION")]:
            val = getattr(self.config, attr)
            if val:
                if 'secret' in attr:
                    print(f"  {label}: ✅ 已设置 (已隐藏)")
                elif 'key_id' in attr:
                    masked = f"{val[:6]}****{val[-4:]}"
                    print(f"  {label}: ✅ 已设置 ({masked})")
                else:
                    print(f"  {label}: ✅ 已设置 ({val})")
            else:
                print(f"  {label}: ❌ 未设置")
        print()

        print("===============================")
        if self.config.dashscope_api_key:
            print("  ✅ 核心配置完整，可以使用 happyhorse.py")
        else:
            print("  ⚠️  有必填配置缺失")
            print(f"  请运行: python3 {_SCRIPT_PATH} config --set DASHSCOPE_API_KEY=sk-xxx")
        print("===============================")

    # ================================================================
    # config: 保存配置
    # ================================================================
    def save_config(self, kv_pairs: List[str]):
        kwargs = {}
        for pair in kv_pairs:
            if '=' in pair:
                k, _, v = pair.partition('=')
                kwargs[k.strip()] = v.strip()

        if not kwargs:
            print("用法: python3 happyhorse.py config --set KEY=VALUE [KEY2=VALUE2 ...]")
            print()
            print("支持的 KEY:")
            print("  DASHSCOPE_API_KEY      百炼平台 API Key")
            print("  OSS_ACCESS_KEY_ID      OSS Access Key ID")
            print("  OSS_ACCESS_KEY_SECRET  OSS Access Key Secret")
            print("  OSS_BUCKET             OSS Bucket 名称")
            print("  OSS_REGION             OSS 地域，如 cn-hangzhou")
            return

        valid_keys = {'DASHSCOPE_API_KEY', 'OSS_ACCESS_KEY_ID', 'OSS_ACCESS_KEY_SECRET',
                      'OSS_BUCKET', 'OSS_REGION'}
        for k in kwargs:
            if k not in valid_keys:
                print(f"⚠️  跳过未知配置项: {k}")

        filtered = {k: v for k, v in kwargs.items() if k in valid_keys}
        self.config.save(**filtered)
        for k, v in filtered.items():
            setattr(self.config, k.lower(), v)
            print(f"✅ 已保存: {k}")

    # ================================================================
    # clear-cache: 清理过期缓存
    # ================================================================
    def clear_cache(self):
        cache = OSSCache()
        bucket = self.config.oss_bucket or ''
        region = self.config.oss_region or ''
        cache.clear_expired(bucket, region)

    # ================================================================
    # i2v: 图生视频
    # ================================================================
    def i2v(self, args):
        if not args.image:
            print("❌ 必须通过 -i 指定图片 URL 或本地路径", file=sys.stderr)
            sys.exit(1)

        api = self._get_api()
        uploader = self._get_uploader()

        prompt_text = self._read_prompt(args.prompt) if args.prompt else ""
        image_url = self._resolve_url(args.image, uploader, "图片")

        print(f"🎬 图生视频 | 图片: {image_url[:60]}...", file=sys.stderr)
        print(f"   分辨率: {args.resolution} | 时长: {args.duration}s | 水印: {args.watermark}", file=sys.stderr)
        if prompt_text:
            print(f"   Prompt: {prompt_text[:100]}...", file=sys.stderr)

        body = {
            "model": "happyhorse-1.0-i2v",
            "input": {"media": [{"type": "first_frame", "url": image_url}]},
            "parameters": {
                "resolution": args.resolution,
                "duration": args.duration,
                "watermark": args.watermark
            }
        }
        if prompt_text:
            body["input"]["prompt"] = prompt_text
        if args.seed is not None:
            body["parameters"]["seed"] = args.seed

        self._run_single_task(api, body, "i2v", "[i2v]", args)

    # ================================================================
    # t2v: 文生视频
    # ================================================================
    def t2v(self, args):
        if not args.prompt:
            print("❌ 必须通过 -p 指定 prompt", file=sys.stderr)
            sys.exit(1)

        api = self._get_api()
        prompt_text = self._read_prompt(args.prompt)

        print(f"🎬 文生视频 | 分辨率: {args.resolution} | 比例: {args.ratio} | 时长: {args.duration}s", file=sys.stderr)
        print(f"   Prompt: {prompt_text[:100]}...", file=sys.stderr)

        body = {
            "model": "happyhorse-1.0-t2v",
            "input": {"prompt": prompt_text},
            "parameters": {
                "resolution": args.resolution,
                "ratio": args.ratio,
                "duration": args.duration,
                "watermark": args.watermark
            }
        }
        if args.seed is not None:
            body["parameters"]["seed"] = args.seed

        self._run_single_task(api, body, "t2v", "[t2v]", args)

    # ================================================================
    # r2v: 参考生视频
    # ================================================================
    def r2v(self, args):
        if not args.prompt:
            print("❌ 必须通过 -p 指定 prompt", file=sys.stderr)
            sys.exit(1)
        if not args.ref:
            print("❌ 必须通过 --ref 指定至少一张参考图", file=sys.stderr)
            sys.exit(1)
        if len(args.ref) > 9:
            print(f"❌ 参考图最多 9 张，当前 {len(args.ref)} 张", file=sys.stderr)
            sys.exit(1)

        api = self._get_api()
        uploader = self._get_uploader()
        prompt_text = self._read_prompt(args.prompt)

        ref_urls = [self._resolve_url(r, uploader, "参考图") for r in args.ref]

        print(f"🎬 参考生视频 | 参考图: {len(ref_urls)} 张 | 分辨率: {args.resolution} | 时长: {args.duration}s", file=sys.stderr)
        print(f"   Prompt: {prompt_text[:100]}...", file=sys.stderr)

        body = {
            "model": "happyhorse-1.0-r2v",
            "input": {
                "prompt": prompt_text,
                "media": [{"type": "reference_image", "url": u} for u in ref_urls]
            },
            "parameters": {
                "resolution": args.resolution,
                "ratio": args.ratio,
                "duration": args.duration,
                "watermark": args.watermark
            }
        }
        if args.seed is not None:
            body["parameters"]["seed"] = args.seed

        self._run_single_task(api, body, "r2v", "[r2v]", args)

    # ================================================================
    # edit: 视频编辑
    # ================================================================
    def video_edit(self, args):
        if not args.video:
            print("❌ 必须通过 -v 指定视频 URL 或本地路径", file=sys.stderr)
            sys.exit(1)
        if not args.prompt:
            print("❌ 必须通过 -p 指定编辑指令", file=sys.stderr)
            sys.exit(1)

        api = self._get_api()
        uploader = self._get_uploader()
        prompt_text = self._read_prompt(args.prompt)
        video_url = self._resolve_url(args.video, uploader, "视频")
        ref_urls = [self._resolve_url(r, uploader, "参考图") for r in (args.ref or [])]

        print(f"🎬 视频编辑 | 视频: {video_url[:60]}...", file=sys.stderr)
        print(f"   分辨率: {args.resolution} | 参考图: {len(ref_urls)} 张", file=sys.stderr)
        print(f"   指令: {prompt_text[:100]}...", file=sys.stderr)

        media = [{"type": "video", "url": video_url}]
        for u in ref_urls:
            media.append({"type": "reference_image", "url": u})

        body = {
            "model": "happyhorse-1.0-video-edit",
            "input": {"prompt": prompt_text, "media": media},
            "parameters": {"resolution": args.resolution}
        }

        self._run_single_task(api, body, "video-edit", "[video-edit]", args)

    # ================================================================
    # 单任务通用流程：提交 → 轮询 → 下载
    # ================================================================
    def _run_single_task(self, api: DashScopeAPI, body: dict, mode: str, label: str, args):
        print(f"🚀 {label}提交任务...", file=sys.stderr)
        task_id = api.submit_task(body, label)
        if not task_id:
            sys.exit(1)
        print(f"✅ {label}任务已提交 task_id: {task_id}", file=sys.stderr)

        print(f"⏳ {label}等待生成...", file=sys.stderr)
        video_url = api.poll_task(task_id, label)
        if not video_url:
            sys.exit(1)

        if args.output:
            output_path = os.path.join(args.output_dir, args.output)
        else:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_path = os.path.join(args.output_dir, f"output-{mode}-{timestamp}.mp4")

        print(f"⬇️  下载视频到: {output_path}", file=sys.stderr)
        api.download_video(video_url, output_path)

    # ================================================================
    # batch: 批量并发生成
    # ================================================================
    def batch(self, args):
        if not args.config:
            print("❌ 必须通过 --config 指定 JSON 配置文件", file=sys.stderr)
            sys.exit(1)
        if not os.path.isfile(args.config):
            print(f"❌ 配置文件不存在: {args.config}", file=sys.stderr)
            sys.exit(1)

        api = self._get_api()
        uploader = self._get_uploader()

        print(f"📋 读取配置: {args.config}")

        with open(args.config) as f:
            config = json.load(f)

        max_concurrency = args.max_concurrency or config.get('max_concurrency', 10)
        output_dir = args.output_dir or config.get('output_dir', '.')
        tasks = config.get('tasks', [])

        if not tasks:
            print("ERROR: tasks 数组为空", file=sys.stderr)
            sys.exit(1)

        print(f"📋 共 {len(tasks)} 个任务待处理")
        print(f"   最大并发: {max_concurrency}")
        print()

        # Phase 1: 预处理——上传文件 + 构建 body
        processed_tasks = []
        for i, t in enumerate(tasks):
            mode = t.get('mode', '').strip()
            if mode not in ('i2v', 't2v', 'r2v', 'video-edit'):
                print(f"ERROR: 任务[{i}] mode 无效: {mode}", file=sys.stderr)
                sys.exit(1)

            prompt = t.get('prompt', '')
            if prompt and os.path.isfile(prompt):
                with open(prompt) as pf:
                    prompt = pf.read().strip()

            resolution = t.get('resolution', '720P')
            duration = t.get('duration', 15)
            ratio = t.get('ratio', '16:9')
            seed_val = t.get('seed')
            watermark = t.get('watermark', False)
            output_file = t.get('output', f'output-batch-{i:03d}.mp4')

            body = {}

            try:
                if mode == 'i2v':
                    image = t.get('image', '')
                    image_url = self._resolve_url(image, uploader, f'图片[{i}]')
                    body = {
                        "model": "happyhorse-1.0-i2v",
                        "input": {"media": [{"type": "first_frame", "url": image_url}]},
                        "parameters": {
                            "resolution": resolution,
                            "duration": int(duration),
                            "watermark": watermark
                        }
                    }
                    if prompt:
                        body["input"]["prompt"] = prompt
                    if seed_val is not None:
                        body["parameters"]["seed"] = int(seed_val)

                elif mode == 't2v':
                    body = {
                        "model": "happyhorse-1.0-t2v",
                        "input": {"prompt": prompt},
                        "parameters": {
                            "resolution": resolution,
                            "ratio": ratio,
                            "duration": int(duration),
                            "watermark": watermark
                        }
                    }
                    if seed_val is not None:
                        body["parameters"]["seed"] = int(seed_val)

                elif mode == 'r2v':
                    refs = t.get('refs', [])
                    if isinstance(refs, str):
                        refs = [refs]
                    ref_urls = [self._resolve_url(r, uploader, f'参考图[{i}]') for r in refs]
                    body = {
                        "model": "happyhorse-1.0-r2v",
                        "input": {
                            "prompt": prompt,
                            "media": [{"type": "reference_image", "url": u} for u in ref_urls]
                        },
                        "parameters": {
                            "resolution": resolution,
                            "ratio": ratio,
                            "duration": int(duration),
                            "watermark": watermark
                        }
                    }
                    if seed_val is not None:
                        body["parameters"]["seed"] = int(seed_val)

                elif mode == 'video-edit':
                    video_path = t.get('video', '')
                    video_url = self._resolve_url(video_path, uploader, f'视频[{i}]')
                    refs = t.get('refs', [])
                    if isinstance(refs, str):
                        refs = [refs]
                    ref_urls = [self._resolve_url(r, uploader, f'参考图[{i}]') for r in refs]
                    media = [{"type": "video", "url": video_url}]
                    for u in ref_urls:
                        media.append({"type": "reference_image", "url": u})
                    body = {
                        "model": "happyhorse-1.0-video-edit",
                        "input": {"prompt": prompt, "media": media},
                        "parameters": {"resolution": resolution}
                    }

            except Exception as e:
                print(f"ERROR: 任务[{i}] 预处理失败: {e}", file=sys.stderr)
                sys.exit(1)

            processed_tasks.append({
                "idx": i,
                "mode": mode,
                "body": body,
                "output_file": output_file
            })

        # Phase 2: 提交所有任务
        print("========================================")
        print("  提交任务到百炼 API")
        print("========================================")

        submitted = []
        for pt in processed_tasks:
            print(f"🚀 提交任务 [{pt['idx']}] {pt['mode']}...", file=sys.stderr)
            task_id = api.submit_task(pt['body'], f"[{pt['idx']}]")
            if task_id:
                print(f"✅ 任务 [{pt['idx']}] 已提交 task_id: {task_id}", file=sys.stderr)
                submitted.append({**pt, "task_id": task_id})
            else:
                print(f"❌ 任务 [{pt['idx']}] 提交失败，跳过", file=sys.stderr)

        print()
        print(f"📊 已提交: {len(submitted)} / {len(tasks)} 个任务")

        if not submitted:
            print("❌ 没有任务成功提交，退出")
            sys.exit(1)

        # Phase 3: 并发轮询并下载
        self._batch_poll_and_download(api, submitted, output_dir)

    def _batch_poll_and_download(self, api: DashScopeAPI, tasks: list, output_dir: str):
        print()
        print("========================================")
        print(f"  开始并发轮询 {len(tasks)} 个任务...")
        print("========================================")

        completed = 0
        failed = 0
        total = len(tasks)
        pending = {t['task_id']: t for t in tasks}

        for poll_count in range(1, api.MAX_POLLS + 1):
            time.sleep(api.POLL_INTERVAL)

            still_pending = {}
            for task_id, pt in pending.items():
                data = api.get_task_status(task_id)
                if data is None:
                    still_pending[task_id] = pt
                    continue

                status = data.get('output', {}).get('task_status', '')

                if status == "SUCCEEDED":
                    video_url = data.get('output', {}).get('video_url', '')
                    if video_url:
                        out_path = os.path.join(output_dir, pt['output_file'])
                        os.makedirs(os.path.dirname(out_path) or '.', exist_ok=True)
                        print(f"⬇️  [{pt['idx']}] 下载: {out_path}", file=sys.stderr)
                        api.download_video(video_url, out_path)
                        completed += 1
                        print(f"✅ [{pt['idx']}] 完成！{out_path}", file=sys.stderr)
                    else:
                        failed += 1
                        print(f"❌ [{pt['idx']}] 成功但无视频 URL", file=sys.stderr)
                elif status == "FAILED":
                    err_msg = data.get('output', {}).get('message', '未知错误')
                    failed += 1
                    print(f"❌ [{pt['idx']}] 失败: {err_msg}", file=sys.stderr)
                else:
                    still_pending[task_id] = pt

            pending = still_pending

            if poll_count % 3 == 0 or len(pending) == 0:
                print(f"📊 进度: ✅{completed} ❌{failed} ⏳{len(pending)} / 总计{total}", file=sys.stderr)

            if not pending:
                break

        if pending:
            print(f"❌ 轮询超时，仍有 {len(pending)} 个任务未完成", file=sys.stderr)

        print()
        print("========================================")
        print(f"  批量任务完成: ✅{completed} ❌{failed} / 总计{total}")
        if completed > 0:
            print(f"  输出目录: {output_dir}")
        print("========================================")


# ============================================================
# CLI 入口
# ============================================================
def main():
    parser = argparse.ArgumentParser(
        description="HappyHorse 视频生成工具 - 基于百炼平台 happyhorse-1.0 系列模型",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
示例:
  python3 {os.path.basename(_SCRIPT_PATH)} check
  python3 {os.path.basename(_SCRIPT_PATH)} config --set DASHSCOPE_API_KEY=sk-xxx
  python3 {os.path.basename(_SCRIPT_PATH)} clear-cache
  python3 {os.path.basename(_SCRIPT_PATH)} i2v -i ./image.png -p "让画面动起来" -d 10
  python3 {os.path.basename(_SCRIPT_PATH)} t2v -p "一只猫在草地上奔跑" -r 1080P -d 5
  python3 {os.path.basename(_SCRIPT_PATH)} r2v -p "图1 身着旗袍..." --ref girl.jpg --ref fan.jpg
  python3 {os.path.basename(_SCRIPT_PATH)} edit -v input.mp4 -p "让角色穿上条纹毛衣"
  python3 {os.path.basename(_SCRIPT_PATH)} batch --config ./tasks.json --max-concurrency 5
        """
    )
    subparsers = parser.add_subparsers(dest="mode", help="操作模式")

    # ---- check ----
    subparsers.add_parser("check", help="环境检查")

    # ---- config ----
    config_parser = subparsers.add_parser("config", help="配置管理")
    config_parser.add_argument("--set", nargs="+", dest="kv_pairs",
                               metavar="KEY=VALUE",
                               help="保存配置项，如 DASHSCOPE_API_KEY=sk-xxx")

    # ---- clear-cache ----
    subparsers.add_parser("clear-cache", help="清理过期 OSS 缓存")

    # ---- 通用参数辅助（不含 -p，因为各模式对 prompt 的 required 条件不同）----
    def add_common_args(p):
        p.add_argument("-r", "--resolution", default="1080P", choices=["720P", "1080P"],
                       help="分辨率，默认 1080P")
        p.add_argument("-d", "--duration", type=int, default=15, choices=[5, 10, 15],
                       help="时长（秒），默认 15")
        p.add_argument("--ratio", default="16:9", choices=["16:9", "9:16", "1:1"],
                       help="比例，默认 16:9")
        p.add_argument("-o", "--output", help="输出文件路径")
        p.add_argument("--output-dir", default=".", dest="output_dir",
                       help="输出目录，默认当前目录")
        p.add_argument("-s", "--seed", type=int, help="随机种子")
        p.add_argument("-w", "--watermark", action="store_true", default=False,
                       help="添加水印")

    # ---- i2v ----
    i2v_parser = subparsers.add_parser("i2v", help="图生视频")
    i2v_parser.add_argument("-i", "--image", required=True,
                            help="首帧图片 URL 或本地路径")
    i2v_parser.add_argument("-p", "--prompt", help="prompt 文本或 .txt/.md 文件路径")
    add_common_args(i2v_parser)

    # ---- t2v ----
    t2v_parser = subparsers.add_parser("t2v", help="文生视频")
    t2v_parser.add_argument("-p", "--prompt", required=True,
                            help="prompt 文本或文件路径")
    add_common_args(t2v_parser)

    # ---- r2v ----
    r2v_parser = subparsers.add_parser("r2v", help="参考生视频")
    r2v_parser.add_argument("-p", "--prompt", required=True,
                            help="含图1图2标记的 prompt")
    r2v_parser.add_argument("--ref", action="append", dest="ref",
                            help="参考图，可多次指定（最多9张）")
    add_common_args(r2v_parser)

    # ---- edit (video-edit) ----
    edit_parser = subparsers.add_parser("edit", help="视频编辑")
    edit_parser.add_argument("-v", "--video", required=True,
                             help="待编辑视频 URL 或本地路径")
    edit_parser.add_argument("-p", "--prompt", required=True,
                             help="编辑指令")
    edit_parser.add_argument("--ref", action="append", dest="ref",
                             help="参考图，可多次指定")
    edit_parser.add_argument("-r", "--resolution", default="1080P",
                             choices=["720P", "1080P"],
                             help="分辨率，默认 1080P")
    edit_parser.add_argument("-o", "--output", help="输出文件路径")
    edit_parser.add_argument("--output-dir", default=".", dest="output_dir",
                             help="输出目录")

    # ---- batch ----
    batch_parser = subparsers.add_parser("batch", help="批量并发生成")
    batch_parser.add_argument("--config", required=True,
                              help="JSON 配置文件路径")
    batch_parser.add_argument("--max-concurrency", type=int, dest="max_concurrency",
                              help="最大并发数，默认 10")
    batch_parser.add_argument("--output-dir", dest="output_dir",
                              help="输出目录")

    args = parser.parse_args()

    if not args.mode:
        parser.print_help()
        sys.exit(1)

    app = HappyHorseApp()

    if args.mode == "check":
        app.check_setup()
    elif args.mode == "config":
        app.save_config(args.kv_pairs or [])
    elif args.mode == "clear-cache":
        app.clear_cache()
    elif args.mode == "i2v":
        app.i2v(args)
    elif args.mode == "t2v":
        app.t2v(args)
    elif args.mode == "r2v":
        app.r2v(args)
    elif args.mode == "edit":
        app.video_edit(args)
    elif args.mode == "batch":
        app.batch(args)


if __name__ == "__main__":
    main()
