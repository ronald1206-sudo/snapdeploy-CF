FROM alpine:latest

# 1. 安裝系統依賴、wget 與 jq（用嚟自動解析 GitHub 最新 Release 下載鏈接）
RUN apk add --no-cache ca-certificates tzdata wget jq

# 2. 自動透過 GitHub API 抓取最新版本的下載鏈接並安裝
RUN LATEST_URL=$(wget -qO- https://api.github.com/repos/enfein/mieru/releases/latest | jq -r '.assets[] | select(.name | contains("linux-amd64")) | .browser_download_url') && \
    wget "$LATEST_URL" -O /usr/local/bin/mita && \
    chmod +x /usr/local/bin/mita

# 3. 複製配置文件與啟動腳本
COPY mita.json /etc/mita/mita.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 7860

# 4. 運行啟動腳本
ENTRYPOINT ["/entrypoint.sh"]
