FROM golang:1.22-alpine

# 1. 安裝 git 同編譯工具
RUN apk add --no-cache git

# 2. 克隆官方源碼並編譯 mita（避開版本號標籤報錯）
RUN git clone --depth 1 --branch v3.39.0 https://github.com/enfein/mieru.git /app/mieru
WORKDIR /app/mieru/cmd/mita
RUN go build -o /mita

# 3. 建立專用系統用戶與群組（解決 getUid 報錯）
RUN addgroup -S mita && adduser -S mita -G mita

# 4. 建立運行目錄並設置權限
RUN mkdir -p /var/run/mita && chown -R mita:mita /var/run/mita

# 5. 複製配置文件
COPY mita.json /mita.json

# 6. 暴露端口並以 root 權限啟動（避免權限不足）
EXPOSE 7860
CMD ["/mita", "run"]
