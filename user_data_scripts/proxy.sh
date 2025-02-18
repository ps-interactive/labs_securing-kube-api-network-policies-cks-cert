#! /bin/bash

sudo sed -i "s|tstark pssecrocks|${proxy_user} ${proxy_pwd}|g" /etc/tinyproxy/tinyproxy.conf
sudo systemctl restart tinyproxy