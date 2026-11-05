#!/usr/bin/env bash
set -Eeuo pipefail

# Mieru official server installer (mita)
# Supported: Debian/Ubuntu, amd64/arm64
MIERU_VERSION="${MIERU_VERSION:-3.39.0}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "请用 sudo 运行：sudo bash install.sh" >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "无法识别系统：缺少 /etc/os-release" >&2
  exit 1
fi
. /etc/os-release
case "${ID:-}" in
  debian|ubuntu) ;;
  *)
    echo "目前脚本只支持 Debian / Ubuntu；检测到：${PRETTY_NAME:-unknown}" >&2
    exit 1
    ;;
esac

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
  amd64) PKG_ARCH="amd64" ;;
  arm64) PKG_ARCH="arm64" ;;
  *)
    echo "不支持的 CPU 架构：$ARCH（仅支持 amd64 / arm64）" >&2
    exit 1
    ;;
esac

if ! [[ "$MIERU_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "版本号格式错误：$MIERU_VERSION" >&2
  exit 1
fi

PKG="mita_${MIERU_VERSION}_${PKG_ARCH}.deb"
BASE_URL="https://github.com/enfein/mieru/releases/download/v${MIERU_VERSION}"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ca-certificates curl openssl python3

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
cd "$TMP_DIR"

echo "下载官方 Mieru mita ${MIERU_VERSION}（${PKG_ARCH}）..."
curl -fL --retry 3 --retry-delay 2 -o "$PKG" "${BASE_URL}/${PKG}"
curl -fL --retry 3 --retry-delay 2 -o "${PKG}.sha256.txt" "${BASE_URL}/${PKG}.sha256.txt"

echo "校验官方 SHA-256..."
sha256sum --check "${PKG}.sha256.txt"

echo "安装 mita..."
apt-get install -y "./${PKG}"

systemctl daemon-reload
systemctl enable --now mita

echo
echo "安装完成。服务初始状态通常为 IDLE（尚未加载监听配置）。"
systemctl --no-pager --full status mita || true
mita version 2>/dev/null || true
