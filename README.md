# ovz-bbr-powered
使用@linhua的黑科技rinetd为OVZ构架的VPS开启bbr 参考：https://www.v2ex.com/t/353778#r_4311799

Debian 8 64 步骤:

1.下载rintd二进制文件:
wget --no-check-certificate 
chmod +x rinetd
2.修改rinetd的配置文件rinetd.conf,添加监听地址 
vi rinetd.conf
# bindadress bindport connectaddress connectport 
0.0.0.0 443 0.0.0.0 443
0.0.0.0 80 0.0.0.0 80
3.设置开机启动
vi /etc/init.d/rinetd.sh

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

最后执行：
chmod +x /etc/init.d/rinetd.sh
cd /etc/init.d
update-rc.d rinetd.sh defaults 97
reboot

PS:记录在这里其实是为了方便自己下载rinetd文件




wget --no-check-certificate https://raw.githubusercontent.com/mishaelre/ovz-bbr-powered/master/install.sh && bash install.sh
