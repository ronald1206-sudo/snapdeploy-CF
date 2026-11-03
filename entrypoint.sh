#!/bin/sh

# 1. 將 mita.json 寫入 mita 配置
mita apply config /etc/mita/mita.json

# 2. 啟動 mita 服務
mita start

# 3. 保持前台運行，防止 Docker 容器退出
exec tail -f /dev/null
