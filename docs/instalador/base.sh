#!/bin/bash
echo "Procederemos a instalar todo lo necesario sobre Debian GNU/Linux"
#Instalar paquetes
apt-get update
apt-get install apache2 mysql-server

#Configurar apache
echo "Copiando los Virtualhosts"
cp apache-jaula-* /eta/apache2/sites-available/

echo "Procederemos a habilitar en apache los modulos necesarios"
a2enmod rewrite
a2enmod expires
a2enmod ssl

echo "Procederemos a habilitar en apache los sites"
a2ensite apache-jaula-ssl
a2ensite apache-jaula-opac
a2disite default

#Generar certificado de apache
echo "Generando el certificado de apache"
mkdir /etc/apache2/ssl
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.pem -out /etc/apache2/ssl/apache.pem

#Crear bdd

#Configurar cron
echo "FIXME Faltan configurar los Crons"

#Reiniciar apache 
/etc/init.d/apache2 restart

#Iniciar sphinx
echo "FIXME Faltan iniciae el Sphinx"

#Reindexar
indexer --all --rotate
