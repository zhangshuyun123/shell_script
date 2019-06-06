#!/bin/bash

#etcd1=172.20.56.159
read -p "请输入节点IP地址：" etcd1
function certificate(){
#创建日志目录
mkdir -p /var/log/etcd
#创建etcd数据目录
mkdir -p /data/etcd
#创建工具目录
mkdir /data/tools

#下载生成证书工具
wget -P /data/tools https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget -P /data/tools https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
wget -P /data/tools https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 
chmod +x /data/tools/cfssl_linux-amd64 /data/tools/cfssljson_linux-amd64 /data/tools/cfssl-certinfo_linux-amd64
cp /data/tools/cfssl_linux-amd64 /usr/local/bin/cfssl
cp /data/tools/cfssljson_linux-amd64 /usr/local/bin/cfssljson
cp /data/tools/cfssl-certinfo_linux-amd64 /usr/bin/cfssl-certinfo

#创建证书目录
mkdir /data/pkg
#配置证书信息1
cat>/data/pkg/ca-config.json<<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "www": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}
EOF
#配置证书信息2
cat>/data/pkg/ca-csr.json<<EOF
{
    "CN": "etcd CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing"
        }
    ]
}
EOF
#配置证书信息3
cat>/data/pkg/server-csr.json<<EOF
{
    "CN": "etcd",
    "hosts": [
    "$etcd1",
#    "$etcd2",
#    "$etcd3"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "BeiJing",
            "ST": "BeiJing"
        }
    ]
}
EOF

echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
#生成证书
cfssl gencert -initca /data/pkg/ca-csr.json | cfssljson -bare ca -
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=/data/pkg/ca-config.json -profile=www /data/pkg/server-csr.json | cfssljson -bare server
echo "()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()"
ls *.pem
mv *.pem /data/pkg
mv *.csr /data/pkg
echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
}
#下载etcd安装包
function install_etcd(){
	a=`find / -name "etcd-v3.3.13-linux-amd64.tar.gz"|wc -l`
	if (( $a != 0 ));then
		mkdir /data/etcd/{bin,cfg,ssl} -p
                tar zxvf etcd-v3.3.13-linux-amd64.tar.gz -C /data/
                mv /data/etcd-v3.3.13-linux-amd64/{etcd,etcdctl} /data/etcd/bin/
	else
		wget  https://github.com/etcd-io/etcd/releases/download/v3.3.13/etcd-v3.3.13-linux-amd64.tar.gz
		if (( `echo $? == 0` ));then
			mkdir /data/etcd/{bin,cfg,ssl} -p
			tar zxvf etcd-v3.3.13-linux-amd64.tar.gz -C /data/
			mv /data/etcd-v3.3.13-linux-amd64/{etcd,etcdctl} /data/etcd/bin/
		else
			echo "etcd包下载出错，请检查网络连通性"
		fi
	fi
#创建etcd配置文件
	cat>/data/etcd/cfg/etcd<<EOF
#[Member]
ETCD_NAME="etcd1"
TCD_DATA_DIR="/var/lib/etcd/default.etcd"
TCD_LISTEN_PEER_URLS="https://$etcd1:2380"
TCD_LISTEN_CLIENT_URLS="https://$etcd1:2379"

[Clustering]
TCD_INITIAL_ADVERTISE_PEER_URLS="https://$etcd1:2380"
TCD_ADVERTISE_CLIENT_URLS="https://$etcd1:2379"
#ETCD_INITIAL_CLUSTER="etcd1=https://$etcd1:2380,etcd2=https://$etcd2:2380,etcd3=https://$etcd3:2380"
ETCD_INITIAL_CLUSTER="https://$etcd1:2380
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"

EOF
#system 管理Etcd
	cat>/usr/lib/systemd/system/etcd.service<<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=/data/etcd/cfg/etcd
ExecStart=/data/etcd/bin/etcd \
--name=etcd1 \
--data-dir=/data/etcd \
--listen-peer-urls=http://127.0.0.1:2379 \
--listen-client-urls=${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \
--advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \
--initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
--initial-cluster=${ETCD_INITIAL_CLUSTER} \
--initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \
--initial-cluster-state=new \
--cert-file=/data/etcd/ssl/server.pem \
--key-file=/data/etcd/ssl/server-key.pem \
--peer-cert-file=/data/etcd/ssl/server.pem \
--peer-key-file=/data/etcd/ssl/server-key.pem \
--trusted-ca-file=/data/etcd/ssl/ca.pem \
--peer-trusted-ca-file=/data/etcd/ssl/ca.pem
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
	cp /data/pkg/*.pem /data/etcd/ssl/
	ln -s /data/etcd/bin/etcd /usr/bin/
	ln -s /data/etcd/bin/etcdctl /usr/bin	
	systemctl daemon-reload
	systemctl start etcd
	systemctl enable etcd

}
certificate
install_etcd
