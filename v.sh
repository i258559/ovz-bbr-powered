#!/bin/bash
apt-get update
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
#安装火狐
apt-get install -y firefox-esr
apt-get install -y flashplugin-nonfree
#重启vnc
tightvncserver :1
apt-get install -y cron
