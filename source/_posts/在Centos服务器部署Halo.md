---
title: 在Centos服务器部署Halo
categories:
  - 技术
tags:
  - 服务器
  - halo
abbrlink: 119bcfe3
date: 2020-07-24 02:21:25
cover: false
---



  本教程以 `CentOS 7.x` 为例，配置并运行 `Halo`，其他 Linux 发行版大同小异。

## 写在前面

1. 具备一定的 Linux 基础。
2. 如需域名绑定，请先保证已经正确解析 IP，以及确认服务器是否需要备案。
3. 如需使用 IP 访问，请先确保 Halo 的运行端口已经打开，除非你使用 80 端口运行 Halo。
4. 如 3 所述，如果你使用了类似 `宝塔面板` 之类的 Linux 管理面板，可能还需要在面板里设置端口。
5. 不要想当然，请严格按照文档的流程操作。

## Win10配置java环境变量

### 下载&& 安装JDK

下载地址：https://www.oracle.com/java/technologies/downloads/

2022.5.26 java18 本地不可用，java17 本地可用。（halo版本：1.5.3）

### 环境变量配置

1. 打开 环境变量窗口，右键 **This PC(此电脑) -> Properties（属性） -> Advanced system settings（高级系统设置） -> Environment Variables（环境变量）...**

2. 新建JAVA_HOME 变量，点击 New（新建）... 按钮，输入:

```
变量名：JAVA_HOME
变量值：电脑上JDK安装的绝对路径(例如：C:\Program Files\Java\jdk-17.0.2)
```

3. 新建/修改 CLASSPATH 变量，如果存在 **CLASSPATH** 变量，选中点击 **Edit(编辑)**。如果没有，点击 **New（新建）...** 新建。输入/在已有的变量值后面添加：

```
变量名：CLASSPATH
变量值：.;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar;
```

4. 修改Path 变量。由于 win10 的不同，当选中 **Path** 变量的时候，系统会很方便的把所有不同路径都分开了，不会像 win7 或者 win8 那样连在一起。新建两条路径：

```powershell
%JAVA_HOME%\bin
%JAVA_HOME%\jre\bin
```

4. 检查 打开 cmd，输入 **java**，出现一连串的指令提示，说明配置成功了。

## 环境要求

为了在使用过程中不出现意外的事故，给出下列推荐的配置

- CentOS 7.x
- 512 MB 以上内存

## 服务器配置

### 更新软件包

请确保服务器的软件包已经是最新的。

```bash
sudo yum update -y
```

###  装 Java 运行环境

> 若已经存在 Java 运行环境的可略过这一步。

```bash
# 安装 OpenJRE
sudo yum install java-11-openjdk -y

# 检测是否安装成功
java -version
```

当然，这只是其中一种比较简单的安装方式，你也可以用其他方式，并不是强制要求使用这种方式安装。

## 创建 Halo 用户

~~我们推荐创建一个低权限的用户运行 `halo`~~：（这一步我没有进行，直接用root）

```bash
# 创建 halo 用户
sudo useradd -m halo
# 直接登录该用户
sudo su halo
```

## 安装 Halo

### 创建存放运行包的目录

创建存放 运行包 的目录，这里以 ~/app 为例

```bash
mkdir ~/app && cd ~/app
```
### 下载运行包

```bash
wget https://dl.halo.run/release/halo-1.5.3.jar -O halo.jar
```
### 创建工作目录
```bash
mkdir ~/.halo && cd ~/.halo
```
### 下载配置文件

考虑到部分用户的需要，可能需要自定义比如端口等设置项，我们提供了公共的配置文件，并且该配置文件是完全独立于安装包的。当然，你也可以使用安装包内的默认配置文件，但是安装包内的配置文件是不可修改的。请注意：配置文件的路径为 `~/.halo/application.yaml`。

```bash
# 下载配置文件到 ~/.halo 目录
wget https://dl.halo.run/config/application-template.yaml -O ./application.yaml 
```
### 修改配置文件

