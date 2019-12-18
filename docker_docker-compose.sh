#!/bin/bash
#升级内核

#修改主机名
bash /root/changehostname.sh

#
echo "检测网络联通性"
ping www.baidu.com -c 4
if (( `echo $?` == 0 ));then
  echo "网络正常，开始安装常用组件"
  yum install wget vim screen net-tools lrzsz -y > /dev/null
  echo "常用组件安装完成，下载repo文件"
  wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
  echo "repo文件部署完毕，安装开发工具，升级yum安装包"
  yum groupinstall "Development Tools" -y > /dev/null
  yum update -y > /dev/null
  echo "获取内核"
  rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
  rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
  yum --disablerepo=\* --enablerepo=elrepo-kernel repolist
else
  exit
fi
 #查看可用的包
echo "创建内核列表文件"
touch list.txt | yum --disablerepo=\* --enablerepo=elrepo-kernel list kernel* >> ./list.txt
touch listall.txt | cat -n list.txt | tee listall.txt
rm -f list.txt
n=`cat listall.txt|awk -F '' '{print $1}'`
read -p "选择内核版本，请输入前面的数字：" number
echo $number
kernal_version=`cat listall.txt |sed -n "$number p"|awk '{print $2}'`
echo $kernal_version
echo "开始安装内核"
yum --disablerepo=\* --enablerepo=elrepo-kernel install -y $kernal_version 
touch boot_sequence.txt | awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg >> boot_sequence.txt
touch kernal_list.txt
n=`cat boot_sequence.txt | wc -l`
for (( i=0; i<$n; i++ ));
do
  echo $i >> kernal_list.txt
done
paste -d "" kernal_list.txt boot_sequence.txt > test.txt
cat test.txt
read -p "设置内核启动顺序:" boot_number
echo "在输入时注意如果是1的话就要输入0以此类推！！！"
grub2-set-default $boot_number
echo "内核升级成功，当前内核版本文为："
uname -r

read -p "是否需要重启(y/n)？？" re
if [ $re = 'y' ];then
  echo "系统将在5秒后重启"
  rm -f *.txt
  reboot
elif [ $re = 'n' ];then
  echo "您选择了否，请稍后手动将系统进行重启"
else
  echo "请正确输入y/n"
fi
