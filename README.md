# Despliegue de 295words

## Armado de imágenes
### Base de datos
Se creó un Dockerfile para armar la imagen
* Se usó como imagen base: postgres:15-alpine
* Se la preparó para correr un script de inicialización: words.sql
* Se la preparó para recibir usuario, password y nombre de la base como argumentos
* Se la preparó para exponer el puerto 5432
### API java
Se creó un Dockerfile para armar la imagen
* Se usó como imagen base: amazoncorretto:21
* Se copiaron el jar y las dependencias en el contenedor
* Se la preparó para exponer el puerto 8080
* Se la preparó para que ejecute el jar al armar el contenedor
### Webapp Go/Angular
Se creó un Dockerfile para armar la imagen
* Se usó como imagen base: golang:alpine
* Se copió el archivo go.mod en el contenedor
* Se preparó el contenedor para que descargara las dependencias de go.mod
* Se la preparó para que copiara el resto de la webapp a continuación
* Se la preparó para exponer el puerto 80
* Se la preparó para que levantara la aplicación al armar el contenedor

## Armado del docker-compose
* Se armó un docker-compose con tres servicios: db, api y web
* Cada servicio levanta su correspondiente imagen
* Se preparó el yaml para que recibiera variables de entorno
* Se crearon dos networks:
    - front: para que se comuniquen la api y la webapp (Se incluyó la base en esta red porque se decidió exponerla para tener acceso a modificarla desde afuera). 
    - back: para que se comuniquen la base y la api
* Se preparó todo para que la base se exponga en el puerto 5432 y la webapp en el 8084. La api no se expone al exterior.
* se establecieron las dependencias de cada servicio para que se levanten los contenedores en orden: db -> api -> web

## Archivo .env
Se creó un archivo con variables de entorno para no exponer usuarios y claves en los otros archivos. Se subieron al repositorio sin datos. Para poder levantar la aplicación, hay que empezar por completar esos datos.

## Shell script
Se preparó un script para automatizar todo el proceso:
1) Se leen las variables de entorno
2) Se efectua el login en Docker Hub
3) Se crea la imagen para la base de datos y se sube a Docker Hub
4) Se construye el jar de la api usando ``` mvn clean package ```. Para poder completar este paso, la máquina desde donde se ejecute el script tiene que tener instalado java 17 o superior y maven 3.4 o superior. Además tienen que estar bien configurados en el PATH.
5) Se crea la imagen de la api y se la sube a Docker Hub
6) Se crea la imagen de la webapp y se la sube a Docker Hub
7) Una vez creadas las imagenes, se ejecuta docker-compose.yaml incluyendo el archivo .env  en el comando para que utilice las variables de entorno en su ejecución.

## Resultados

### Contenedores levantados por docker-compose
![Captura de la terminal](/images/docker-compose.png)

### Base de datos cargada con los datos iniciales
![Captura de DBeaver](/images/db.png)

### Aplicación funcionando
![Captura de la aplicación corriendo en el navegador](/images/app.png)