完成上一步操作，我们就可以自己配置 `Halo` 的运行端口，以及数据库相关的配置了。

```bash
# 使用 Vi 工具修改配置文件
vi ~/.halo/application.yaml
```

打开之后我们可以看到

```yaml
server:
  port: 8090

  # Response data gzip.
  compression:
    enabled: false
spring:
  datasource:
    # H2 database configuration.
    driver-class-name: org.h2.Driver
    url: jdbc:h2:file:~/.halo/db/halo
    username: admin
    password: 123456

    # MySQL database configuration.
  #    driver-class-name: com.mysql.cj.jdbc.Driver
  #    url: jdbc:mysql://127.0.0.1:3306/halodb?characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
  #    username: root
  #    password: 123456

  # H2 database console configuration.
  h2:
    console:
      settings:
        web-allow-others: false
      path: /h2-console
      enabled: false

halo:
  # Your admin client path is https://your-domain/{admin-path}
  admin-path: admin

  # memory or level
  cache: memory
```

1. 如果需要自定义端口，修改 `server` 节点下的 `port` 即可。
2. 默认使用的是 `H2 Database` 数据库，这是一种嵌入式的数据库，使用起来非常方便。需要注意的是，默认的用户名和密码为 `admin` 和 `123456`，这个是自定义的，最好将其修改，并妥善保存。
3. 如果需要使用 `MySQL` 数据库，需要将 `H2 Database` 的所有相关配置都注释掉，并取消 `MySQL` 的相关配置。另外，`MySQL` 的默认数据库名为 `halodb`，请自行配置 `MySQL` 并创建数据库，以及修改配置文件中的用户名和密码。
4. `h2` 节点为 `H2 Database` 的控制台配置，默认是关闭的，如需使用请将 `h2.console.settings.web-allow-others` 和 `h2.console.enabled` 设置为 `true`。控制台地址即为 `域名/h2-console`。注意：非紧急情况，不建议开启该配置。
5. `server.compression.enabled` 为 `Gzip` 功能配置，如有需要请设置为 `true`，需要注意的是，如果你使用 `Nginx` 或者 `Caddy` 进行反向代理的话，默认是有开启 `Gzip` 的，所以这里可以保持默认。
6. `halo.admin-path` 为后台管理的根路径，默认为 `admin`，如果你害怕别人猜出来默认的 `admin`（就算猜出来，对方什么都做不了），请自行设置。仅支持一级，且前后不带 `/`。
7. `halo.cache` 为系统缓存形式的配置，可选 `memory` 和 `level`，默认为 `memory`，将数据缓存到内存，使用该方式的话，重启应用会导致缓存清空。如果选择 `level`，则会将数据缓存到磁盘，重启不会清空缓存。如不知道如何选择，建议默认。

注意：使用 MySQL 之前，必须要先新建一个 `halodb` 数据库，MySQL 版本需 5.7 以上。

```sql
create database halodb character set utf8mb4 collate utf8mb4_bin;
```
注意：使用 MySQL 之前，必须要先新建一个 halodb 数据库，MySQL 版本需 5.7 以上。

```bash
create database halodb character set utf8mb4 collate utf8mb4_bin;
```
### 运行 Halo
```bash
cd ~/app && java -jar halo.jar
```

如看到以下日志输出，则代表启动成功.

```bash
run.halo.app.listener.StartedListener    : Halo started at         http://127.0.0.1:8090
run.halo.app.listener.StartedListener    : Halo admin started at   http://127.0.0.1:8090/admin
run.halo.app.listener.StartedListener    : Halo has started successfully!
```

提示：以上的启动仅仅为测试 Halo 是否可以正常运行，如果我们关闭 ssh 连接，Halo 也将被关闭。要想一直处于运行状态，请继续看下面的教程。

### 作为服务运行

