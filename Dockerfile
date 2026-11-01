FROM ubuntu:22.04

# 安裝下載同解壓工具
RUN apt-get update && apt-get install -y wget tar && rm -rf /var/lib/apt/lists/*

# 下載並解壓 mita 3.39.0
RUN wget https://github.com/enfein/mieru/releases/download/v3.39.0/mita_3.39.0_linux_amd64.tar.gz && \
    tar -zxvf mita_3.39.0_linux_amd64.tar.gz && \
    chmod +x mita

# 手動建立 mita 專用 socket 目錄，確保萬無一失
RUN mkdir -p /var/run/mita

# 複製配置文件到根目錄
COPY mita.json /mita.json

# 暴露服務端口
EXPOSE 7860

# 啟動 mita
CMD ["./mita", "run"]
