FROM alpine:latest

# 1. 安裝基礎依賴
RUN apk add --no-cache ca-certificates tzdata

# 2. 如果該倉庫支援直接複製或有對應腳本，確保目錄結構正確
WORKDIR /app

# 3. 複製倉庫中的所有檔案到容器中
COPY . /app

# 4. 賦予執行權限並設置入口
RUN chmod +x /app/entrypoint.sh 2>/dev/null || true

EXPOSE 7860

ENTRYPOINT ["/app/entrypoint.sh"]