上面我们已经完成了 Halo 的整个配置和安装过程，接下来我们对其进行更完善的配置，比如：`需要开机自启？`，`更简单的启动方式？`

实现以上功能我们只需要新增一个配置文件即可，也就是使用 `Systemd` 来完成这些工作。

1.退出 halo 账户，登录到 root 账户
> 如果当前就是 root 账户，请略过此步骤。
```bash
exit
```
2.下载 Halo 官方的 halo.service 模板
```bash
wget https://dl.halo.run/config/halo.service -O /etc/systemd/system/halo.service
```
3.修改 halo.service
```bash
vi /etc/systemd/system/halo.service
```
4.修改配置

### 下载 Halo 官方的 halo.service 模板
```
wget https://dl.halo.run/config/halo.service -O /etc/systemd/system/halo.service
```
3.修改 halo.service
下载完成之后，我们还需要对其进行修改。

```bash
sudo vi /etc/systemd/system/halo.service
```

打开之后我们可以看到

+ `YOUR_JAR_PATH`：Halo 运行包的绝对路径，例如 `/root/app/halo.jar`，注意：此路径不支持 ~ 符号。
+ `USER`：运行 Halo 的系统用户，如果有按照上方教程创建新的用户来运行 Halo，修改为你创建的用户名称即可。反之请删除 **User=USER**。

```conf
[Unit]
Description=Halo Service
Documentation=https://halo.run
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=USER
ExecStart=/usr/bin/java -server -Xms256m -Xmx256m -jar YOUR_JAR_PATH
ExecStop=/bin/kill -s QUIT $MAINPID
Restart=always
StandOutput=syslog

StandError=inherit

[Install]
WantedBy=multi-user.target
```

参数：

- -Xms256m：为 JVM 启动时分配的内存，请按照服务器的内存做适当调整，512 M 内存的服务器推荐设置为 128，1G 内存的服务器推荐设置为 256，默认为 256。
- -Xmx256m：为 JVM 运行过程中分配的最大内存，配置同上。
- YOUR_JAR_PATH：Halo 安装包的绝对路径，例如 `/www/wwwroot/halo-latest.jar`。

提示：

1. 如果你不是按照上面的方法安装的 JDK，请确保 `/usr/bin/java` 是正确无误的。
2. systemd 中的所有路径均要写为绝对路径，另外，`~` 在 systemd 中也是无法被识别的，所以你不能写成类似 `~/halo-latest.jar` 这种路径。
3. 如何检验是否修改正确：把 ExecStart 中的命令拿出来执行一遍。

5.重新加载 systemd
```bash
# 修改 service 文件之后需要刷新 Systemd
systemctl daemon-reload
```
6.运行服务
```bash
systemctl start halo
```
7.在系统启动时启动服务
```bash
systemctl enable halo
```
您可以查看服务日志检查启动状态
```bash
journalctl -n 20 -u halo
```


## 配置域名访问

1. 假设你已经成功配置并运行好了 Halo，且不是使用 80 端口运行。
2. 请确保域名已经成功解析到服务器 IP，并确认服务器是否需要备案。
3. 请检查服务器的 80 和 443 端口是否开放。
4. 如 3 所述，如果你使用了类似 `宝塔面板` 之类的 Linux 管理面板，可能还需要在面板里设置端口。
5. 并不一定要求按照下列教程操作，这里仅仅以供参考。
6. 如 2 所述，你需要做的仅仅是反向代理 Halo 运行端口，并配置 SSL 证书而已，所以并不要求配置方式。

### 使用 Nginx 进行反向代理

我使用的是这一种方法。

#### 安装 Nginx

```bash
# 添加 Nginx 源
sudo rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

# 安装 Nginx
sudo yum install -y nginx

# 启动 Nginx
sudo systemctl start nginx.service

# 设置开机自启 Nginx
sudo systemctl enable nginx.service
```

#### 配置 Nginx

