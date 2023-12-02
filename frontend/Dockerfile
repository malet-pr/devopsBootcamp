FROM node:slim

WORKDIR /usr/app
COPY . .

ARG API_URI
ENV API_URI=${API_URI}

RUN npm install
EXPOSE 3000
CMD ["npm","start"]
