#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CREDENTIALS_FILE="/root/mieru-credentials.txt"
CONFIG_TMP="$(mktemp)"
trap 'rm -f "$CONFIG_TMP"' EXIT

if [[ "${EUID}" -ne 0 ]]; then
  echo "请用 sudo 运行：sudo bash deploy.sh" >&2
  exit 1
fi

echo "=== Mieru 服务端部署 ==="
echo "此脚本会安装官方 mita 软件包，并写入单用户配置。"
echo

MIERU_VERSION="${MIERU_VERSION:-3.39.0}" bash "$SCRIPT_DIR/install.sh"

read -r -p "监听端口 [8443]： " PORT
PORT="${PORT:-8443}"
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1025 || PORT > 65535 )); then
  echo "端口必须是 1025–65535 之间的整数。" >&2
  exit 1
fi

read -r -p "传输协议 TCP 或 UDP [TCP]： " PROTOCOL
PROTOCOL="${PROTOCOL:-TCP}"
PROTOCOL="${PROTOCOL^^}"
if [[ "$PROTOCOL" != "TCP" && "$PROTOCOL" != "UDP" ]]; then
  echo "协议只可选择 TCP 或 UDP。" >&2
  exit 1
fi

DEFAULT_USER="mita-$(openssl rand -hex 3)"
read -r -p "节点用户名 [${DEFAULT_USER}]： " USERNAME
USERNAME="${USERNAME:-$DEFAULT_USER}"
if ! [[ "$USERNAME" =~ ^[A-Za-z0-9._-]{1,64}$ ]]; then
  echo "用户名只允许 1–64 位英文字母、数字、点、下划线及连字符。" >&2
  exit 1
fi

echo "输入节点密码（留空则自动生成 32 位随机密码）："
read -r -s -p "密码： " PASSWORD
echo
if [[ -z "$PASSWORD" ]]; then
  PASSWORD="$(openssl rand -hex 16)"
fi
if (( ${#PASSWORD} < 8 )); then
  echo "密码至少需要 8 个字符。" >&2
  exit 1
fi

export MIERU_PORT="$PORT"
export MIERU_PROTOCOL="$PROTOCOL"
export MIERU_USERNAME="$USERNAME"
export MIERU_PASSWORD="$PASSWORD"

python3 - "$CONFIG_TMP" <<'PY'
import json, os, sys
config = {
    "portBindings": [{
        "port": int(os.environ["MIERU_PORT"]),
        "protocol": os.environ["MIERU_PROTOCOL"]
    }],
    "users": [{
        "name": os.environ["MIERU_USERNAME"],
        "password": os.environ["MIERU_PASSWORD"]
    }],
    "loggingLevel": "INFO",
    "mtu": 1400,
    "dns": {"dualStack": "PREFER_IPv4"}
}
with open(sys.argv[1], "w", encoding="utf-8") as f:
    json.dump(config, f, ensure_ascii=False, indent=2)
    f.write("\n")
PY
chmod 600 "$CONFIG_TMP"

echo "应用服务端配置..."
mita replace config "$CONFIG_TMP"
mita start

cat > "$CREDENTIALS_FILE" <<EOF
Mieru server credentials
Version: ${MIERU_VERSION:-3.39.0}
Port: ${PORT}
Protocol: ${PROTOCOL}
Username: ${USERNAME}
Password: ${PASSWORD}

Keep this file private. Do not upload it to GitHub or send it to anyone.
EOF
chmod 600 "$CREDENTIALS_FILE"

echo
echo "=== 部署完成 ==="
mita status
echo "节点凭据已保存到：$CREDENTIALS_FILE（权限 600）"
echo "请在 VPS 云平台防火墙及系统防火墙放行 ${PORT}/${PROTOCOL}。"
echo "注意：本脚本不会自动修改云平台防火墙规则。"
