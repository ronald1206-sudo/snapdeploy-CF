FROM golang:1.22-alpine

# 1. 安裝 git 同編譯工具
RUN apk add --no-cache git

# 2. 克隆官方源碼並編譯 mita
RUN git clone --depth 1 --branch v3.39.0 https://github.com/enfein/mieru.git /app/mieru
WORKDIR /app/mieru/cmd/mita
RUN go build -o /mita

# 3. 建立專用系統用戶與群組
RUN addgroup -S mita && adduser -S mita -G mita

# 4. 建立運行所需嘅 socket 目錄同 mita 配置專用目錄 /etc/mita
RUN mkdir -p /var/run/mita && chown -R mita:mita /var/run/mita
RUN mkdir -p /etc/mita

# 5. 複製配置文件同時放到根目錄及 /etc/mita 夾入面
COPY mita.json /mita.json
COPY mita.json /etc/mita/mita.json

# 6. 暴露端口並啟動
EXPOSE 7860
CMD ["/mita", "run"]
