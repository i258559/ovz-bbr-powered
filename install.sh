#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================================#
#   System Required:  Debian8_x64                                   #
#   Description: One click Install lkl-bbr kcp               #
#   Adapt from: 91yun <https://twitter.com/91yun>                     #
#   Thanks: @linrong                            #
#=================================================================#

if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi


Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        release='CentOS'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        release='Debian'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        release='Ubuntu'
	else
        release='unknow'
    fi
    
}
Get_Dist_Name
function getversion(){
    if [[ -s /etc/redhat-release ]];then
        grep -oE  "[0-9.]+" /etc/redhat-release
    else    
        grep -oE  "[0-9.]+" /etc/issue
    fi    
}
ver=""
CentOSversion() {
    if [ "${release}" == "CentOS" ]; then
        local version="$(getversion)"
        local main_ver=${version%%.*}
		ver=$main_ver
    else
        ver="$(getversion)"
    fi
}
CentOSversion
Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        bit='x64'
    else
        bit='x32'
    fi
}
Get_OS_Bit

if [ "${release}" == "CentOS" ]; then
	yum install -y bc
else
	apt-get update
	apt-get install -y bc
fi

iddver=`ldd --version | grep ldd | awk '{print $NF}'`
dver=$(echo "$iddver < 2.14" | bc)
if [ $dver -eq 1 ]; then
	ldd --version
	echo "idd的版本低于2.14，系统不支持。请尝试Centos7，Debian8，Ubuntu16"
	exit 1
fi

if [ "$bit" -ne "x64" ]; then
	echo "脚本目前只支持64bit系统"
	exit 1
fi	



cd /root
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
wget --no-check-certificate https://raw.githubusercontent.com/mishaelre/ovz-bbr-powered/master/rinetd
chmod +x rinetd
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

nohup /root/rinetd -f -c /etc/rinetd.conf raw venet0:0 >/dev/null 2>&1 &
EOF

chmod +x /etc/init.d/rinetd.sh
cd /etc/init.d
update-rc.d rinetd.sh defaults 99


iptables -A INPUT -p tcp --dport 26514 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 12420 -j ACCEPT
iptables -A INPUT -p udp --dport 12420 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables-save > /etc/iptables

cat > /etc/network/if-pre-up.d/iptables<<-EOF
#!/bin/sh
/sbin/iptables-restore < /etc/iptables
EOF

chmod +x /etc/network/if-pre-up.d/iptables
