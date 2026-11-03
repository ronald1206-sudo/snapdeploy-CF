#!/bin/sh

# 1. 將配置寫入 mita 內部數據庫
mita apply config /etc/mita/mita.json

# 2. 啟動 mita 服務
mita start

# 3. 保持前台運行，防止容器退出
exec tail -f /dev/null
