#!/bin/bash
#
# 安装 Redis 脚本

if [[ $# -lt 1 ]] || [[ $# -lt 2 ]] || [[ $# -lt 3 ]] || [[ $# -lt 4 ]];then
    echo "用法： sh redis-install.sh [版本] [安装路径] [端口] [密码]"
    echo -e "默认:\n 版本：5.0.4 安装路径：/opt/redis 端口：6379 密码：123456\n"
    echo "如需修改请在30秒内 Ctrl + c 结束本次执行，按照上述规范重新执行该脚本"
fi

sleep 30

version=5.0.4
root=/opt/redis
port=6379
password=123456

if [[ -n $1 ]]; then
  version=$1
fi

if [[ -n $2 ]]; then
  root=$2
fi

if [[ -n $3 ]]; then
  port=$3
fi

if [[ -n $4 ]]; then
  password=$4
fi

printf "开始安装>>>> \n"

echo -e "\t 安装信息: redis版本 ${version} 路径 ${root}, 端口 ${port}, 密码 ${password} \n"
yum install -y zlib zlib-devel gcc-c++ libtool openssl openssl-devel tcl

mkdir -p $root
curl -o $root/redis-$version.tar.gz http://download.redis.io/releases/redis-$version.tar.gz

path=$root/redis-$version
tar zxf $root/redis-$version.tar.gz -C $root
cd $path
make && make install
mv $path/* $root/
echo "修改redis配置文件"
cp $root/redis.conf $root/redis.conf.bak
mkdir -p /etc/redis
cp $root/redis.conf /etc/redis/$port.conf
sed -i "s/^port 6379/port $port/g" /etc/redis/$port.conf
if [[ -n $password ]]; then
  sed -i "s/^# requirepass/requirepass $password/g" /etc/redis/$port.conf
fi

cat >/lib/systemd/system/redis.service <<EOF
[Unit]
Description=Redis
After=network.target
 
[Service]
ExecStart=$root/src/redis-server /etc/redis/$port.conf  --daemonize no
ExecStop=$root/src/redis-cli -h 127.0.0.1 -p 6379 shutdown
 
[Install]
WantedBy=multi-user.target

EOF

echo "安装完成,开始启动服务"
systemctl daemon-reload
systemctl start redis
systemctl status redis
systemctl enable redis
