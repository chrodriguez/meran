#!/bin/bash
version=0.2
if [ $(uname -a|grep amd64|wc -l) -gt 0 ];
  then 
     versionKernel=64;
  else
     versionKernel=32;
fi;
echo "Bienvenido al instalador de meran version $version para sistemas de $versionKernel bits" 

generarConfSphinx()
{
  sed s/reemplazarID/$ID/g $sources_MERAN/sphinx.conf > /tmp/$ID.sphix.conf
  sed s/reemplazarIUSER/$IUSER_BDD_MERAN/g /tmp/$ID.sphix.conf > /tmp/$ID.sphix2.conf
  sed s/reemplazarIPASS/$IPASS_BDD_MERAN/g /tmp/$ID.sphix2.conf > /tmp/$ID.sphix.conf
  sed s/reemplazarDATABASE/$BDD_MERAN/g /tmp/$ID.sphix.conf > $DESTINO_MERAN/$ID/sphinx/etc/sphinx.conf
  rm /tmp/$ID.sphix*

}
generarLogRotate()
{
  sed s/reemplazarID/$ID/g logrotate.d-meran > /etc/logrotate.d/logrotate.d-meran$ID
  #Logs de meran
  mkdir -p /var/log/meran/$ID
  
}

generarJaula()
{
  sed s/reemplazarID/$ID/g $sources_MERAN/apache-jaula-ssl > /etc/apache2/sites-available/$ID-apache-jaula-ssl
  sed s/reemplazarID/$ID/g $sources_MERAN/apache-jaula-opac > /etc/apache2/sites-available/$ID-apache-jaula-opac
  #Generar certificado de apache
  echo "Generando el certificado de apache"
  mkdir -p /etc/apache2/ssl/$ID
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/apache2/ssl/$ID/apache.pem -out /etc/apache2/ssl/$ID/apache.pem
  a2ensite $ID-apache-jaula-ssl
  a2ensite $ID-apache-jaula-opac
}

crearBaseDedatos()
{
  #Esto es lo que hay que fixear.....  
  echo "Creando Base de DAtos, esto se va a demorar un buen rato"
  mysql --default-character-set=utf8  $BDD_MERAN -u$USER_BDD_MERAN -p$PASS_BDD_MERAN < /root/basePrueba.sql
  echo "FIXMEEEE. esto deberia estar en el archivo pasa que pesa 300 megas"
  echo "Asignando permisos al indice, vamos a requerirle una vez mas la pass."
  mysql --default-character-set=utf8  $BDD_MERAN -p < /tmp/$ID.permisosbdd6
}     
generarPermisosBDD()
{
  head -n2 $sources_MERAN/permisosbdd.sql | sed s/reemplazarDATABASE/$BDD_MERAN/g > /tmp/$ID.permisosbdd
  sed s/reemplazarUSER/$USER_BDD_MERAN/g /tmp/$ID.permisosbdd > /tmp/$ID.permisosbdd2
  sed s/reemplazarPASS/$PASS_BDD_MERAN/g /tmp/$ID.permisosbdd2 > /tmp/$ID.permisosbdd3
  echo "Tenemos que crear la base de datos $DD_MERAN y para eso pediremos los permisos de root"
  mysql -p -uroot < /tmp/$ID.permisosbdd3
  tail -n1 $sources_MERAN/permisosbdd.sql | sed s/reemplazarDATABASE/$BDD_MERAN/g > /tmp/$ID.permisosbdd4
  sed s/reemplazarIUSER/$IUSER_BDD_MERAN/g  /tmp/$ID.permisosbdd4 > /tmp/$ID.permisosbdd5
  sed s/reemplazarIPASS/$IPASS_BDD_MERAN/g /tmp/$ID.permisosbdd5 > /tmp/$ID.permisosbdd6
  echo "Procederemos a crear la base de datos y asignarle los permisos necesarios"
  crearBaseDedatos
  rm /tmp/$ID.permisosbdd*
}


