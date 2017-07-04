#!/bin/bash
apt-get update
apt-get install -y vnc4server
apt-get install -y xfce4
#开启服务
echo "启动vnc服务，请输入密码（ 不少于8位）"
vncserver :1
echo "启动成功，暂停配置中。。。"
#暂停vnc
vncserver -kill :1
#配置文件
rm -f /root/.vnc/xstartup
cat > /root/.vnc/xstartup<<EOF
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
update-rc.d vncserver defaults
#安装火狐
apt-get -y install firefox-esr
#重启vnc
vncserver :1
apt-get install -y cron

cat > /etc/init.d/vncserver<<EOF
#! /bin/sh
export USER="root"
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/bin/X11"
NAME=vncstart
start()
{
su - $USER -c"vncserver :1"
}
stop()
{
su - $USER -c"vncserver -clean -kill :1"
}
case "$1" in
start)
echo -n "Starting Xvnc: "
start
;;
stop)
echo -n "Stopping Xvnc "
stop
;;
restart)
echo -n "Restarting Xvnc "
stop
start
;;
****)
echo "Usage: /etc/init.d/$NAME {start|stop|restart}"
;;
esac
exit 0
EOF
chmod 755 /etc/init.d/vncserver ; update-rc.d vncserver defaults ; service vncserver start
