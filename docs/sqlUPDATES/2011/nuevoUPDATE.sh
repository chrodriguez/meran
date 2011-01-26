#!/bin/sh
conf="/etc/meran/revisionLocal"
pathRelativo=$(dirname $0)
contador=$(cat $pathRelativo/revision)
touch $pathRelativo/sql.rev$(($contador+1))
echo $(($contador+1)) > $pathRelativo/revision
echo "Tenes que editar $pathRelativo/sql.rev$(($contador+1)) y agregar todos los cambios que le hiciste a la base de datos"
echo "Ahora subimos para reservar el nro de revision"
cd $pathRelativo/../../
git ci "mensaje automatico generado para el sql.rev$(($contador+1))"
git up
git push
cd $OLDPWD
