#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================================#
#   System Required:  Debian8_x64                                   #
#   Description: One click Install lkl-bbr           #
#=================================================================#


apt-get update
wget --no-check-certificate https://raw.githubusercontent.com/mishaelre/ovz-bbr-powered/master/rinetd
chmod +x rinetd

cat > /root/rinetd.conf<<-EOF
# bindadress bindport connectaddress connectport
0.0.0.0 1001 0.0.0.0 1001
EOF

cat > /etc/systemd/system/rinetd.service<<-EOF
[Unit]
Description=rinetd
[Service]
ExecStart=/root/rinetd -f -c /root/rinetd.conf raw venet0:0
Restart=always
  
[Install]
WantedBy=multi-user.target
EOF

systemctl enable rinetd.service && systemctl start rinetd.service