```bash
# 下载 Halo 官方的 Nginx 配置模板
curl -o /etc/nginx/conf.d/halo.conf --create-dirs https://dl.halo.run/config/nginx.conf
```

下载完成之后，我们还需要对其进行修改

```bash
# 使用 vim 编辑 halo.conf
vi /etc/nginx/conf.d/halo.conf
```

打开之后我们可以看到

```nginx
upstream halo {
  server 127.0.0.1:8090;
}
server {
  listen 80;
  listen [::]:80;
  server_name www.yourdomain.com;
  client_max_body_size 1024m;
  location / {
    proxy_pass http://halo;
    proxy_set_header HOST $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
```
注意：Nginx 默认的 client_max_body_size 配置大小为 1m，可能会导致你在 Halo 后台上传文件被 Nginx 限制，所以此示例配置文件加上了 client_max_body_size 1024m; 这行配置。当然，1024m 可根据你的需要自行修改。

修改完成之后

```bash
# 检查配置是否有误
sudo nginx -t

# 重载 Nginx 配置
sudo nginx -s reload
```

### 配置阿里云免费证书SSL 证书
目前使用的是Let’s Encrypt 免费证书。

1.在nginx根目录（默认为/etc/nginx）下创建目录cert。
```
cd /etc/nginx
mkdir cert
```
2.把下载的证书两个文件.pem和.key上传到目录cert中。

3.修改nginx配置文件（目前使用的是下面的官方推荐配置）

