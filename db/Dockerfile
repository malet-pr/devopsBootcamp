FROM postgres:15-alpine
COPY words.sql /docker-entrypoint-initdb.d/
EXPOSE 5432

ARG POSTGRES_USER=default_user
ARG POSTGRES_PASSWORD=default_password
ARG POSTGRES_DB=default_db
ARG PORT=default_port

ENV POSTGRES_USER $POSTGRES_USER
ENV POSTGRES_PASSWORD $POSTGRES_PASSWORD
ENV POSTGRES_DB $POSTGRES_DB
ENV PORT $PORT

VOLUME /data/bootcamp/postgresql