#!/usr/bin/env python3
"""
License 生成工具
用法:
  python generate_license.py --customer "XX风电场" --expire 2027-12-31 --key private.pem
  python generate_license.py --customer "XX风电场" --expire 2027-12-31 --key private.pem --mac AA:BB:CC:DD:EE:FF

输出: 一串 base64 字符串，用户在安装时粘贴即可
"""

import argparse
import base64
import json
import sys
from datetime import datetime

from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding


def load_private_key(path: str):
    with open(path, "rb") as f:
        return serialization.load_pem_private_key(f.read(), password=None)


def make_sign_payload(customer: str, expire: str, mac: str) -> str:
    """签名原文: customer|expire|mac"""
    return f"{customer}|{expire}|{mac}"


def generate_license(private_key_path: str, customer: str, expire: str, mac: str = "") -> str:
    private_key = load_private_key(private_key_path)

    payload = make_sign_payload(customer, expire, mac)
    signature = private_key.sign(
        payload.encode("utf-8"),
        padding.PKCS1v15(),
        hashes.SHA256(),
    )

    license_obj = {
        "customer": customer,
        "expire": expire,
        "mac": mac,
        "signature": base64.b64encode(signature).decode("ascii"),
    }

    # 整个 JSON base64 编码，方便用户复制粘贴
    license_json = json.dumps(license_obj, ensure_ascii=False, separators=(",", ":"))
    return base64.b64encode(license_json.encode("utf-8")).decode("ascii")


def main():
    parser = argparse.ArgumentParser(description="风电监控系统 License 生成工具")
    parser.add_argument("--customer", required=True, help="客户名称，如 'XX风电场'")
    parser.add_argument("--expire", required=True, help="到期日期，格式 YYYY-MM-DD")
    parser.add_argument("--key", required=True, help="私钥文件路径 (private.pem)")
    parser.add_argument("--mac", default="", help="绑定的网卡 MAC 地址 (可选)")
    args = parser.parse_args()

    # 校验日期格式
    try:
        datetime.strptime(args.expire, "%Y-%m-%d")
    except ValueError:
        print(f"错误: 日期格式不正确，应为 YYYY-MM-DD，当前: {args.expire}", file=sys.stderr)
        sys.exit(1)

    license_str = generate_license(args.key, args.customer, args.expire, args.mac)

    print("=" * 60)
    print("License 已生成，请将以下内容提供给用户:")
    print("=" * 60)
    print(license_str)
    print("=" * 60)
    print(f"客户: {args.customer}")
    print(f"有效期至: {args.expire}")
    if args.mac:
        print(f"绑定 MAC: {args.mac}")


if __name__ == "__main__":
    main()
