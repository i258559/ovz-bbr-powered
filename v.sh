#!/bin/bash
apt-get update
apt-get upgrade -y
apt-get install -y tightvncserver
apt-get install -y xfce4
#开启服务
echo "启动vnc服务，请输入密码（ 不少于8位）"
tightvncserver :1
echo "启动成功，暂停配置中。。。"
#暂停vnc
tightvncserver -kill :1
#配置文件
rm -f /root/.vnc/xstartup
cat > /root/.vnc/xstartup<<-EOF
#!/bin/sh
xrdb $HOME/.Xresources 
xsetroot -solid grey 
x-terminal-emulator -geometry 80×24+10+10 -ls -title "$VNCDESKTOP Desktop" & 
#x-window-manager & 
xfce4-session & 
# Fix to make GNOME work 
#export XKL_XMODMAP_DISABLE=1 
#/etc/X11/Xsession
EOF
chmod +x /root/.vnc/xstartup
#设置开机启动
touch /etc/init.d/tightvncserver
cat > /etc/init.d/tightvncserver<<-EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides: tightvncserver
# Required-Start: $syslog $remote_fs $network
# Required-Stop: $syslog $remote_fs $network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Starts VNC Server on system start.
# Description: Starts tight VNC Server. Script written by James Swineson.
### END INIT INFO
# /etc/init.d/tightvncserver
VNCUSER='root'
case "$1" in
start)
su $VNCUSER -c '/usr/bin/tightvncserver -geometry 800x600 -depth 24 :1'
echo "Starting TightVNC Server for $VNCUSER"
;;
stop)
pkill Xtightvnc
echo "TightVNC Server stopped"
;;
*)
echo "Usage: /etc/init.d/tightvncserver {start|stop}"
exit 1
;;
esac
exit 0`</pre>
EOF
#修改权限
chmod 755 /etc/init.d/tightvncserver
update-rc.d tightvncserver defaults

#安装火狐
apt-get install -y firefox-esr
apt-get install -y flashplugin-nonfree
#重启vnc
vncserver :1
apt-get install -y cron

