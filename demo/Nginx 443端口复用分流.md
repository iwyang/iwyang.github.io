---
title: Nginx 443端口复用分流
categories:
  - 技术
tags:
  - linux
  - nginx
abbrlink: a5658b36
date: 2022-05-29 05:55:31
---

>因为我们转发的是TCP流，因此nginx需要安装ngx_stream_core_module模块(以下简称stream模块)；我们还需要做一个SSL证书前置，需要ngx_stream_ssl_preread_module 模块。要查看这些模块是否被编译进了Nginx，可以使用Nginx -V命令进行查看。

>如果返回的结果中含有 --with-stream和--with-stream_ssl_preread_module，就说明这两个模块已经被编译进了Nginx；否则则需要自己重新编译Nginx。

## 第一种方法

1. 修改 Ngnix 默认配置

```bash
vi /etc/nginx/nginx.conf
```
2. 加入转发模块

在配置文件底部加上如下转发模块（他人的）：
```bash
# stream模块设置
stream {
    # SNI识别，将一个个域名映射成一个配置名
    map $ssl_preread_server_name $stream_map {
        website.example.com web;
        xtls.example.com beforextls;# 注意这里修改了
    }
 
    # upstream,也就是流量上游的配置
    upstream beforextls {
        server 127.0.0.1:7999;
    }
    upstream xtls {
        server 127.0.0.1:9000;
    }
    upstream web {
        server 127.0.0.1:443;
    }
    # stream模块监听服务器公网IP443端口，并进行端口复用
    server {
        listen [服务器公网IP]:443 reuseport;
        proxy_pass $stream_map;
        ssl_preread on;
        proxy_protocol on; # 开启Proxy protocol
    }
    server {
        listen 127.0.0.1:7999 proxy_protocol;# 开启Proxy protocol
        proxy_pass xtls; # 以真实的XTLS作为上游，这一层是与XTLS交互的“媒人”
    }
}
```
自定义：
```bash
stream {
    map $ssl_preread_server_name $stream_map {
        bore.vip web;
        www.bore.vip web1;
        p.bore.vip beforextls;
    }
 
    upstream beforextls {
        server 127.0.0.1:7999;
    }
    upstream xtls {
        server 127.0.0.1:9000;
    }
    upstream web {
        server 127.0.0.1:443;
    }
    upstream web1 {
        server 127.0.0.1:443;
    }
    server {
        listen 107.182.17.239:443 reuseport;
        proxy_pass $stream_map;
        ssl_preread on;
        proxy_protocol on; 
    }
    server {
        listen 127.0.0.1:7999 proxy_protocol;
        proxy_pass xtls; 
    }
}
```
3. 修改xr端口为`9000`

- 配置文件目录：

```
/etc/v2ray-agent/xray/conf
```

4. 修改web服务器配置：

