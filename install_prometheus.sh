#!/bin/bash

# 功能：自动化安装prometheus
# 时间：20200110
# version：1.0

prometheus_url="https://github.com/prometheus/prometheus/releases/download/v2.15.2/"
prometheus_version="prometheus-2.15.2.linux-amd64.tar.gz"
installdir="/data"

wget $prometheus_url$prometheus_version > /dev/null
check_sum=`sha256sum $prometheus_version|awk '[print $1]'`

if [[ `echo $?` -eq 0 ]] && [[ "$check_sum" = "3a826321ee90a5071abf7ba199ac86f77887b7a4daa8761400310b4191ab2819" ]];then
  echo "源码包下载成功"
else
  echo "源码包下载失败"
fi

if [ -d $installdir ];then
  tar -zxf $package -C $installdir
  if [ `echo $?` -eq 0 ];then
    echo "解压成功"
    mv prometheus-2.15.2.linux-amd64 prometheus
    echo "重命名成功"
    rm -rf prometheus-2.15.2.linux-amd64
    rm -rf prometheus-2.15.2.linux-amd64.tar.gz
  else
    echo "解压失败"
    exit
  fi
else
  mkdir $installdir
  tar -zxvf $package -C $installdir
  mv prometheus-2.15.2.linux-amd64 prometheus
  echo "重命名成功"
  # rm -rf prometheus-2.15.2.linux-amd64 prometheus-2.15.2.linux-amd64.tar.gz
fi

cat > /usr/lib/systemd/system/prometheus.service <<EOF
[Unit]
Description=https://prometheus.io

[Service]
Restart=on-failure
ExecStart=/data/prometheus/prometheus --config.file=/data/prometheus/prometheus.yml

[Install]
WantedBy=multi-user.target

EOF

# 备份prometheus的配置文件
cp /data/prometheus/prometheus.yml /data/prometheus/prometheus.yml.bak

systemctl daemon-reload
systemctl start prometheus
systemctl status prometheus


bash install_grafana.sh
