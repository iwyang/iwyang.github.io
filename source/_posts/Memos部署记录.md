---
title: Memos部署记录
categories:
  - 技术
tags:
  - hexo
comments: true
cover: /img/cover/memos.jpg
abbrlink: d5e37958
date: 2022-09-18 19:44:19
sticky:
keywords:
description:
top_img:
---

> Memos是什么：一个开源的、支持私有化部署的碎片化知识卡片管理工具。可以说是支持 Docker 自部署的 flomo
>
> 官网：https://usememos.com/
>
> 仓库地址：https://github.com/usememos/memos
>
> 成品：https://me.bore.vip/u/101

## Docker部署

```
docker run -d --name memos -p 5230:5230 -v ~/.memos/:/var/opt/memos neosmemo/memos:latest
```

## Docker Compose部署

1.创建 Memos 工作目录

```
mkdir memos && cd memos
vi docker-compose.yaml
```

2.编写 `docker-compose.yaml` 文件：

```yaml
version: "3.0"
services:
  memos:
    image: neosmemo/memos:latest
    restart: always 
    container_name: memos
    volumes:
      - ~/.memos/:/var/opt/memos
    ports:
      - 5230:5230
```

更多参考：[`docker-compose.yaml`](https://github.com/usememos/memos/blob/main/docker-compose.yaml)

3.执行命令，`Memos` 后端程序将运行在 `http://localhost:端口号`

```
docker-compose up -d
```

通过访问 `localhost:5230` 即可打开 Memos，首次安装会提示注册用户，请记牢您的而密码。数据文件默认存储在 **`~/.memos`** 中。

4.**更新**。删除现有容器，拉取最新镜像，然后重新创建容器即可。

**Docker Compose**

```
docker-compose down
docker-compose pull
docker-compose up -d
```

**Docker**

待补充

5.一些 Docker Compose 常用命令：

```
docker-compose restart  # 重启容器
docker-compose stop     # 暂停容器
docker-compose down     # 删除容器
docker-compose pull     # 更新镜像
docker-compose exec artalk bash # 进入容器
```

## 配置域名访问

```
vi /etc/nginx/conf.d/memos.conf
```

```bash
server
{
  listen 80;
  server_name me.bore.vip;
  
  # proxy to 5230
  location / {
    proxy_pass http://127.0.0.1:5230;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header REMOTE-HOST $remote_addr;
    add_header X-Cache $upstream_cache_status;
    # cache
    add_header Cache-Control no-cache;
    expires 12h;
  }
  location ^~ /.well-known/acme-challenge/ {
    default_type "text/plain";
    allow all;
    root /data/wwwroot/me.bore.vip/;
  }  
}
```

重启Nginx：`systemctl restart nginx`

## 申请SSL证书

参考：[Nginx 配置 ssl 证书](/archives/58fed3fc/#Debian10上的操作)

1.新建文件夹：

```
mkdir -p /data/wwwroot/me.bore.vip
```

2.申请证书

```
sudo apt-get install letsencrypt -y
certbot certonly --webroot -w /data/wwwroot/me.bore.vip -d me.bore.vip -m 455343442@qq.com --agree-tos
```

3.编辑 Nginx

**（1）未启用端口复用：**

```
server
{
  listen 80;
  listen 443 ssl http2;
  server_name me.bore.vip;
  root /data/wwwroot/me.bore.vip;

  # SSL setting
  ssl_certificate /etc/letsencrypt/live/me.bore.vip/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/me.bore.vip/privkey.pem;
  ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;
  add_header Strict-Transport-Security "max-age=31536000";

  # proxy to 5230
  location / {
    proxy_pass http://127.0.0.1:5230;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header REMOTE-HOST $remote_addr;
    add_header X-Cache $upstream_cache_status;
    # cache
    add_header Cache-Control no-cache;
    expires 12h;
  }

  location ^~ /.well-known/acme-challenge/ {
    default_type "text/plain";
    allow all;
    root /data/wwwroot/me.bore.vip/;
  }  
}
```

**（2）启用端口复用：**

```bash
server
{
  listen 80;
  listen 127.0.0.1:1314 ssl http2 proxy_protocol;
  set_real_ip_from 127.0.0.1;
  real_ip_header proxy_protocol; 
  port_in_redirect off;  
  server_name me.bore.vip;
  root /data/wwwroot/me.bore.vip;
  if ($host != 'me.bore.vip' ) {
      rewrite ^/(.*)$ https://me.bore.vip/$1 permanent;
  }  

  # SSL setting
  ssl_certificate /etc/letsencrypt/live/me.bore.vip/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/me.bore.vip/privkey.pem;
  ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;
  add_header Strict-Transport-Security "max-age=31536000";

  # proxy to 5230
  location / {
    proxy_pass http://127.0.0.1:5230;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header REMOTE-HOST $remote_addr;
    add_header X-Cache $upstream_cache_status;
    # cache
    add_header Cache-Control no-cache;
    expires 12h;
  }

  location ^~ /.well-known/acme-challenge/ {
    default_type "text/plain";
    allow all;
    root /data/wwwroot/me.bore.vip/;
  }  
}
```

4.重启Nginx、xr

## 安卓快捷方式发送Memos

参考：[安卓手机上快捷方式发送](/archives/6c31209c/#安卓手机上快捷方式发送)

注意：

1.变量只添加一个`content`即可

2.`响应体/响应参数`，选择`自定义类型`，Content-Type 填写 `application/json`，请求体填写：(最好不要直接点复制按钮复制代码，直接拖动选择所有行代码，这样张贴就会保留空格)

```json
{
    "content": "{content}"
}
```

{% note warning flat %}
注意：上面的`{content}`  需要先删除，然后点击旁边的 `{}` 插入变量（插入的变量颜色是蓝色）。不能直接填写！！！
{% endnote %}

## 定时备份数据库

参考：[halo 定时备份的方法](/archives/3a4bd17/)

## 参考链接

[Hi，Memos](https://immmmm.com/hi-memos/)

[搭建属于你自己的 flomo 应用 :Memos](https://1900.live/build_your_own_flomo_applications/)
