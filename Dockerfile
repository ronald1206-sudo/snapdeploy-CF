# 第一階段：使用官方 Go 環境下載並編譯最新版 mita 服務端
FROM golang:1.22-alpine AS builder

WORKDIR /app
RUN apk add --no-cache git && \
    go install github.com/enfein/mieru/cmd/mita@latest

# 第二階段：提取編譯產物，構建極簡運行容器
FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata

# 複製已編譯好的 mita 執行檔
COPY --from=builder /go/bin/mita /usr/local/bin/mita
RUN chmod +x /usr/local/bin/mita

# 複製配置文件
COPY mita.json /etc/mita/mita.json

EXPOSE 7860
WORKDIR /etc/mita

CMD ["mita", "server", "--config", "/etc/mita/mita.json"]
