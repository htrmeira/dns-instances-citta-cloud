#!/bin/bash -e

### BEGIN INIT INFO
# Provides:             start_dnsmasq
# Required-Start:       bootlogs $syslog
# Required-Stop:        bootlogs $syslog
# Should-Start:
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    start_dnsmasq
### END INIT INFO

PROG_NAME="Dnsmasq for OpenStack"

NET_DIR=/var/lib/neutron/dhcp
CONF_FILE=/opt/openstack-dns/dnsmasq.conf
VAR_DIR=/var/lib/dns-openstack
PID_FILE=$VAR_DIR/pid

if [[ -z "${PID}" && -e $PID_FILE ]]; then
    PID=`cat $PID_FILE`
fi

start() {
    echo "Starting $PROG_NAME"
    mkdir -p $VAR_DIR
    for neutron_network in `ls $NET_DIR`; do
        ADDN_HOSTS="$ADDN_HOSTS--addn-hosts=$NET_DIR/$neutron_network/addn_hosts "
    done;

    /usr/sbin/dnsmasq --conf-file=$CONF_FILE --pid-file=$PID_FILE $ADDN_HOSTS
    if [ $? -eq 0 ]; then
        exit 0;
    else
        exit 1;
    fi
}

stop() {
    if [[ -z "${PID}" ]]; then
        echo "$PROG_NAME is not running (missing pid)."
    elif [[ -e /proc/$PID/exe ]]; then
        echo "Killing $PROG_NAME..."
        kill $1 $PID
        if [ $? -eq 0 ]; then
	    echo "Killed"
        fi
    else
	echo "$PROG_NAME is not running (with pid: $PID)"
    fi
}

status() {
    if [[ -z "${PID}" ]]; then
        echo "$PROG_NAME is not running (missing pid)."
	exit 1;
    elif [[ -e /proc/${PID}/exe ]]; then
        echo "$PROG_NAME is running (pid: $PID)"
	exit 0;
    else
        echo "$PROG_NAME is not running (with pid: $PID)"
	exit 2;
    fi
}

restart() {
    stop;
    start;
}

force-stop() {
   stop -9;
}

force-restart() {
    stop -9;
    start;
}

usage() {
    echo "Usage: `basename $0` {start|stop|restart|force-stop|force-restart|status}" >&2
}

case $1 in
    start)
        start;
        ;;
    stop)
        stop;
        ;;
    status)
        status;
        ;;
    restart)
        restart;
        ;;
    force-stop)
        force-stop;
        ;;
    force-restart)
        force-restart;
        ;;
    *)
        usage;
        exit 4;
        ;;
esac