```bash
vi /etc/nginx/conf.d/halo.conf
```
他人的：(

**PS：**`port_in_redirect off;` # **重定向去掉端口号，根据实际情况添加，如果二级目录链接无法从自定义端口（如1413）跳转到443，则开启此项**。

```bash
# Web服务器的配置
server {
    listen 80;# 我们只对443端口进行SNI分流，80端口依旧做Web服务；SNI分流也只能在443端口上跑TLS流量才能分流
    listen 127.0.0.1:443 ssl http2 proxy_protocol;# 监听本地443端口，要和上面的stream模块配置中的upstream配置对的上，开启Proxy protocol
    ......
    if ($ssl_protocol = "") {
        return 301 https://$host$request_uri;
    }
    index index.html index.htm index.php;
    try_files $uri $uri/ /index.php?$args;
 
    set_real_ip_from 127.0.0.1;# 从Proxy protocol获取真实IP
    real_ip_header proxy_protocol;
    port_in_redirect off; # 重定向去掉端口号
    ......
}
```
自定义：
```bash

upstream halo {
  server 127.0.0.1:8090;
}
server {
  listen 80;
  listen [::]:80;
  listen 127.0.0.1:443 ssl http2 proxy_protocol;
  listen [::]:443 ssl http2;
  set_real_ip_from 127.0.0.1;
  real_ip_header proxy_protocol;
  server_name bore.vip www.bore.vip;
  if ($host != 'bore.vip' ) {
      rewrite ^/(.*)$ https://bore.vip/$1 permanent;
  } 
  client_max_body_size 1024m;
  ssl_certificate /etc/letsencrypt/live/bore.vip/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/bore.vip/privkey.pem;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_session_timeout 10m;
  ssl_session_cache builtin:1000 shared:SSL:10m;
  ssl_buffer_size 1400;
  add_header Strict-Transport-Security max-age=15768000;
  ssl_stapling on;
  ssl_stapling_verify on;
  access_log /data/wwwlogs/bore.vip_nginx.log combined;
  index index.html index.htm index.php;
  root /data/wwwroot/bore.vip;
  if ($ssl_protocol = "") { return 301 https://$host$request_uri; }
  #error_page 404 /404.html;
  #error_page 502 /502.html;
  location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ {
    proxy_pass http://halo;
    expires 30d;
    access_log off;
  }
  location ~ .*\.(js|css)?$ {
    proxy_pass http://halo;
    expires 7d;
    access_log off;
  }
  location ~ /(\.user\.ini|\.ht|\.git|\.svn|\.project|LICENSE|README\.md) {
    deny all;
  }
  location / {
    proxy_set_header HOST $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass http://halo;
  }
  location ^~ /.well-known/acme-challenge/ {
    default_type "text/plain";
    allow all;
    root /data/wwwroot/bore.vip/;
  } 
}
```
5. 重启xr、nginx

   先重启xr，重启略，再重启nginx
```bash
systemctl restart nginx
```
**省略**

## 第二种方法（未测试）

### 配置Nginx SNI

由于默认安装的`Nginx`不会构建`http_realip`及`stream_ssl_preread`模块，需手动添加`--with-http_realip_module --with-stream_ssl_preread_module`两个参数再编译安装`Nginx`，使用`nginx -V`命令可查看已安装的模块。

在主配置文件`nginx.conf`的`events`和`http`之间插入`stream_ssl_preread`模块，插入后的配置文件如下：

```bash
user  www;

events {
    use epoll;
    worker_connections 51200;
    multi_accept on;
}

stream {
    map $ssl_preread_server_name $name {
        x.example.com xray;
        example.com blog;
    }
    upstream xray {
        server 127.0.0.1:6004; # xray xtls伪装站点
    }
    upstream xtls {
        server 127.0.0.1:6443; # Xray端口
    }
    upstream blog {
        server 127.0.0.1:6003; # 业务站点
    }

    server {
        listen 443 reuseport;
        listen [::]:443 reuseport;
        proxy_pass $name;
        ssl_preread on;
        proxy_protocol on;
    }
    server {
        # Xray XTLS
        listen 127.0.0.1:6004 proxy_protocol;
        proxy_pass xtls;
    }
}

http {
  ...
}
```

伪装站点及业务站点的配置:

```bash
http {
    set_real_ip_from 127.0.0.1; # 获取真实客户IP，不然全是127.0.0.1
    real_ip_header proxy_protocol;
    port_in_redirect off; # 重定向去掉端口号

    fastcgi_connect_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_read_timeout 300;
    fastcgi_buffer_size 64k;
    fastcgi_buffers 4 64k;
    fastcgi_busy_buffers_size 128k;
    fastcgi_temp_file_write_size 256k;

    server {
        listen 80;
        server_name x.example.com;
        return 301 https://x.example.com$request_uri;
    }

    server {
        # 伪装站点由Xray处理SSL
        listen 127.0.0.1:6001 proxy_protocol; # xray http/1.1
        listen 127.0.0.1:6002 proxy_protocol http2; # xray http/2

        server_name x.example.com;
        index index.html index.htm index.php;
        root /home/wwwroot/default;
    }

    server {
        listen 80;
        server_name example.com;
        return 301 https://example.com$request_uri;
    }

    server {
        listen 127.0.0.1:6003 proxy_protocol ssl http2;

        server_name example.com;
        root /home/wwwroot/example.com;
        index index.html index.htm index.php;

        ssl_certificate /etc/ssl/nginx/example.com.pem;
        ssl_certificate_key /etc/ssl/nginx/example.com.key;

        include enable-php-pathinfo.conf;

        location ~ \.php$ {
            # fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
            fastcgi_pass 127.0.0.1:9000;
            # fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}
```

### 配置Xray

服务端配置：

```bash
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 6443,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "UUID",
            "flow": "xtls-rprx-direct"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 6001,
            "xver": 1
          },
          {
             "alpn": "h2",
             "dest": 6002,
             "xver": 1
          },
          {
            "path": "/vmessws",
            "dest": 6000,
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
          "alpn": [
            "h2",
            "http/1.1"
          ],
          "certificates": [
            {
              "certificateFile": "/usr/local/ssl/xray/example.com.pem",
              "keyFile": "/usr/local/ssl/xray/example.com.key"
            }
          ]
        }
      }
    },
    {
      "port": 6000,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "UUID"
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/vmessws"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
```

最后开启服务端防火墙的443和80端口，如果有另外的软件限制服务器内部端口之间的访问，也要打开相应的端口。

Linux客户端使用VLESS+TCP+XTLS配置：

```bash
{
  "inbounds": [
    {
      "port": 1080,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "settings": {
        "udp": true
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "x.example.com",
            "port": 443,
            "users": [
              {
                "id": "UUID",
                "security": "none"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "serverName": "x.example.com"
        },
        "wsSettings": {
          "path": "/vmessws"
        }
      }
    }
  ]
}
```



## 参考链接

+ [使用Nginx进行SNI分流并完美和网站共存](https://blog.xmgspace.me/archives/nginx-sni-dispatcher.html)
+ [Nginx SNI分流（端口复用）使用Xray+VLESS+XTLS](https://qoanty.github.io/2021/05/xray-nginx-sni/)