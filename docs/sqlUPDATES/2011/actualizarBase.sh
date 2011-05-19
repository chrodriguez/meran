#!/bin/sh
conf="/etc/meran/revisionLocal"
pathRelativo=$(dirname $0)
if [ ! -f $conf ]; then
    echo 0 > $conf
fi
anterior=$(($(cat $conf)+1))
echo "Estamos verificando si es necesario aplicar cambios en la base";
echo "En caso de serlo es recomendable que realice un BACKUP de su base previamente";
BASE=$(grep ^database /etc/meran/meran.conf| awk '{split($0,a,"="); print a[2]}')
PASSWD=$(grep ^passINTRA /etc/meran/meran.conf| awk '{split($0,a,"="); print a[2]}')
USER=$(grep ^userINTRA /etc/meran/meran.conf| awk '{split($0,a,"="); print a[2]}')
echo $BASE;
echo $PASSWD;
echo $USER;
hasta=$(cat $pathRelativo/revision)
if [ $1 ]
then
	echo "Backupeando base en el directorio home del usuario $(whoami)"
	mysqldump --default-character-set=utf8 $BASE -u$USER -p$PASSWD > ~/backup_base.sql.rev$anterior;
fi


for i in `seq $anterior $hasta`; do
        echo $pathRelativo/sql.rev$i;
        if [ -e $pathRelativo/sql.rev$i ]; then
            echo "Aplicando sql.rev$i";
            mysql --default-character-set=utf8 $BASE -u$USER -p$PASSWD < $pathRelativo/sql.rev$i;
        fi;
done;
echo $hasta > $conf
