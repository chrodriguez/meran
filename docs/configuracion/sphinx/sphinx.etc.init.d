#! /bin/sh
# /etc/init.d/sphinx: start the sphinx search daemon.

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin

pidfile=/tmp/searchd.pid
binpath=/usr/local/bin/searchd

SPHINX="--config /usr/local/etc/sphinx.conf"
NAME=searchd
DESC="sphinx search daemon"

test -f $binpath || exit 0

echo "LE_TY"
test ! -r /etc/default/sphinx || . /etc/default/sphinx

running()
{
    # No pidfile, probably no daemon present
    #
    if [ ! -f $pidfile ]
    then
	return 1
    fi

    pid=`cat $pidfile`

    # No pid, probably no daemon present
    #
    if [ -z "$pid" ]
    then
	return 1
    fi

    if [ ! -d /proc/$pid ]
    then
	return 1
    fi

    cmd=`cat /proc/$pid/cmdline | tr "\000" "\n"|head -n 1`

    # No syslogd?
    #
    if [ "$cmd" != "$binpath" ]
    then
	return 1
    fi

    return 0
}

case "$1" in
  start)
    echo -n "Starting sphinx search daemon: searchd"
    start-stop-daemon --start --quiet --chuid www-data --group www-data  --exec $binpath -- $SPHINX
    echo "."
    ;;
  stop)
    echo -n "Stopping sphinx search daemon: searchd"
    start-stop-daemon --stop --chuid 999 --group 999 --retry TERM/1/TERM/1/TERM/4/KILL --quiet --exec $binpath --pidfile $pidfile
    echo "."
    ;;
  restart|force-reload)
    echo -n "Restarting sphinx search daemon: searchd"
    start-stop-daemon --stop --chuid 999 --group 999  --retry TERM/1/TERM/1/TERM/4/KILL --quiet --exec $binpath --pidfile $pidfile
    start-stop-daemon --start --chuid 999 --group 999  --quiet --exec $binpath -- $SPHINX
    echo "."
    ;;
  *)
    echo "Usage: /etc/init.d/shpinx {start|stop|restart|force-reload}"
    exit 1
esac

exit 0