apt-get update
wget --no-check-certificate https://raw.githubusercontent.com/mishaelre/ovz-bbr-powered/master/rinetd
chmod +x rinetd

cat > /root/rinetd.conf<<-EOF
# bindadress bindport connectaddress connectport
0.0.0.0 12420 0.0.0.0 12420
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