generarConfiguracion()
{
  database=reemplazarDATABASE
  sed s/reemplazarID/$ID/g $sources_MERAN/meran.conf > /tmp/$ID.meran.conf
  sed s/reemplazarUSER/$USER_BDD_MERAN/g /tmp/$ID.meran.conf > /tmp/$ID.meran2.conf
  sed s/reemplazarPASS/$PASS_BDD_MERAN/g /tmp/$ID.meran2.conf > /tmp/$ID.meran.conf
  sed s/reemplazarDATABASE/$BDD_MERAN/g /tmp/$ID.meran.conf > $CONFIGURACION_MERAN/$ID.conf
  rm /tmp/$ID.meran
}

usage()
{
cat << EOF
usage: $0 options

Este script necesita si o si el parametro -i

OPTIONS:
   -h      Show this message
   -i      Identificador para esta instalación de meran. Este Identificador se va a utilizar en todo
   -d      Carpeta DESTINO donde se guardara meran. Por defecto /usr/share/meran
   -b      Base de datos a usar. Por Defecto va a ser meran
   -u      Usuario que se va a conectar a la base de datos. Por defecto kohaadmin
   -p      Pass del usuario que se va a conectar a la base de dato. Por defecto sera un random
   -s      Usuario que se va a utilizar en el indic. Por defecto indice
   -w      Pass del usuario que se va a utilizar en el indice. Por defecto sera un random
   -c      directorio donde se guardará la configuracion de meran. Por defecto sera /etc/meran y el archivo de configuracion sera $ID.conf
EOF
}

ID=
sources_MERAN=$(dirname "${BASH_SOURCE[0]}")
DESTINO_MERAN="/usr/share/meran"
CONFIGURACION_MERAN="/etc/meran"
BDD_MERAN="meran"
USER_BDD_MERAN="kohaadmin"
PASS_BDD_MERAN=`</dev/urandom tr -dc A-Za-z0-9 | head -c8`
IUSER_BDD_MERAN="indice"
IPASS_BDD_MERAN=`</dev/urandom tr -dc A-Za-z0-9 | head -c8`

while getopts “h:i:d:b:u:p:s:w:c:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         i)
             ID=$OPTARG
             ;;
         d)
             DESTINO_MERAN=$OPTARG
             ;;
         b)
             BDD_MERAN=$OPTARG
             ;;
         u)
             USER_BDD_MERAN=$OPTARG
             ;;
         p)
             PASS_BDD_MERAN=$OPTARG
             ;;
         s)
             IUSER_BDD_MERAN=$OPTARG
             ;;
         w)
             IPASS_BDD_MERAN=$OPTARG
             ;;
         c)
             CONFIGURACION_MERAN=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $ID ]] 
then
     usage
     exit 1
fi

if [ $(whoami) = root ];
  then
    echo "Sos root asi que no hay problema, adelante!!!"
  else
    echo "Hay que ser root"
    exit 1
fi

if [ $(dpkg -l |grep apache2|grep ii |wc -l ) -eq 0 ];
  then
  echo "Apache no se detecta instalado"
  echo "¿Quiere proceder a instalar toda la base necesaria para Meran?"
  select OPCION in Instalar No_instalar
    do
      if [ $OPCION = Instalar ]; 
        then
          echo "Procederemos a instalar todo lo necesario sobre Debian GNU/Linux"
          echo "Para hacerlo hay q ser superusuario"
          #Instalar paquetes
          #su
          apt-get update
          apt-get install apache2 mysql-server libapache2-mod-perl2 htmldoc libgd2-xpm libxpm4 htmldoc


          #Configurar apache
          echo "Procederemos a habilitar en apache los modulos necesarios"
          a2enmod rewrite
          a2enmod expires
          a2enmod ssl
          a2enmod headers

          echo "Procederemos a habilitar en apache los sites"
          a2dissite default
          break
      else
        echo "NO se instalará nada base"
        break
      fi
    done
fi

echo "Seleccione el tipo de Instalacion que quiere realizar"

