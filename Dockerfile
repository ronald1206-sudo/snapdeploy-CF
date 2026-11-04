FROM alpine:latest

# 1. 安裝系統依賴與下載解壓工具
RUN apk add --no-cache ca-certificates tzdata wget tar

# 2. 下載官方最新版本的 tar.gz 壓縮包並解壓安裝到系統路徑
RUN wget https://github.com/enfein/mieru/releases/latest/download/mieru-linux-amd64.tar.gz -O /tmp/mieru.tar.gz && \
    tar -zxvf /tmp/mieru.tar.gz -C /tmp && \
    mv /tmp/mieru /usr/local/bin/mita && \
    chmod +x /usr/local/bin/mita && \
    rm -rf /tmp/mieru.tar.gz

# 3. 複製配置文件與啟動腳本
COPY mita.json /etc/mita/mita.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 7860

# 4. 運行啟動腳本
ENTRYPOINT ["/entrypoint.sh"]
