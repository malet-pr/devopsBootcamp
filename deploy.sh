#!/bin/sh

echo "\n==================== INICIO DESPLIEGUE 295WORDS ==========================\n"

# Para obtener una forma rápida de volver al directorio del script
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
cd "$SCRIPT_DIR"

# Lee archivo con variables de entorno, usuarios y claves
if [ -f .env ]; then
  while read -r line; do
    # echo "Line read: $line"
    export "$line"
  done < .env
else
  echo "Error: no se encontró el archivo .env"
  exit 1
fi

echo "\n======================== LOGIN EN DOCKER HUB ============================="
REGISTRY_URL="https://index.docker.io/v1/"
echo "$DOCKER_PASSWORD" | docker login $REGISTRY_URL -u $DOCKER_USERNAME --password-stdin 2>/dev/null
# unset PASSWORD

echo "\n======================== IMAGEN DE POSTGRESQL ============================"
cd db
# Construcción de la imagen
docker build -t $DOCKER_USERNAME/bootcamp-postgres \
  --build-arg POSTGRES_USER=$POSTGRES_USER \
  --build-arg POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  --build-arg POSTGRES_DB=$POSTGRES_DB  \
  --build-arg PORT=5432 .
# Subida a Docker Hub
docker push $DOCKER_USERNAME/bootcamp-postgres:latest
cd "$SCRIPT_DIR"

echo "\n========================= IMAGEN DE JAVA ================================="
cd api
# Construcción del jar
mvn clean package > maven_build.log 2>&1
if [ $? -eq 0 ]; then
  echo "Maven build exitoso. Puede acceder al log en maven_build.log"
else
  echo "Maven build falló. Puede acceder al log en maven_build.log"
fi
# Construcción de la imagen
docker build -t $DOCKER_USERNAME/bootcamp-words .
# Subida a Docker Hub
docker push $DOCKER_USERNAME/bootcamp-words:latest
cd "$SCRIPT_DIR"

echo "\n========================== IMAGEN DE GO =================================="
cd web
# Construcción de la imagen
docker build -t $DOCKER_USERNAME/bootcamp-go .
# Subida a Docker Hub
docker push $DOCKER_USERNAME/bootcamp-go:latest
cd "$SCRIPT_DIR"

echo "\n====================== CORRER DOCKER-COMPOSE ============================="
docker-compose --env-file .env up -d