select OPCION in Jaula Sistema
  do
  if [ $OPCION = Jaula ]; 
    then
      echo "Procediendo a la Instalación como Jaula de la aplicación"
      echo "Este proceso instalará los módulos específicos para la arquitectura de su Kernel que ya vienen precompilados y se distribuyen junto con Meran"
      echo "Su sistema es de $versionKernel bits"
      echo "Este instalador automático ubicará todos los archivos en el path por defecto $DESTINO_MERAN utilizando para la configuración del sistema /etc/meran/meran.conf"
      fecha=$(date +%Y%m%d%H%M)
      echo $fecha > ./fecha_instalacion
      if [ -e $CONFIGURACION_MERAN/meran$ID.conf ]; then
                echo "El archivo de configuración ya existía"
                mv $CONFIGURACION_MERAN/meran$ID.conf $CONFIGURACION_MERAN/meran$ID.$fecha.conf
                echo "Se backupeo el archivo original a /etc/meran/meran.$fecha.conf"
      fi
      if [ ! -d $CONFIGURACION_MERAN ]; then
        echo "El directorio de configuración no existía, lo creamos\n"
        mkdir $CONFIGURACION_MERAN
      fi
      generarConfiguracion
      if [ -d $DESTINO_MERAN/$ID ]; then
                echo "Ya existe el directorio de archivos, lo backupeamos"
                mv $DESTINO_MERAN/$ID $DESTINO_MERAN/$ID$fecha
                echo "Se backupeo el directorio original a $DESTINO_MERAN$fecha"
      fi
      mkdir -p $DESTINO_MERAN/$ID
      echo "Procedemos a la instalación"
      echo "Descomprimiendo Intranet y Opac" 
      tar xzf $sources_MERAN/intranetyopac.tar.gz -C $DESTINO_MERAN/$ID
      echo "Descomprimiendo las dependencias" 
      tar xzf $sources_MERAN/jaula$versionKernel.tar.gz -C $DESTINO_MERAN/$ID/intranet/modules/C4/
      echo "Descomprimiendo sphinxsearch" 
      tar xzf $sources_MERAN/sphinx$versionKernel.tar.gz -C $DESTINO_MERAN/$ID
      echo "Generando Archivos de logs y logrotate"
      generarLogRotate
      echo "Copiando configuración de sphinx" 
      generarConfSphinx
      echo "Copiando los Virtualhosts"
      generarJaula 
      #Crear bdd
      echo "FIXME Faltan configurar los BDD"
      echo "ESto se configuraria desde el web, ahora lo estoy haciendo desde un archivo que llevo de la maquina de gaspo, hay que borrarlo"
      echo "Generando la Base de datos"
      echo "FIXXXXXXXX habria q parametrizar la base y la conexion"
      generarPermisosBDD
      
      #Configurar cron
      echo "FIXME Faltan configurar los Crons"
      echo "La instalación esta concluida"
      echo "Reiniciaremos los servicios"
      #Reiniciar apache 
      /etc/init.d/apache2 restart
      #Iniciar sphinx
      echo "Ahora el Sphinx"
      if [ $(netstat -natp |grep searchd |grep 9312|wc -l) -gt 0 ]
        then
          echo "Sphinx ya esta corriendo vas a tener que combinar a mano el archivo de configuracion y generar los indices"
          echo "El archivo generado es $DESTINO_MERAN/$ID/sphinx/etc/sphinx.conf "
        else
          echo "Como Sphinx no estaba ejecutandose lo vamos a hacer ahora"
          $DESTINO_MERAN/$ID/sphinx/bin/indexer -c $DESTINO_MERAN/$ID/sphinx/etc/sphinx.conf --all --rotate
          $DESTINO_MERAN/$ID/sphinx/bin/searchd -c $DESTINO_MERAN/$ID/sphinx/etc/sphinx.conf
      fi
      break
    else
      echo "Solicitó una instalación sistemica de Meran, lo que significa que se modificará el sistema base."
      echo "Para continuar con la instalación dependerá de la buena voluntad del Mono que termine el script."
      break
  fi
done
