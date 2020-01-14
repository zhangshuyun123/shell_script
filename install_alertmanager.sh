#!/bin/bash

# 功能：安装alertmanager
# 时间：20200114
# version：V1.0

alertmanager_url=https://github.com/prometheus/alertmanager/releases/download/v0.20.0
alertmanager_version=alertmanager-0.20.0.linux-amd64.tar.gz

wget $alertmanager_url/$alertmanager_version

check_sum=`sha256sum $alertmanager_version|awk '{print $1}'`
echo $check_sum

if [[ `echo #?` -eq 0 ]] && [[ $check_sum = "3a826321ee90a5071abf7ba199ac86f77887b7a4daa8761400310b4191ab2819" ]];then
  echo "下载成功"
else
  echo "下载失败"
fi
