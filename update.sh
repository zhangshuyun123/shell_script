#!/bin/bash
#
#功能：升级MySQL和Nginx
#
#时间：20190529

function update_mysql(){
	echo "当前运行的mysql容器是："
	docker ps|grep mysql
	echo "当前环境的mysql容器有："
	docker images|grep mysql
	read -p "请输入要升级到的镜像及版本号（例：mysql:5.7.26：" mysql_version
	docker pull $mysql_version
	echo "最新镜像以pull完成"
	read -p "请输入修改后的tag($mysql_version ---------> ):" image_tag
	echo $image_tag
	docker tag $mysql_version $image_tag
	echo "                          手动启动docker镜像                          "
	docker run -itd \
		-v /data:/data \
		-v /tmp:/tmp \
		-v /home/mysql.cnf:/home/mysql.cnf \
		-e MYSQL_ROOT_PASSWORD=Ufsoft*123 \
		$image_version
	docker ps|grep mysql
	ID=`docker ps|grep $image_tag |awk -F ' ' '{print$1}'`
	echo $ID
	sleep 23
	docker cp /tmp/SQLfile.sql $ID:/
	docker exec -it $ID mysql -uroot -pUfsoft*123 -e "source /SQLfile.sql;"
	
	if (( `echo $? == 0` ));then
		echo "数据恢复成功"
	else
		echo "数据恢复失败"
		exit
	fi
	
	docker images|grep mysql
	sed -n '/mysql:/,/1/p' docker-compose.yml > /tmp/docker-compose.yaml
	echo $image_tag
	sed -i "/image: /c\ \ \ \ image: $image_tag" /tmp/docker-compose.yaml
	docker stop $ID
	cd /tmp
	pwd
	docker-compose up -d mysql
	
}
update_mysql