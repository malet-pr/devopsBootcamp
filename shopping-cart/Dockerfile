FROM node:slim
WORKDIR /express-docker
COPY . .
RUN npm install
CMD [ "node", "server.js" ]
EXPOSE 3002