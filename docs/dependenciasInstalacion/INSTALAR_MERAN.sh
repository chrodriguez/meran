#!/bin/bash
#obtener el código fuente
apt-get install git-core -y
cd /usr/share/
git clone ssh://root@proyectos.linti.unlp.edu.ar/var/meran
cd /usr/share/meran/docs/dependenciasInstalacion/
#Configurar apache
cp ../configuracion/apache/* /etc/apache2/sites-availables
a2ensite opac
a2ensite ssl
#Instalar dependencias
sh dependenciasKOHA.sh
#Configurar Meran
mkdir /etc/meran
cp ../configuracion/meran/koha.conf /etc/meran
chown -R +r /etc/meran/koha.conf
#Logs de meran
mkdir /var/log/meran
cp ../configuracion/logrotate.d/meran /etc/logrotate.d/
#Configurar Sphinx
cp ../configuracion/sphinx/sphinx.conf /etc/sphinxsearch/sphinx.conf

#Configurar cron
#Crear bdd
#Reiniciar apache 
