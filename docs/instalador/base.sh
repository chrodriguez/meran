#!/bin/bash
echo "Procederemos a instalar todo lo necesario sobre Debian GNU/Linux"
#Instalar paquetes
apt-get update
apt-get install apache2 mysql-server htmldoc

#Configurar apache

echo "Procederemos a habilitar en apache los modulos necesarios"
a2enmod rewrite
a2enmod expires
a2enmod ssl

#Configurar cron
echo "FIXME Faltan configurar los Crons"


