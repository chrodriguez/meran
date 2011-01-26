#!/bin/sh
conf="/etc/meran/revisionLocal"
pathRelativo=$(dirname $0)
echo "Actualizaste?S/N"
read respuesta
if [ "$respuesta" = "S" ] || [ "$respuesta" = "s" ]; then
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
else
    echo "Es necesario Actualizar antes para no tener conflicto con otro sql.rev##"
    echo "Ejecuta:"
    echo "git ci mensaje"
    echo "git up"
    echo "Actualizo automaticamente?"
    read respuesta
    if [ "$respuesta" = "S" ] || [ "$respuesta" = "s" ]; then
        cd $pathRelativo/../../
        git ci "mensaje automatico generado para la revision de sql $(($contador+1))"
        git up
        cd $OLDPWD
    fi
fi
