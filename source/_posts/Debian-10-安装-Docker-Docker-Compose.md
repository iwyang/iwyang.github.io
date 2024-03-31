---
title: Debian 10 安装 Docker & Docker Compose
categories:
  - 技术
tags:
  - docker
comments: true
cover: /img/cover/docker.jpg
abbrlink: 9755dbc8
date: 2022-08-22 17:56:32
sticky:
keywords:
description:
top_img:
---

{% note warning flat %}
Debian10 上安装部分应用，速度几乎为0，至少需要Debian11以上，512M内存足够。
{% endnote %}

## 安装 Docker

1.首先，更新现有的软件包列表：

```bash
sudo apt update -y
```

2.接下来，安装一些必备软件包，让 apt 通过 HTTPS 使用软件包。

```bash
sudo apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
```

3.然后将官方 Docker hub 的 GPG key 添加到系统中。

```bash
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
```

4.将 Docker 版本库添加到APT源：

```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
```

5.接下来，我们用新添加的 Docker 软件包来进行升级更新。

```yaml
sudo apt update -y
```

6.安装 Docker 

```bash
sudo apt install docker-ce -y
```

7.检查 Docker 是否正在运行

```
docker --version
sudo systemctl status docker
```



8.重启 docker 并设置开机自启

```
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

9.修改Docker配置（来自[烧饼博客](https://u.sb/debian-install-docker/)）

以下配置会增加一段自定义内网 IPv6 地址，开启容器的 IPv6 功能，以及限制日志文件大小，防止 Docker 日志塞满硬盘（泪的教训）

```bash
cat > /etc/docker/daemon.json <<EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "20m",
        "max-file": "3"
    },
    "ipv6": true,
    "fixed-cidr-v6": "fd00:dead:beef:c0::/80",
    "experimental":true,
    "ip6tables":true
}
EOF
```

然后重启 Docker 服务：

```bash
systemctl restart docker
```

## 在 Docker 中使用镜像

1.要查看已下载到计算机的镜像：

```bash
docker images
```

2.删除某个docker镜像

```bash
docker rmi <your-image-id>
```

3.一次删除多张镜像

```bash
docker rmi <your-image-id> <your-image-id> ...
```

4.一次删除所有镜像

```bash
docker rmi $(docker images -q)
```

## 在 Docker 中使用容器

1.要查看**所有**的容器对象，请使用：

```bash
docker ps -a
```

> docker ps -a -q 分解
>
> - `docker ps` 列出**活动**中容器。
> - `-a` 这个选项用于列出**所有**容器，包括停止运行的。如果没有这个选项，则默认只列出在运行的容器。
> - `-q` 这个选项列出容器的数字 ID，而不是容器的所有信息。



2.要启动已停止的容器，请使用`docker start命令+容器ID或容器名`

>- 停止所有容器运行：`docker stop $(docker ps -a -q)`



3.通过`docker rm`命令来删除不用的容器。



>+ 先使用`docker ps -a`命令查找相关镜像关联的容器的**容器ID或名称**，然后通过`docker rm`命令来删除其删除。
>+ 删除所有停止运行的容器：`docker rm $(docker ps -a -q)`

### **Docker 容器开机自启**

1.在使用docker run启动容器时，使用--restart参数来设置：

```bash
docker run -m 512m --memory-swap 1G -it -p 58080:8080 --restart=always  
```

2.如果创建时未指定 --restart=always ,可通过update 命令设置

```bash
docker update --restart=always 容器ID或名称
```

## 安装 Docker Compose

1.安装

```bash
export LATEST_VERSION=$(wget -qO- -t1 -T2 "https://api.github.com/repos/docker/compose/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
sudo curl -L https://github.com/docker/compose/releases/download/$LATEST_VERSION/docker-compose-linux-`uname -m` > ./docker-compose
sudo chmod +x ./docker-compose
sudo mv ./docker-compose /usr/local/bin/docker-compose
```

2.查看版本

```
docker-compose --version
```

3.使用 -d 选项以分离模式启动 Compose(后台)

```
docker-compose up -d
```

4.要查看正在运行的 docker 容器，请使用以下命令

```
docker-compose ps
```

5.删除容器

```
cd /root/data/docker_data/joplin  # 进入docker-compose所在的文件夹

docker-compose down    # 停止容器，此时不会删除映射到本地的数据

rm -rf /root/data/docker_data/joplin  # 完全删除映射到本地的数据
```

6.一些 Docker Compose 常用命令：

```
docker-compose restart  # 重启容器
docker-compose stop     # 暂停容器
docker-compose down     # 删除容器
docker-compose pull     # 更新镜像
docker-compose exec artalk bash # 进入容器
```

7.Docker Compose升级

删除现有容器，拉取最新镜像，然后重新创建容器即可。

```
docker-compose down
docker-compose pull
docker-compose up -d
```

### **开机自动启动应用容器**

1.方法一、通过 Docker Restart Policy 方法

在 Docker 中，支持 --restart 选项，来控制容器自动启动。在 Docker Compose 中，应该使用 restart 属性

```diff
version: '2'
services:
  database:
    build: ./mysql/
    command: mysqld --user=root --verbose
+   restart: always 
    environment:
      MYSQL_DATABASE: "web_level3_sqli"
      MYSQL_USER: "web_level3_sqli"
      MYSQL_PASSWORD: "thisisasecurepassword123"
      MYSQL_ROOT_PASSWORD: "root"
      MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
  web:
    build: ./www/
+    restart: always
    ports:
     - "12000:80"
    volumes:
      - ./www/src:/var/www/html
    links:
      - database
```

注意事项：
1）Docker 并不知道这些服务的依赖关系及启动顺序，需要我们精心编排 docker-compose.yaml 文件；
2）Docker Compose 不支持 deploy:restart_policy 属性，该属性只能用于 a swarm with docker stack deploy 环境；



2.方法二、通过进程管理服务（推荐）

该方法本质上还是在执行 docker-compose 命令。

使用 systemd 管理
如下示例，可以根据需要进行设置：

```bash
# cat /etc/systemd/system/docker-compose-app.service

[Unit]
Description=Docker Compose Application Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/srv/docker/app/
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

7.卸载 Docker Compose

```
sudo rm /usr/local/bin/docker-compose
```

## 常见问题

1.出错提示：error storing credentials - err: exit status 1, out: `Cannot autolaunch D-Bus without X11 $DISPLAY`

解决方法：

```bash
sudo apt install gnupg2 pass -y
```

## 参考链接

+ [如何在 debian 10 中安装和使用 Docker](https://www.sunqi.org/debian-10-install-docker.html)
+ [Debian 11 安装 Docker & Docker Compose](https://6xyun.cn/article/137)
+ [实用教程Debian 10系统中安装Docker Compose过程](https://www.itbulu.com/docker-compose.html)
+ [Docker 容器开机自启](https://www.jianshu.com/p/36f63f57b05d)
+ [docker-compose 关机或者重启docker同时重启容器restart always的配置](https://blog.csdn.net/fjh1997/article/details/98880638)
+ [如何删除 Docker 镜像和容器](https://chinese.freecodecamp.org/news/how-to-remove-images-in-docker/)





