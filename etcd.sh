#!/bin/bash

# 功能： 安装etcd
# 时间： 20191224
# version: 2.0

IP=`ip a |grep eth0 |grep inet|awk '{print $2}'|awk -F '/' '{print $1}'`
read -p "集群节点个数num(奇数)：" num

if [ `expr $num % 2` -ne 0 ];then
  echo "奇数"
else
  echo "输入的数字不是奇数，请再次执行该文件输入正确的数字"
  exit
fi

wget https://github.com/etcd-io/etcd/releases/download/v3.3.18/etcd-v3.3.18-linux-amd64.tar.gz
tar -zxvf etcd-v3.3.18-linux-amd64.tar.gz
mv etcd-v3.3.18-linux-amd64 /etc/etcd-3.3.18
cd /etc/etcd-3.3.18
touch etcd.conf
cat >etcd.conf<<EOF
name: kubernetes_master
data-dir: /etc/etcd-3.3.18/data
listen-client-urls: http://0.0.0.0:2379
advertise-client-urls: http://$IP:2379
listen-peer-urls: http://0.0.0.0:2380
initial-advertise-peer-urls: http://$IP:2380
initial-cluster: kubernetes_master=http://$IP:2380
initial-cluster-token: etcd-cluster-my
initial-cluster-state: new
EOF
echo "export ETCDCTL_API=3" >> ~/.bashrc
echo "export PATH=/etc/etcd-3.3.18:$PATH" >> ~/.bashrc
source ~/.bashrc

touch /usr/lib/systemd/system/etcd.service

cat >/usr/lib/systemd/system/etcd.service <<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
WorkingDirectory=/etc/etcd-3.3.18
# User=etcd
ExecStart=/etc/etcd-3.3.18/etcd --config-file /etc/etcd-3.3.18/etcd.conf
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
systemctl restart etcd
