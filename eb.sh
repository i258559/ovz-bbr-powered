#!/bin/bash
cat > /root/ebesucher.sh<<EOF
export DISPLAY=localhost:1.0
rm -rf ~/.vnc/*.log /tmp/plugtmp* > /dev/null
killall /usr/bin/x-www-browser >> /dev/null 2>&1
/usr/bin/firefox -new-tab http://www.ebesucher.com/surfbar/mishaelre > /dev/null 2>&1 &
EOF

chmod +x /root/ebesucher.sh
echo "0 */2 * * * root /root/ebesucher.sh" >>/etc/crontab
service cron restart
/root/ebesucher.sh 
