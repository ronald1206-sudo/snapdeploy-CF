FROM enfein/mieru:latest

COPY mita.json /etc/mita/mita.json

EXPOSE 7860

CMD ["mita", "apply", "-c", "/etc/mita/mita.json"]
