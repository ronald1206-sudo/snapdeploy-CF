# ---- 階段一：編譯器 ----
FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY . .

# 禁用 CGO，確保純靜態編譯，適配任何 Linux amd64 環境
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server main.go

# ---- 階段二：精簡運行環境 ----
FROM alpine:latest
RUN apk add --no-cache ca-certificates

# 嚴格創建 mita 依賴嘅系統路徑與目錄
RUN mkdir -p /etc/mita /var/run/mita

# 將本地的 mita.json 準確放置到 /etc/mita/ 目錄下
COPY mita.json /etc/mita/mita.json

# 複製編譯好的執行檔
COPY --from=builder /app/server /server

# 暴露平台指定端口
EXPOSE 7860

# 啟動命令
CMD ["/server"]
