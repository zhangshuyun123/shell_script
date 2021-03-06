#!/bin/bash

# promethus + grafana 监控
# 20191223
# versio：1.0

DIR="/data/jiankong"

#if [ ! -d "$DIR" ];then
#  echo "目录不存在,开始创建 /data/jankong"
#  mkdir -p $DIR
#else
#  echo "目录存在"
#fi

echo "开始下载组件，请等待..."
wget -P $dir https://dl.grafana.com/oss/release/grafana-6.5.2-1.x86_64.rpm >> /dev/null
if [ `echo $?` -eq 0 ];then
  echo "grafana 下载完成"
  yum -y localinstall $DIR/grafana-6.5.2-1.x86_64.rpm
  if [ `echo $?` -eq 0 ];then
    systemctl daemon-reload
    systemctl enable grafana-server.service
    systemctl start grafana-server.service
  else
    echo "安装失败"
  fi
else
  echo "下载失败"
fi

wget -P $DIR https://github.com/prometheus/prometheus/releases/download/v2.14.0/prometheus-2.14.0.linux-amd64.tar.gz >> /dev/null
if [ `echo $?` -eq 0 ];then
  echo "promethus 下载完成"
  tar zxvf $DIR/prometheus-2.14.0.linux-amd64.tar.gz -C $DIR
  cd $DIR/prometheus-2.15.0-rc.0.linux-amd64
  pwd
  cp prometheus.yml prometheus.yml.bak
  cat >prometheus.yml << EOF
 my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.

 Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:

 Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:

 A scrape configuration containing exactly one endpoint to scrape:
 Here it's Prometheus itself.
scrape_configs:
  - job_name: 'linux'
    static_configs:
    - targets: ['101.201.69.197:9100']
      labels:
        instance: Prometheus

EOF
  
  ./prometheus&
else
  echo "下载失败"
fi

wget -P $DIR https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
if [ `echo $?` -eq 0 ];then
  echo "promethus 下载完成"
  tar zxvf $DIR/node_exporter-0.18.1.linux-amd64.tar.gz -C $DIR
  cd $DIR/node_exporter
  pwd
  ./node_exporter
else
  echo "下载失败"
fi
