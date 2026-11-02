FROM enfein/mieru:latest

COPY mita.json /etc/mita/mita.json

EXPOSE 7860

# 改用直接啟動或者不帶多餘參數
CMD ["mita", "--config", "/etc/mita/mita.json"]