```bash
vi /etc/nginx/conf.d/halo.conf
```
~~自定义配置~~(不要用这个，用下面的官方配置）：
```yaml
server {
    listen 80;
    server_name bore.vip www.bore.vip;
    rewrite ^(.*)$ https://$host$1 permanent;

    client_max_body_size 1024m;
}
server {
    listen 443 ssl;

    server_name bore.vip;

    ssl_certificate /etc/nginx/cert/bore.vip.pem;
    ssl_certificate_key /etc/nginx/cert/bore.vip.key;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_set_header HOST $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_pass http://127.0.0.1:8090/;
    }
}

```
官方推荐配置（用这个）：
```yaml
upstream halo {
  server 127.0.0.1:8090;
}
server {
  listen 80;
  listen [::]:80;
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name bore.vip www.bore.vip;
  if ($host != 'bore.vip' ) {
      rewrite ^/(.*)$ https://bore.vip/$1 permanent;
  } 
  client_max_body_size 1024m;
  ssl_certificate /etc/nginx/cert/bore.vip.pem;
  ssl_certificate_key /etc/nginx/cert/bore.vip.key;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_session_timeout 10m;
  ssl_session_cache builtin:1000 shared:SSL:10m;
  ssl_buffer_size 1400;
  add_header Strict-Transport-Security max-age=15768000;
  ssl_stapling on;
  ssl_stapling_verify on;
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
}
```
4.重启nginx服务。

```bash
systemctl restart nginx
```
### 添加 Let's Encrypt 免费证书
#### **Centos 8**
1. 安装Certbot
```bash
yum install epel-release -y
yum install certbot -y
```
2. 新建相应文件夹
由于配置了反向代理，为了顺利申请证书，需要新建文件夹：
```bash
mkdir -p /data/wwwroot/bore.vip
mkdir -p /data/wwwlogs
```
3. 配置Nginx http 80端口

为了使下面申请证书时能访问http://bore.vip/.well-known/acme-challenge/.......这个链接，首先配置好

Nginx 80端口，保证上述网址能顺利访问，从而顺利申请证书。

由于配置了反向代理，所以在验证的时候是无法直接访问到站点目录下的 .well-known 文件夹下的验证文

件的。所以在nginx配置的server节点下添加：
```bash
location ^~ /.well-known/acme-challenge/ {
  default_type "text/plain";
  allow all;
  root /data/wwwroot/demo.halo.run/;
}
```
上述代码如果不行，试下下面的：
```bash
location ~ /.well-known {
    allow all;
}
```
编辑`halo.conf`
```bash
vi /etc/nginx/conf.d/halo.conf
```
```bash
upstream halo {
  server 127.0.0.1:8090;
}
server {
  listen 80;
  listen [::]:80;
  server_name bore.vip;
  client_max_body_size 1024m;
  location / {
    proxy_pass http://halo;
    proxy_set_header HOST $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
  location ^~ /.well-known/acme-challenge/ {
    default_type "text/plain";
    allow all;
    root /data/wwwroot/bore.vip/;
  }
}
```
4. 申请证书
```bash
certbot certonly --webroot -w /data/wwwroot/bore.vip -d bore.vip -m 455343442@qq.com --agree-tos
```
相关参数含义：  
+ –webroot是运行模式
 + standalone模式：需要停止当前的 web server 服务，让出 80 端口，由客户端内置的 web server 启动与Let’ s Encrypt通信。
- webroot模式：不需要停止当前 web server，但需要在域名根目录下创建一个临时目录，并要保证外网通过域名可以访问这个目录。 
+ -w 指定网站所在目录
+ -d 指定网站域名
+ -m 指定联系邮箱，填写真实有效的，letsencrypt会在证书在过期以前发送预告的通知邮件
+ agree-tos 表示接受相关协议

使用webroot模式，Certbot在验证服务器域名的时候，会生成一个随机文件，然后Certbot的服务器会通过HTTP访问你的这个文件，因此要确保你的 Nginx 配置好，以便可以访问到这个文件。否则会返回403错误，在nginx配置的server节点下添加：
 ```bash
 location ^~ /.well-known/acme-challenge/ {
  default_type "text/plain";
  allow all;
  root /data/wwwroot/demo.halo.run/;
}
 ```
上述代码如果不行，试下下面的：
```bash
location ~ /.well-known {
    allow all;
}
```
5. 配置Nginx 

编辑`halo.conf`
```bash
vi /etc/nginx/conf.d/halo.conf
```
```bash
upstream halo {
  server 127.0.0.1:8090;
}
server {
  listen 80;
  listen [::]:80;
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
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

测试配置是否有问题：
```bash
nginx -t
```

重启Nginx生效：
```bash
systemctl restart nginx
```
6. 证书自动更新
由于这个证书的时效只有 90 天，我们需要设置自动更新的功能，帮我们自动更新证书的时效。首先先在命令行模拟证书更新：
```bash
certbot renew --dry-run
```
模拟更新成功的效果如下：
```
[root@special-beep-1 ~]# certbot renew --dry-run
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/blog.bore.vip.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Simulating renewal of an existing certificate for blog.bore.vip

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/bore.vip.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Simulating renewal of an existing certificate for bore.vip

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/blog.bore.vip/fullchain.pem (success)
  /etc/letsencrypt/live/bore.vip/fullchain.pem (success)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```
在无法确认你的 nginx 配置是否正确时，一定要运行模拟更新命令，确保certbot和服务器通讯正常。使用 `crontab -e` 的命令来启用自动任务，命令行：
```bash
crontab -e
```
添加配置：（每隔两个月凌晨2:30自动执行证书更新操作）后保存退出。
```bash
30 2 * */2 * /usr/bin/certbot renew --quiet && /bin/systemctl restart nginx
```
查看证书有效期的命令：
```bash
openssl x509 -noout -dates -in /etc/letsencrypt/live/bore.vip/cert.pem
```
PS:如果失败，先申请阿里证书，再申请Let's Encrypt SSL证书，记得要添加 acme.sh 续签验证路由，才能申请Let's Encrypt SSL证书。

#### Debian10
1. 安装 Certbot
```bash
sudo apt-get install letsencrypt
```
2. 新建相应文件夹

由于配置了反向代理，为了顺利申请证书，需要新建文件夹：
```bash
mkdir -p /data/wwwroot/bore.vip
mkdir -p /data/wwwlogs
```
3. 配置Nginx http 80端口

为了使下面申请证书时能访问http://bore.vip/.well-known/acme-challenge/…这个链接，首先配置好

Nginx 80端口，保证上述网址能顺利访问，从而顺利申请证书。所以在nginx配置的server节点下添加：
```bash
location ^~ /.well-known/acme-challenge/ {
  default_type "text/plain";
  allow all;
  root /data/wwwroot/demo.halo.run/;
}
```
上述代码如果不行，试下下面的：
```bash
location ~ /.well-known {
    allow all;
}
```
4. 编辑`halo.conf`
```bash
vi /etc/nginx/conf.d/halo.conf
```
```bash
upstream halo {
  server 127.0.0.1:8090;
}
server {
  listen 80;
  listen [::]:80;
  server_name bore.vip;
  client_max_body_size 1024m;
  location / {
    proxy_pass http://halo;
    proxy_set_header HOST $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
  location ^~ /.well-known/acme-challenge/ {
    default_type "text/plain";
    allow all;
    root /data/wwwroot/bore.vip/;
  }
}
```
重启 Nginx 生效：

```
systemctl restart nginx
```

5. 使用 webroot 自动生成证书

Certbot 支持多种不同的「插件」来获取证书，这里选择使用 webroot 插件，它可以在不停止 Web 服务器的前提下自动生成证书，使用 --webroot 参数指定网站的根目录。
```bash
certbot certonly --webroot -w /data/wwwroot/bore.vip -d bore.vip -m 455343442@qq.com --agree-tos
```
>PS：用上面的命令，不要用下面的命令。
```bash
letsencrypt certonly --webroot -w /data/wwwroot/bore.vip -d bore.vip -m 455343442@qq.com --agree-tos
```
这样，在 /var/www/hexo 目录下创建临时文件 .well-known/acme-challenge ，通过这个文件来证明对域名 iwyang.top 的控制权，然后 Let’s Encrypt 验证服务器发出 HTTP 请求，验证每个请求的域的 DNS 解析，验证成功即颁发证书。

生成的 pem 和 key 在 /etc/letsencrypt/live/ 目录下

6. 配置Nginx

编辑`halo.conf`，未开启443端口复用：

```bash
vi /etc/nginx/conf.d/halo.conf
```
```bash
upstream halo {
  server 127.0.0.1:8090;
}
server {
  listen 80;
  listen [::]:80;
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
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
如果开启443端口复用：
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
测试配置是否有问题：
```bash
nginx -t
```
重启Nginx生效：
```bash
systemctl restart nginx
```
7. 自动续期

Let’s Encrypt 的证书有效期为 90 天，不过我们可以通过 crontab 定时运行命令更新证书。

先运行以下命令来测试证书的自动更新：
```bash
certbot renew --dry-run
```
>PS：用上面的命令，不要用下面的命令。

`letsencrypt renew --dry-run --agree-tos`

如果一切正常，就可以编辑 crontab 定期运行以下命令：
```bash
crontab -e
```
```bash
30 2 * */2 * /usr/bin/certbot renew --quiet && /bin/systemctl restart nginx
```
## halo更改评论模块

首先进入后台，依次点击：`系统`—`博客设置`—`评论设置`，更改`评论模块JS`。系统默认（halo 1.3.2）`评论模块JS`为：

```bash
//cdn.jsdelivr.net/npm/halo-comment@latest/dist/halo-comment.min.js
```

更改为[halo-comment-fly](https://github.com/halo-dev/halo-comment-fly)评论模块JS：

```bash
https://cdn.jsdelivr.net/gh/hshanx/halo-comment-fly@latest/dist/halo-comment.min.js
```

或者：

```bash
https://cdn.jsdelivr.net/gh/hshanx/halo-comment-hshan@2.0.6/dist/halo-comment.min.js
```

更多`评论模块JS`，可以在`github`中搜索[halo comment](https://github.com/search?q=halo+comment)。

## 定时删除halo日志

```bash
crontab -e
```

```bash
0 0 * * * rm -rf /root/.halo/logs/*
```

意思是每天删除日志文件。

## 更改时区

如果你不知道服务器当前时间，可以使用下面的命令，查看当前时间：

```bash
date -R
```

修改当前时区为上海（为了避免日志发表时间出现错误）：

```bash
sudo timedatectl set-timezone Asia/Shanghai
```
再次不带任何选项参数调用timedatectl命令，打印系统当前设置的时区即可：

```bash
timedatectl
```
## 版本升级

> 我们假设你存放运行包的路径为 ~/app，运行包的文件名为 halo.jar，且使用了 systemd 进行进程管理，如有不同，下列命令请按需修改。

1. 停止正在运行的服务
```bash
service halo stop
```
2. 备份数据以及旧的运行包（重要）
```bash
cp -r ~/.halo ~/.halo.archive
mv ~/app/halo.jar ~/app/halo.jar.archive
```
>需要注意的是，.halo.archive 和 halo.jar.archive 文件名不一定要根据此文档命名，这里仅仅是个示例。

3. 清空 leveldb 缓存（如果有使用 leveldb 作为缓存策略）
```bash
rm -rf ~/.halo/.leveldb
```
4. 下载最新版本的运行包
```bash
cd ~/app && wget https://dl.halo.run/release/halo-1.5.3.jar -O halo.jar
```
5. 启动测试
```bash
java -jar halo.jar
```
<joe-message type="info" content="如测试启动正常，请继续下一步。使用 CTRL+C 停止运行测试进程。"></joe-message>

6. 重启服务
```bash
service halo start
```
## 备份迁移

目前 Halo 在后台的小工具中提供了数据导出的功能，此功能的作用为导出数据库的所有数据，格式为 JSON。通常可以作为切换数据库类型的时候使用。需要注意的是，此备份仅仅为备份数据，不包含其他诸如主题、附件等资料。如下图：

### 整站备份
通过 《写在前面》 的名词解释部分我们可以知道，Halo 的所有数据都是存放在当前用户目录的工作目录（.halo）下的（使用 MySQL 数据库除外，你还需要导出 MySQL 数据）。所以我们备份整站的数据仅需备份这个目录即可，不管你使用何种方式。不过，为了操作方便，我们也在后台的小工具中提供了备份整站数据的功能，和上面所说的数据备份一致，点击备份按钮即可打包工作目录文件夹。如下图：

### 导入数据
此功能为导入上面所说的数据备份产生的数据文件（JSON 格式），并非整站备份的工作目录文件。需要注意的是，此功能仅在站点初始化的时候支持。如下图：

### 整站迁移
此操作通常用于迁移服务器，基于上面 整站备份 所说，Halo 的所有数据都是存放于当前用户目录的工作目录（.halo）下的。当然，这仅限于使用 H2 Database 的情况下，如果你使用的 MySQL，那么还需要手动导出 MySQL 数据。所以，我们迁移服务器仅仅需要需要将工作目录的备份文件上传到新服务器的用户目录下解压，然后按照 《安装指南》 重新安装即可。MySQL 用户还需要做的就是手动导出 MySQL 数据，并在新服务器上导入。

## 常见问题
1.忘记了管理员密码，如何重置？

目前在登录页面含有隐藏的 找回密码 链接，点击即可进入找回密码页面，具体可参考以下步骤：

1. 在登录页面按下键盘快捷键（Windows / Linux：Shift + Alt + H，macOS：Shift + Command + H）即可显示 找回密码 链接。
2. 按照表单提示输入用户名和邮箱，点击 获取 按钮即可发送带有验证码的邮件。
3. 按照表单填写验证码和新密码，点击重置密码即可。
>需要注意的是，第 2 步中的获取验证码需要事先配置了 SMTP 发信设置，否则无法发送验证码。但你可以登录服务器查看 Halo 运行日志，搜索 Got reset password code 关键字即可获取到验证码。

## 附：修改 Nginx 配置文件
1. 使用你熟悉的工具打开配置文件，此教程使用 vi。
```bash
vi /etc/nginx/conf.d/halo.conf
```
2. 添加 upstream 配置
在 `server` 的同级节点添加如下配置：
```bash
upstream halo {
  server 127.0.0.1:8090;
}
```
3. 在 server 节点添加如下配置
```bash
location / {
  proxy_set_header HOST $host;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_pass http://halo;
}
```
4. 修改 location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ 节点
```bash
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ {
  proxy_pass http://halo;
  expires 30d;
  access_log off;
}
```
5. 修改 location ~ .*\.(js|css)?$ 节点
```bash
location ~ .*\.(js|css)?$ {
  proxy_pass http://halo;
  expires 7d;
  access_log off;
}
```
如果不按照第 4，5 步操作，请求一些图片或者样式文件不会经过 Halo，所以请不要忽略此配置。

~~6. 添加 acme.sh 续签验证路由~~

~~OneinStack 使用的 acme.sh 管理证书，如果你在创建 vhost 的时候选择了使用 Let's Encrypt 申请证书，那么 OneinStack 会在系统内添加一个定时任务去自动续签证书，acme.sh 默认验证站点所有权的方式为在站点根目录生成一个文件（.well-known）来做验证，由于配置了反向代理，所以在验证的时候是无法直接访问到站点目录下的 .well-known 文件夹下的验证文件的。需要添加如下配置：~~
```bash
location ^~ /.well-known/acme-challenge/ {
  default_type "text/plain";
  allow all;
  root /data/wwwroot/demo.halo.run/;
}
```
如果上述代码失效，可以试下：
```bash
location ~ /.well-known {
    allow all;
}
```
至此，配置修改完毕，保存即可。最终你的配置文件可能如下面配置一样：
```yaml
upstream halo {
  server 127.0.0.1:8090;
}
server {
  listen 80;
  listen [::]:80;
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  ssl_certificate /usr/local/nginx/conf/ssl/demo.halo.run.crt;
  ssl_certificate_key /usr/local/nginx/conf/ssl/demo.halo.run.key;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_session_timeout 10m;
  ssl_session_cache builtin:1000 shared:SSL:10m;
  ssl_buffer_size 1400;
  add_header Strict-Transport-Security max-age=15768000;
  ssl_stapling on;
  ssl_stapling_verify on;
  server_name demo.halo.run;
  access_log /data/wwwlogs/demo.halo.run_nginx.log combined;
  index index.html index.htm index.php;
  root /data/wwwroot/demo.halo.run;
  if ($ssl_protocol = "") { return 301 https://$host$request_uri; }
  include /usr/local/nginx/conf/rewrite/none.conf;
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
    root /data/wwwroot/demo.halo.run/;
  }
}
```
## https www跳转
```diff
upstream halo {
  server 127.0.0.1:8090;
}
server {
  listen 80;
  listen [::]:80;
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name bore.vip www.bore.vip;
+  if ($host != 'bore.vip' ) {
+      rewrite ^/(.*)$ https://bore.vip/$1 permanent;
+  }
```
## 参考链接

+ [1.在 Linux 服务器部署 Halo](https://docs.halo.run/getting-started/install/linux)
+ [2.配置域名访问](https://halo.run/archives/install-reverse-proxy.html)
+ [3.CentOS 7 Nginx配置Let's Encrypt SSL证书](https://juejin.im/entry/5b59c3f26fb9a04fda4e2238)
+ [4.windows 10 配置Java 环境变量](https://www.jianshu.com/p/9fc41ea941aa)
+ [5.如何设置或更改系统时区在CentOS 8](https://www.myfreax.com/how-to-set-or-change-timezone-on-centos-8/)