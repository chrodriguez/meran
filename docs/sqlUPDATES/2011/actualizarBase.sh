#!/bin/sh
conf="/etc/meran/revisionLocal"
pathRelativo=$(dirname $0)
if [ ! -f $conf ]; then
    echo 0 > $conf
else 
    anterior=$(($(cat $pathRelativo/revision)+1))
    echo "Estamos verificando si es necesario aplicar cambios en la base";
    echo "En caso de serlo es recomendable que realice un BACKUP de su base previamente";
    BASE=$(grep ^database /etc/meran/meran.conf| awk '{split($0,a,"="); print a[2]}')
    PASSWD=$(grep ^pass /etc/koha/meran.conf| awk '{split($0,a,"="); print a[2]}')
    USER=$(grep ^user /etc/koha/meran.conf| awk '{split($0,a,"="); print a[2]}')
    echo "Backupeando base";
    hasta=$(cat $pathRelativo/revision)
    mysqldump --default-character-set=utf8 $BASE -u$USER -p$PASSWD > ~/backup_base.sql.rev$anterior;
    for i in `seq $anterior $hasta`; do
          if [ -e $pathRelativo/sql.rev$i ]; then
                echo "Aplicando sql.rev$i";
                mysql --default-character-set=utf8 $BASE -u$USER -p$PASSWD < $pathRelativo/sql.rev$i;
          fi;
    done;
fi