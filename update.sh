#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VERSION="${1:-${MIERU_VERSION:-3.39.0}}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "请用 sudo 运行：sudo bash update.sh [版本号]" >&2
  exit 1
fi

MIERU_VERSION="$VERSION" bash "$SCRIPT_DIR/install.sh"
systemctl restart mita
echo "更新完成："
mita version 2>/dev/null || true
mita status
