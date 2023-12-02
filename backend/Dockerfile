FROM node:slim

WORKDIR /usr/app
COPY . .

ARG DATABASE_URL=default_db_url
ARG DATABASE_NAME=default_db_name
ARG HOST=default_host
ARG PORT=default_port

ENV DATABASE_URL=$DATABASE_URL
ENV DATABASE_NAME=$DATABASE_NAME
ENV HOST=$HOST
ENV PORT=$PORT

RUN npm install
EXPOSE 5000
CMD ["npm","start"]
