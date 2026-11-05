#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "请用 sudo 运行：sudo bash uninstall.sh" >&2
  exit 1
fi

echo "将停止并移除官方 mita 软件包。"
echo "默认保留 /etc/mita 配置及 /root/mieru-credentials.txt。"
read -r -p "确认卸载？输入 YES 继续： " CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
  echo "已取消。"
  exit 0
fi

mita stop 2>/dev/null || true
systemctl disable --now mita 2>/dev/null || true
apt-get remove -y mita
echo "mita 已卸载。配置及凭据文件按默认策略保留。"
