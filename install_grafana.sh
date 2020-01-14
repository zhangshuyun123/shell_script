#!/bin/bash

# 功能：安装grafana
# 时间：20200111
# 版本： V1.0


grafana_url=https://dl.grafana.com/oss/release
grafana_version=grafana-6.5.2-1.x86_64.rpm

wget $package_url/$package_name
if [ `echo $?` -eq 0 ];then
  echo "下载成功"
  yum -y localinstall $package_name
else
  echo "下载失败"
fi

systemctl start grafana-server
systemctl enable grafana-server
