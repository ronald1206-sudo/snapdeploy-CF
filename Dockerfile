FROM ubuntu:22.04

# 安裝 ca-certificates、wget同解壓工具
RUN apt-get update && apt-get install -y ca-certificates wget tar && rm -rf /var/lib/apt/lists/*

# 下載時加入 --no-check-certificate 略過憑證報錯
RUN wget --no-check-certificate https://github.com/enfein/mieru/releases/download/v3.39.0/mita_3.39.0_linux_amd64.tar.gz && \
    tar -zxvf mita_3.39.0_linux_amd64.tar.gz && \
    chmod +x mita

# 手動建立 mita 專用 socket 目錄
RUN mkdir -p /var/run/mita

# 複製配置文件到根目錄
COPY mita.json /mita.json

# 暴露服務端口
EXPOSE 7860

# 啟動 mita
CMD ["./mita", "run"]
