cd /root
apt-get update
apt-get install -y git
git clone -b manyuser https://github.com/shadowsocksr/shadowsocksr.git
bash /root/shadowsocksr/initcfg.sh
rm -f /root/shadowsocksr/user-config.json
cat > /root/shadowsocksr/user-config.json<<-EOF
{
    "server":"0.0.0.0",
    "server_ipv6":"::",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "port_password":{
        "12420":{"protocol":"origin", "password":"133hhlovell!"}
    },
    "timeout":300,
    "method":"rc4-md5",
    "protocol": "origin",
    "protocol_param": "",
    "obfs": "tls1.2_ticket_auth",
    "obfs_param": "",
    "redirect": "",
    "dns_ipv6": false,
    "fast_open": false,
    "workers": 1
}
EOF

cd /root
wget "https://drive.google.com/uc?id=0B0D0hDHteoksVW5CemJKZVcyN1E" -O /usr/bin/rinetd
chmod +x /usr/bin/rinetd
echo "0.0.0.0 12420 0.0.0.0 12420" > /etc/rinetd.conf


cat > /etc/init.d/rinetd.sh<<-EOF
#!/bin/sh

### BEGIN INIT INFO
# Provides: rinetd
# Required-Start: $network
# Required-Stop:
# Should-Start:
# Should-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop rinetd
# Description: ovz vps bbr
### END INIT INFO

nohup /root/rinetd -f -c /root/rinetd.conf raw venet0:0 >/dev/null 2>&1 &
EOF

chmod +x /etc/init.d/rinetd.sh
cd /etc/init.d
update-rc.d rinetd.sh defaults 97


iptables -A INPUT -p tcp --dport 26514 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 12420 -j ACCEPT
iptables -A INPUT -p udp --dport 12420 -j ACCEPT
iptables -A INPUT -i lo -p tcp -m tcp --dport 12420 -m comment --comment LKL_RAW -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 12420 -m comment --comment LKL_RAW -j DROP
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables-save > /etc/iptables
touch /etc/network/if-pre-up.d/iptables
chmod +x /etc/network/if-pre-up.d/iptables

cat > /etc/network/if-pre-up.d/iptables<<-EOF
#!/bin/sh
/sbin/iptables-restore < /etc/iptables
EOF

iptables-save > /etc/iptables
