#!/bin/bash

# 功能：备份 crontab 文件，清理7天以前的的备份文件
# 时间：20191217
# version：v1.0


:<<!
  注释内容：
	DATE 日期
	BAKPATH 路径
!

DATE=`date +%Y%m%d`
BAKPATH="/tmp/crontab-bak/"
WAITIME=30

# 执行提示信息
if [[ $# -lt 1 ]] ;then
    echo "  用法： sh backcrontab.sh [路径]"
    echo -e "  默认路径: $BAKPATH \n"
  
    while [ $WAITIME -gt 0 ]
    do
      let WAITIME--
      sleep 1
      echo -ne "\e[1;31m 如需修改请在 $WAITIME 秒内 Ctrl + c 结束本次执行，按照上述规范重新执行该脚本 \e[0m"
      echo -ne "\r"
    done
    echo
fi


if [[ -n $1 ]]; then
  BAKPATH=$1
fi

# 判断目录是否存在
if [ ! -d "$BAKPATH" ];then
  echo "$BAKPATH 不存在，开始创建"
  mkdir -p $BAKPATH
  echo "目录创建完毕，开始执行"
else
  echo "开始执行"
fi

# 备份定时任务
crontab -l > $BAKPATH/crontab_$DATE\.bak

# 清理 7 天以前的备份文件
find $BAKPATH -mtime +7 -name "*.bak" | xargs rm -rf

echo "执行完毕"
