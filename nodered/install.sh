#!/bin/sh

###########
# NodeRed #
###########
### Service SystemD, pour les installations normales  ###
mkdir -p /etc/systemd/system/multi-user.target.wants
echo "[Unit]
Description=NodeRed
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
NotifyAccess=main
ExecStart=/usr/sbin/node-red
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/multi-user.target.wants/node-red
### Service InitD, pour les installations avec Docker ###
echo "#!/bin/sh
### BEGIN INIT INFO
# Provides:    node-red
# Required-Start:  \$remote_fs \$syslog
# Required-Stop:  \$remote_fs \$syslog
# Default-Start:  2 3 4 5
# Default-Stop:    0 1 6
# Short-Description:  node-red
# Description:
#  Flow manager.
### END INIT INFO

set -e

PIDFILE=/var/run/node-red.pid
DAEMON=/usr/bin/node-red
OPTIONS=\"--max-old-space-size=128 --userDir=/root/.node-red\"
test -x \${DAEMON} || exit 0

umask 022

. /lib/lsb/init-functions

case \"\$1\" in
  start)
    log_daemon_msg \"Starting node-red daemon\" \"node-red\"
    if start-stop-daemon --start --quiet --oknodo --background  --make-pidfile --pidfile \${PIDFILE} --startas /bin/bash -- -c \"exec \${DAEMON} \${OPTIONS} > /var/log/nodered.log 2>&1\"; then
      log_end_msg 0
    else
      log_end_msg 1
    fi
    ;;
  stop)
    log_daemon_msg \"Stopping node-red daemon\" \"node-red\"
    if start-stop-daemon --stop --quiet --oknodo --pidfile \${PIDFILE}; then
      log_end_msg 0
      rm -f \${PIDFILE}
    else
      log_end_msg 1
    fi
    ;;
  status)
    if init_is_upstart; then
      exit 1
    fi
    status_of_proc -p \${PIDFILE} \${DAEMON} node-red && exit 0 || exit \$?
    ;;
  *)
    log_action_msg \"Usage: /etc/init.d/node-red {start|stop|reload|force-reload|restart|try-restart|status}\"
    exit 1
esac
exit 0" > /etc/init.d/node-red
chmod +x /etc/init.d/node-red
