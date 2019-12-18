#!/bin/bash
# 解决异常实例杀不死的问题
# 20191115
# version: 1.0

# 判断日志文件是否存在
if [ ! -e /tmp/error_info ];then
  echo "创建 /tmp/error_info 文本文件"
  touch /tmp/error_info
else
  echo "/tmp/error_info 文件已存在，正在清理......"
  > /tmp/error_info
fi

# 过滤 docker 服务日志重定向到 /tmp/error_info 文件中
journalctl -u docker.service -n 200 -l|grep "container kill failed because of 'container not found' or 'no such process'" >/tmp/error_info

# 判断 /tmp/error_info 文件已经收集到错误信息（不为空）
if [ `echo $?` -eq 0 ] && [ -s /tmp/error_info ];then
  num=`cat /tmp/error_info |awk -F 'kill container ' '{print $2}'|awk -F ':' '{print $1}'|uniq -c|awk '{print $1}'`

# 判断错误信息达到三条以上
  if [ $number -ge 3 ];then
    id=`cat /tmp/error_info |awk -F 'kill container ' '{print $2}'|awk -F ':' '{print $1}'|uniq -c|awk '{print $2}'|cut -c1-6`
    container_name=`docker ps | grep $id` | awk -F '  ' '{print $NF}'

# container_name 非空
    if [ -n "$container_name" ];then
      for j in `ps -elf |grep $container_name |awk '{print $4}'`
      do
        echo -e "$j \n" >> /data/kill_container_process
        kill -9 $j
      done
    else
      echo "ID位 $id 的镜像已被清理，无需清理（this container_name not exist）"
    fi

  echo -e "杀掉的进程ID为：$id" >> /data/kill_container_id
  docker rm -f $id
  fi
else
  echo "没有要清理的镜像"
fi
