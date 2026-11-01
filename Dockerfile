FROM ubuntu:22.04

# 1. 安裝必要工具與憑證
RUN apt-get update && apt-get install -y ca-certificates wget tar && rm -rf /var/lib/apt/lists/*

# 2. 明確下載 amd64 架構的 mita 程式
RUN wget --no-check-certificate https://github.com/enfein/mieru/releases/download/v3.39.0/mita_3.39.0_linux_amd64.tar.gz && \
    tar -zxvf mita_3.39.0_linux_amd64.tar.gz && \
    chmod +x mita

# 3. 建立運行所需嘅目錄
RUN mkdir -p /var/run/mita

# 4. 複製配置文件
COPY mita.json /mita.json

# 5. 暴露監聽端口
EXPOSE 7860

# 6. 啟動 mita
CMD ./mita run
