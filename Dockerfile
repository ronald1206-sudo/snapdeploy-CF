FROM alpine:latest

# 1. 安裝系統依賴同下載工具
RUN apk add --no-cache ca-certificates tzdata wget

# 2. 直接指定 v3.39.0 版本的官方下載鏈接（最穩陣，不會解析失敗）
RUN wget https://github.com/enfein/mieru/releases/download/v3.39.0/mieru-linux-amd64 -O /usr/local/bin/mita && \
    chmod +x /usr/local/bin/mita

# 3. 複製配置文件與啟動腳本
COPY mita.json /etc/mita/mita.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 7860

# 4. 運行啟動腳本
ENTRYPOINT ["/entrypoint.sh"]
