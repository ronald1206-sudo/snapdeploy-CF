FROM golang:1.22-alpine

# 1. 安裝 git 同 build 工具
RUN apk add --no-cache git

# 2. 克隆源碼倉庫
RUN git clone --depth 1 --branch v3.39.0 https://github.com/enfein/mieru.git /app/mieru

# 3. 進入目錄並編譯 mita
WORKDIR /app/mieru/cmd/mita
RUN go build -o /mita

# 4. 建立運行所需嘅目錄
RUN mkdir -p /var/run/mita

# 5. 複製配置文件到根目錄
COPY mita.json /mita.json

# 6. 暴露端口並啟動
EXPOSE 7860
CMD ["/mita", "run"]
