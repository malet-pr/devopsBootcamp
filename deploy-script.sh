#!/bin/bash

USERID=$(id -u)

if [ "${USERID}" -ne 0 ]; then
    echo -e "\nCorrer con usuario ROOT"
    exit
fi 

echo -e "\n============ ACTUALIZAR SERVIDOR E INSTALAR CURL ======================="
apt-get update
apt-get install -y curl
echo -e "\nEl Servidor se encuentra Actualizado"


echo -e "\n======================== INSTALAR MARIADB ============================="
if dpkg -s mariadb-server > /dev/null 2>&1; then
    echo -e "\nMariaDB ya se encuentra instalada"
else    
    echo -e "\nInstalando MARIA DB"
    apt install -y mariadb-server
# Se inicializa MariaDB
    systemctl start mariadb
    systemctl enable mariadb
# Solicita usuario y contraseña de la base de datos
    read -p "Ingresa el usuario la base de datos: " codeuser
    read -s -p "Ingresa la contraseña de la base de datos: " codepass
# Se crean la base, un usuario, se le dan permisos y se carga el script con tablas y datos
    mysql -u root -p"$codepass" <<EOF
    CREATE DATABASE IF NOT EXISTS devopstravel;
    CREATE USER IF NOT EXISTS '$codeuser'@'localhost' IDENTIFIED BY '$codepass';
    GRANT ALL PRIVILEGES ON devopstravel.* TO '$codeuser'@'localhost';
    FLUSH PRIVILEGES; 
EOF
# Se carga el script con tablas y datos
    mysql -u "$codeuser" -p"$codepass" devopstravel < db-load-script.sql
fi

echo -e "\n====== REVISAR FUNCIONAMIENTO DE LA BASE DE DATOS ================="
db_status=$(systemctl is-active mariadb)
if [ "$db_status" = "active" ]; then
    echo "La base de datos está en funcionamiento"
else
    echo "La base de datos no está en funcionamiento"
fi


echo -e "\n================== INSTALAR APACHE Y PHP ============================"
if dpkg -s apache2 > /dev/null 2>&1; then
    echo -e "\nApache2 se encuentra ya instalado"
else    
    echo -e "\nInstalando Apache2"
    apt install -y apache2
    apt install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl
    systemctl start apache2
    systemctl enable apache2
    mv /var/www/html/index.html /var/www/html/index.html.bkp
fi

echo -e "\n================ AJUSTAR CONFIGURACIÓN DE PHP ====================="
php_ini_path="/etc/php/7.2/apache2/php.ini"  # Adjust the path based on your PHP version and installation
# Agregar index.php a la lista de archivos y reiniciar
sed -i '/^index/s/\(.*\)/\1 index.php/' $php_ini_path
systemctl restart apache2

echo -e "\n================ PROBAR COMPATIBILIDAD DE PHP ====================="
php_test_file="/var/www/html/info.php"  # Adjust the path based on your web server configuration
# Crear un archivo php y probarlo
echo "<?php phpinfo(); ?>" > $php_test_file
php_result=$(curl -s http://localhost/info.php)
# Ver si se ejecutó correctamente
if [[ "$php_result" == *"<title>phpinfo()</title>"* ]]; then
    echo "PHP está configurado correctamente y la prueba fue exitosa"
else
    echo " La prueba de compatibilidad de PHP falló"
fi
# Eliminar archivo de prueba
rm $php_test_file

echo -e "\n================ REVISAR FUNCIONAMIENTO DE PHP ===================="
php_status=$(systemctl is-active apache2) 
if [ "$php_status" = "active" ]; then
    echo "PHP está en funcionamiento"
else
    echo "PHP no está en funcionamiento"
fi


echo -e "\n===================== INSTALAR GIT ==============================="
if dpkg -s git > /dev/null 2>&1; then
    echo -e "\nGit se encuentra ya instalado"
else   
    apt install -y git
    echo -e "\nInstalando GIT"
fi

echo -e "\n======================= CLONAR REPO =============================="
repo="https://github.com/roxsross/bootcamp-devops-2023.git" 
branch="clase2-linux-bash"
subfolder="app-295devops-travel"
clone_dir="/tmp/devops_project"
cd /tmp/devops_project
if [ -d "$clone_dir" ]; then
    echo -e "\nEl proyecto ya existe, se realiza un pull"
    cd $clone_dir
    git pull
else
    echo -e "\nClonando el repositorio "
    mkdir $clone_dir
    git clone -b $branch --single-branch $repo $clone_dir  
fi  
source_dir="$clone_dir/$subfolder"
if [ -d "$source_dir" ]; then
    cp -r "$source_dir"/* /var/www/html
    sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
else
    echo -e "\nNo se encocntró la carpeta $subfolder en el repositorio."
fi


echo -e "\n=================== REINICIAR SERVER ============================"
systemctl reload apache2


echo -e "\n======================== NOTIFICAR =============================="

# Configura el token de acceso de tu bot de Discord
DISCORD="https://discord.com/api/webhooks/1169002249939329156/7MOorDwzym-yBUs3gp0k5q7HyA42M5eYjfjpZgEwmAx1vVVcLgnlSh4TmtqZqCtbupov"

# Obtiene el nombre del repositorio
REPO_NAME=$(basename $(git rev-parse --show-toplevel))
# Obtiene la URL remota del repositorio
REPO_URL=$(git remote get-url origin)
WEB_URL="localhost"
# Realiza una solicitud HTTP GET a la URL
HTTP_STATUS=$(curl -Is "$WEB_URL" | head -n 1)

# Verifica si la respuesta es 200 OK (puedes ajustar esto según tus necesidades)
if [[ "$HTTP_STATUS" == *"200 OK"* ]]; then
  # Obtén información del repositorio
    DEPLOYMENT_INFO2="Despliegue del repositorio $REPO_NAME - Nuria Malet Quintar:"
    DEPLOYMENT_INFO="La página web $WEB_URL está en línea."
    COMMIT="Commit: $(git rev-parse --short HEAD)"
    AUTHOR="Autor: $(git log -1 --pretty=format:'%an')"
    DESCRIPTION="Descripción: $(git log -1 --pretty=format:'%s')"
else
  DEPLOYMENT_INFO="La página web $WEB_URL no está en línea."
fi

# Construye el mensaje
MESSAGE="$DEPLOYMENT_INFO2\n$DEPLOYMENT_INFO\n$COMMIT\n$AUTHOR\n$REPO_URL\n$DESCRIPTION"

# Envía el mensaje a Discord utilizando la API de Discord
curl -X POST -H "Content-Type: application/json" \
     -d '{
       "content": "'"${MESSAGE}"'"
     }' "$DISCORD"

