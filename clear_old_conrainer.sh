#!/bin/bash

:'

#  RECORD_FILE         镜像停止记录文件
#  RESULE_EXECUTION    最后一次执行该脚本的记录
#  TIME                获取当前时间
#  APP_ID              容器环境变量中的MARATHON_APP_ID的值
#  TASK_ID             容器环境变量中的MESOS_TASK_ID的值

'

RECORD_FILE=/data/record
RESULE_EXECUTION=/data/last_run_result
TIME=`date '+%Y-%m-%d.%H:%M:%S'`

# 清空文本文件
> $RECORD_FILE

# 写入当前时间到记录文件中
echo $TIME >> $RECORD_FILE

# 获取容器 ID，并通过 for 循环进行遍历
for i in `docker ps --format "table {{.ID}}"|awk 'NR>1'`
do
# 获取 MARATHON_APP_ID 和 MESOS_TASK_ID
  APP_ID=`docker exec $CID env|grep MARATHON_APP_ID|awk -F= '{print $2}'`
  TASK_ID=`docker exec $CID env|grep MESOS_TASK_ID|awk -F= '{print $2}'`

# 判断 MARATHON_APP_ID 和 MESOS_TASK_ID 是否为空，如果这两个值为空不进行任何操作
# -n 非空

  if [ -n "$APP_ID" ] && [ -n "$TASK_ID" ];then
    TASK="`curl -sS -u admin:*xxxxxx http://10.100.23.234:8080/v2/apps/$APP_ID/tasks|jq '.tasks[]|select(.id=="'$TASK_ID'")'`"

# -z 为空   
   if [ -z "$TASK" ]; then
      echo -e "task $i not exist" >> $RESULE_EXECUTION
      echo -e "停掉的旧实例有：`docker ps |grep $i >> $RECORD_FILE`"
      docker stop $Ci
    else
      echo task exist
    fi
  fi
done
