#!/bin/bash
#功能：安装/升级docker
#时间：20190527

echo "正在安装常用组件"
yum -y install py-pip python libffi openssl gcc libc make
function install_docker(){
                        #将旧版的docker卸载
                        yum  -y  remove docker docker-client \ 
                                        docker-client-latest \ 
                                        docker-common \ 
                                        docker-latest \
                                        docker-latest-logrotate \ 
                                        docker-logrotate \ 
                                        docker-engine
                        #
                        yum install -y yum-utils device-mapper-persistent-data lvm2
                        #添加yum的repo文件
			ls /etc/yum.repos.d/ |grep docker-ce.repo
			if (( `echo $?` != 0 ));then
				echo "正在下载docker-ce的yum源文件"
                        	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
			else
				echo "docker-ce 的yum源文件已准备好正在安装docker-ce"
			fi
                        #安装docker
                        yum install -y docker-ce docker-ce-cli containerd.io
			echo "Docker安装成功，现在开启Docker服务"
			systemctl start docker
			echo "将Docker加入开机自启动中"
			systemctl enable docker
                        }
#安装docker-compose
function install_docker-compose(){
	docker-compose version
	if (( `echo $? != 0` ));then
		echo "当前环境没有docker-compose正在安装请稍等"
		rm -rf /usr/local/bin/docker-compose
		rm -rf /usr/bin/docker-compose
                ##获取docker-compose
                echo "**************************正在获取docker-compose请稍等************************************"
                curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
		if (( `echo $?` != 0));then
                        echo "^^^^^^^^^^^^^^^^^^^^^增加执行权限^^^^^^^^^^^^^^^^^^^^^^^^^"
                        chmod +x /usr/local/bin/docker-compose
                        echo "-----------------------创建链接---------------------------------"
                        ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
                        echo "#%#%#%#%#%#%#%#%#%#%#% 当前docker-compose的版本为： #%#%#%#%#%#%#%#%#%#%#%"
                        docker-compose --version
		else
			echo "由于当前网络环境安装失败，正在改换安装方式"
			rm -rf /usr/local/bin/docker-compose
			rm -rf /usr/bin/docker-compose
			wget https://github.com/docker/compose/releases/download/1.25.0-rc1/docker-compose-Linux-x86_64 -o /usr/local/bin/
			mv /usr/local/bin/docker-compose-Linux-x86_64 docker-compose
			echo "^^^^^^^^^^^^^^^^^^^^^增加执行权限^^^^^^^^^^^^^^^^^^^^^^^^^"
			chmod +x /usr/local/bin/docker-compose
			echo "-----------------------创建链接---------------------------------"
			ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
			echo "#%#%#%#%#%#%#%#%#%#%#% 当前docker-compose的版本为： #%#%#%#%#%#%#%#%#%#%#%"
			docker-compose --version
		fi
	else
		echo "当前环境已安装docker-compose，它的版本为："
		docker-compose --version
	fi
                        }

case $1 in
	-d|-D)
		install_docker
;;
	-dc|DC)
		install_docker-compose
;;
	-a|-A)
		#docker和docker-compose
		install_docker
		install_docker-compose
;;
	*)
		echo -e "\e[1;32m帮助信息:\e[0m"
		echo -e "\e[1;35m\t\t执行 \e[1;32msh $0 -d或-D安装docker-compose \e[0m\e"
		echo -e "\e[1;35m\t\t执行 \e[1;32msh $0 -dc或-DC安装docker-compose \e[0m\e"
		echo -e "\e[1;35m\t\t执行 \e[1;32msh $0 -a或-A安装docker-compose和docker \e[0m\e"
;;
esac
