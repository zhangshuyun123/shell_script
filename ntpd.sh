#!/bin/bash

# 功能：服务器同步时间
# 时间：20200114
# 版本：V1.0

if [[ `rpm -qa|grep -e "ntp-"` ]] && [[ `rpm -qa|grep -e "ntpdate"` ]];then
  echo "ntp 服务正常"
else
  echo "ntp 服务异常"
fi

# 备份ntp服务的配置文件
cp /etc/ntp.conf   /etc/ntp.conf.bak

# 替换时间服务器地址
for i in {0..3}
do
  sed -i "s/server $i.centos.pool.ntp.org iburst/server ntp$i.aliyun.com/g" /etc/ntp.conf
  echo $?
done

if [ `echo $?` -eq 0 ];then
  echo "替换完成，开始修改时区"
  rm -rf /etc/localtime
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  systemctl restart ntpd
  systemctl enable ntpd
  systemctl status ntpd
else
  echo "替换失败"
fi
