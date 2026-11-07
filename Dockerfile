FROM node:18-alpine
WORKDIR /app
COPY . .
EXPOSE 7860
CMD ["node", "index.js"]
