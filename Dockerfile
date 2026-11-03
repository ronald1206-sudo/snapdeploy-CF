FROM alpine:latest

# 1. 安裝系統依賴同下載工具
RUN apk add --no-cache ca-certificates tzdata wget

# 2. 直接從 GitHub 下載官方編譯好的二進制檔並放到系統路徑
RUN wget https://github.com/enfein/mieru/releases/latest/download/mieru-linux-amd64 -O /usr/local/bin/mita && \
    chmod +x /usr/local/bin/mita

# 3. 複製配置文件與啟動腳本
COPY mita.json /etc/mita/mita.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 7860

# 4. 運行啟動腳本
ENTRYPOINT ["/entrypoint.sh"]
