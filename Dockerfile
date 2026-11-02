FROM golang:1.22-alpine

# 安裝 Git同編譯工具
RUN apk add --no-cache git

# 直接拉取官方源碼並編譯安裝 mita
RUN go install github.com/enfein/mieru/cmd/mita@v3.39.0

# 建立 socket 目錄
RUN mkdir -p /var/run/mita

# 複製配置文件
COPY mita.json /mita.json

# 暴露端口
EXPOSE 7860

# 啟動 mita (Go install 安裝嘅 binary 會直接喺 PATH 入面)
CMD ["mita", "run"]
