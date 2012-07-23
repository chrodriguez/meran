#!/bin/bash
version=0.1
sources_MERAN=$(dirname "${BASH_SOURCE[0]}")
if [ $(uname -a|grep amd64|wc -l) -gt 0 ]
  then 
     versionKernel=64;
  else
     versionKernel=32;
fi;
echo "Bienvenido al instalador de meran version $version"
echo "Seleccione el tipo de Instalacion que quiere realizar"
select OPCION in Jaula Sistema
  do
  echo $OPCION
  if [ $OPCION = Jaula ]; then
      echo "Procediendo a la Instalación como Jaula de la aplicación"
      echo "Este proceso instalará los módulos específicos para la arquitectura de su Kernel que ya vienen precompilados y se distribuyen junto con Meran"
      echo "Su sistema es de $versionKernel bits"
      echo "Este instalador automático ubicará todos los archivos en el path por defecto /usr/share/meran utilizando para la configuración del sistema /etc/meran/meran.conf"
      if [ -e /etc/meran/meran.conf ] then
                echo "El archivo de configuración ya existía"
                fecha=$(date +%Y%m%d%H%M)
                mv /etc/meran/meran.conf /etc/meran/meran.$fecha.conf
                echo "Se backupeo el archivo original a /etc/meran/meran.$fecha.conf"
      fi
      if [ ! -d /etc/meran/ ] then
        mkdir /etc/meran
      fi
      cp $sources_MERAN/meran.conf /etc/meran.conf
      if [ -d /usr/share/meran ] then
                echo "Ya existe el directorio"
                mv /usr/share/meran /usr/share/meran$fecha
                echo "Se backupeo el directorio original a //usr/share/meran$fecha"
          else 
            if [ ! -d /usr/share/meran/ ] then
                mkdir /usr/share/meran
            fi
            tar xzvf $sources_MERAN/intranetyopac.tar.gz /usr/share/meran
            tar xzvf $sources_MERAN/jaula$versionKernel.tar.gz -C /usr/share/meran/intranet/modules/C4/
            tar xzvf $sources_MERAN/sphinx$versionKernel.tar.gz -C /usr/share/meran/intranet/
            cp $sources_MERAN/sphinx.conf /usr/share/meran/intranet/sphinx/etc/
      break

  else
      echo "Solicitó una instalación sistemica de Meran, lo que significa que se modificará el sistema base."
      echo "Para continuar con la instalación dependerá de la buena voluntad del Mono que termine el script."
      break
  fi
done
