FROM node:20
WORKDIR /app
COPY package.json index.js ./
RUN npm install
EXPOSE 7860
CMD ["node", "index.js"]
