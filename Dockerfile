FROM enfein/mieru:latest

# 複製配置文件與啟動腳本
COPY mita.json /etc/mita/mita.json
COPY entrypoint.sh /entrypoint.sh

# 賦予腳本執行權限
RUN chmod +x /entrypoint.sh

EXPOSE 7860

# 執行啟動腳本
ENTRYPOINT ["/entrypoint.sh"]
