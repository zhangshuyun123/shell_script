#!/bin/bask

# 监控 zookeeper 服务
# 20191120
# version：1.1

<<!
  time             获取当前时间 
  backtime         备份当天文件日期
  container_name   容器名称
  log_path         文件路径
!

time=`date '+%Y-%m-%d %H:%M:%S'`
backtime=`date '+%Y%m%d'`
container_name="zookeeper"
log_path="/data/check/log/"

# 判断文件路径是否存在
if [ ! -d "$log_path" ];then
  mkdir -p $log_path
  echo "正在创建目录"
else
  echo "目录存在，正在执行"
fi

echo -e "$time" >> $log_path/check_port-$backtime\.log

# 检测三个IP的2181和3888端口状态
for ip in {10.100.23.234,10.100.23.235,10.100.23.23.76}
do
  for port in {2181,3888}
  do
    nc -vz -w 2 $ip $port 2> /dev/null
    if [ `echo $?` -eq 0 ];then
      echo -e "$ip $port 端口正常" >> $log_path/check_port-$backtime\.log
    else
      echo -e "$ip $port 端口异常" >> $log_path/check_port-$backtime\.log
    fi
  done

# 网络连通性
  echo $time >> /data/check/log/ping_$ip-$backtime\.log
  ping -c 4 $ip >> /data/check/log/ping_$ip-$backtime\.log
  echo -e "\n"  >> /data/check/log/ping_$ip-$backtime\.log
done

# 检测 10.100.23.234 的 2888 端口状态
nc -v -w 2 10.100.23.234 -z 2888 2>/dev/null
if [ `echo $?` -eq 0 ];then
  echo -e "10.100.23.234 2888 端口正常 \n" >> $log_path/check_port-$backtime\.log
else
  echo -e "10.100.23.234 2888 端口异常 \n" >> $log_path/check_port-$backtime\.log
fi

# 检测容器状态
result=`echo -e "\n" | docker stats --no-stream $container_name`
echo -e "$time" >> $log_path/$container_name\_stats-$backtime.\log
echo -e "$result \n" >> $log_path/$container_name\_stats-$backtime.\log

# 清理15天以前的日志

find /data/check/log -type f -name "*.log" -mtime +15 |xargs rm -f
