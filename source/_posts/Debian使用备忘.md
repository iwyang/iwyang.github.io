---
title: Debian使用备忘
categories:
  - 技术
tags:
  - linux
abbrlink: 9eb70758
date: 2022-05-29 01:12:45
cover: ../img/cover/debian.jpg
---

由于一些原因，之前服务器上用的Centos换成了Debian。Debian虽然和Centos大同小异，但是还是有些东西要记一下。

{% note warning flat %}
Debian10 上安装部分应用，速度几乎为0，至少需要Debian11以上，512M内存足够。
{% endnote %}

{% note primary no-icon %}
推荐使用terminal(ssh 工具) ，[finashell](https://www.hostbuf.com/) 也行。
{% endnote %}

## **Debian 更新报错的解决方法**

~~一台很老的Debian使用apt-get update的时候，出现一下报错。~~（非必要，不要更新）

**解决方法**

```bash
apt-get update --allow-releaseinfo-change
apt-get upgrade
```

**提示**：Unable to fetch some archives, maybe run apt-get update or try with --fix-missing?

**解决方法**（问chatgpt）：

```bash
apt-get update --fix-missing
```

## 调整时区

如果你不知道服务器当前时间，可以使用下面的命令，查看当前时间：

```
date -R
```

修改当前时区为上海：

```
sudo timedatectl set-timezone Asia/Shanghai
```

再次不带任何选项参数调用 timedatectl 命令，打印系统当前设置的时区即可：

```
timedatectl
```

## putty保存登录账号和密码

1.创建一个桌面快捷方式。

2.进入快捷方式属性，修改目标，在后面加上 -ssh -l 用户名 -pw 密码 -i session标识 -P 端口号 IP地址。例如 "C:\Program Files\PuTTY\putty.exe" -ssh -l root -pw 123456 -i "yuanchengserver1" -P 22 142.16.187.129

```
E:\软件\putty.exe -ssh -l root -pw password -i "yansvps" -P 22 ip
```
3.然后，通过快捷方式就可以直接登录了~

PS：`putty`没有[FinalShell](https://www.hostbuf.com/)好用。

## `vi`无法正常使用
1.先安装`vim`：

```bash
apt install vim -y
```
2.修改`vimrc.tiny`
`vi /etc/vim/vimrc.tiny` 将其中的语句 `set compatible` 修改为 `set nocompatible` ，非兼容模式下可以解决方向键变ABCD的问题。

在刚才那句话后面再加一句 `set backspace=2` 来解决退格键无法使用的问题。
```bash
vi /etc/vim/vimrc.tiny
set nocompatible
set backspace=2
```
3.卸载`vim`
vim颜色太花眼了，所以最后把它卸载：

```bash
apt remove vim -y
```


## Debian安装vsftpd

{% note warning no-icon %}
传输大文件慢，可以用transmission下载完后，配合nginx开启目录浏览，配置好SSL使用；也可以用[terminal](https://www.terminal.icu/)(ssh工具)上传~~下载~~文件，finashell也行。
{% endnote %}

0.开启21端口：

```bash
iptables -I INPUT 5 -p tcp --dport 21 -j ACCEPT
```

1.安装命令：

```bash
sudo apt install vsftpd -y
```
2.安装软件包后，启动vsftpd，并使其能够在引导时自动启动：

```bash
sudo systemctl start vsftpd
sudo systemctl enable vsftpd
```
3.编辑`vsftpd.conf`

```bash
vi /etc/vsftpd.conf
```
---

（1）去掉`write_enable=YES`前面的注释，使用户可以上传文件。

（2）要仅允许某些用户登录FTP服务器，请在文件末尾添加以下行：

```bash
userlist_enable=YES
userlist_file=/etc/vsftpd.user_list
userlist_deny=NO
```

启用此选项后，您需要通过向`/etc/vsftpd.user_list`文件添加用户名（每行一个用户）明确指定哪些用户能够登录。

（3）添加FTP用户。

```bash
sudo adduser admin
sudo passwd admin
```

（4）将用户添加到允许的 FTP 用户列表中：

```bash
echo "admin" | sudo tee -a /etc/vsftpd.user_list
```

（5）关闭防火墙

```bash
systemctl stop firewalld.service
systemctl disable firewalld.service 
```

（6）**使 ftp 用户`admin`可以上传文件到指定目录**

```bash
sudo chmod 755 /var/www/speak
sudo chown -R admin: /var/www/speak
```

（7）重启 vsftpd 服务

保存文件并重新启动 vsftpd 服务，以使更改生效：

```
sudo systemctl restart vsftpd
```

---

4.设置允许root登录

+ 将`root`添加到允许的FTP用户列表中：

```bash
echo "root" | sudo tee -a /etc/vsftpd/user_list
```

+ 修改`/etc/vsftpd/user_list`和`/etc/ftpusers`两个设置文件脚本，将root账户前加上`#`号变为注释

```bash
vi /etc/vsftpd/user_list
```

```bash
vi /etc/ftpusers
```

5.重启vsftpd服务

```bash
sudo systemctl restart vsftpd
```
6.解决Nginx出现403 forbidden

j假设网站根目录在`/var/www/blog/`，则执行：

```bash
chmod -R 777 /var/www
```
7.限制用户登录（未启用）

要仅允许某些用户登录FTP服务器，请在文件末尾添加以下几行：
```bash
vi /etc/vsftpd.conf
```
```diff
userlist_enable=YES
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO
```
启用此选项后，您需要通过将用户名添加到/etc/vsftpd.user_list文件（每行一个用户）来明确指定哪些用户可以登录。使用以下命令：
```bash
echo "admin" | sudo tee -a /etc/vsftpd/user_list
```

## 开启80、443端口

```
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
```

````
service iptables save
````

```
service iptables restart
```

## Debian 9上安装和配置Postfix邮件

1.安装 mailtuils:

```bash
sudo apt install mailutils -y
```
2.安装postfix后缀:

```bash
sudo apt install postfix
```
在安装过程即将结束时，您将看到一个类似于下图中的窗口的窗口。默认选项是`Internet Site`。这是本教程的推荐选项，请按`TAB`，然后按`ENTER`。
之后，您将获得另一个窗口，就像下一个图像中的窗口一样。该系统邮件名称应该是一样的，你分配给服务器，当你在创造它的名字。如果它显示子域`subdomain.example.com`，请将其更改为`ust example.com`。完成后，按`TAB`，然后`ENTER`。

3.配置Postfix

```bash
vi /etc/postfix/main.cf
```
打开文件后，向下滚动，直到看到以下部分：
```bash
. . .
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
. . .
```
将读取的inet_interfaces = all行更改为inet_interfaces = loopback-only：
```bash
. . .
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = loopback-only
. . .
```
您需要修改的另一个指令是mydestination，用于指定通过local_transport邮件传递传输传递的域列表。默认情况下，值类似于：
```bash
. . .
mydestination = $myhostname, example.com, localhost.com, , localhost
. . .
```
此指令的建议默认值在下面的代码块中给出，因此请修改以匹配：
```bash
. . .
mydestination = $myhostname, localhost.$your_domain, $your_domain
. . .
```
4.重启Postfix。

```bash
sudo systemctl restart postfix
```
5.测试SMTP服务器

```bash
echo "This is the body of the email" | mail -s "This is the subject line" your_email_address
```
6.debian 彻底删除posfix 然后重新安装

如果安装出错，先彻底删除posfix 然后重新安装

+ 关闭 service postfix start
```bash
service postfix  stop
```
+ 卸载postfix
```bash
apt-get remove  postfix -y
dpkg --purge postfix
apt autoremove
```
+ 查看配置文件是否已经删除

查看 /etc/postfix是否已经删除掉

## ~~安装Transmission~~

{% note primary no-icon %}
速度不及下面的qbittorrent
{% endnote %}

1.安装

```bash
sudo apt-get update -y
sudo apt-get install transmission transmission-daemon -y
```

2.启动&关闭

```
systemctl start transmission-daemon
systemctl enable transmission-daemon
systemctl stop transmission-daemon
```

3.修改配置（关闭后再修改配置）

```
sudo vi /var/lib/transmission-daemon/info/settings.json
```

```diff
{
    "download-dir": "/home/admin",
    ......
    "rpc-authentication-required": true
    "rpc-bind-address": "0.0.0.0", 
    "rpc-enabled": true, 
    "rpc-password": "123456", 
    "rpc-port": 9091, 
    "rpc-url": "/transmission/", 
    "rpc-username": "transmission", 
    "rpc-whitelist": "*", 
    "rpc-whitelist-enabled": true, 
    ......
```

**主要是`rpc-whitelist`、`用户名`、`密码`和` download-dir（可选）`**



如果修改下载目录，将下载目录改成： "download-dir": "/home/admin"，那么还要赋予`debian-transmission`读写`/home/admin`的权限：

```
sudo chmod 755 /home/admin
sudo chown -R debian-transmission: /home/admin
```

执行`sudo vi /etc/init.d/transmission-daemon`可以看到运行用户。



4.美化WEB UI：

```
wget https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control-cn.sh
bash install-tr-control-cn.sh
```

### 安装nginx

```bash
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 配置nginx

```yaml
server {
  listen  80 ;
  listen [::]:80;
  root /home/admin;
  server_name example.com;
  access_log  /var/log/nginx/hexo_access.log;
  error_log   /var/log/nginx/hexo_error.log;
  error_page 404 =  /404.html;
  location ~* ^.+\.(ico|gif|jpg|jpeg|png)$ {
    root /home/admin;
    access_log   off;
    expires      1d;
  }
  location ~* ^.+\.(css|js|txt|xml|swf|wav)$ {
    root /home/admin;
    access_log   off;
    expires      10m;
  }
  location / {
    root /home/admin;
    if (-f $request_filename) {
    rewrite ^/(.*)$  /$1 break;
    }
  }
  location /nginx_status {
    stub_status on;
    access_log off;
 }
 
  autoindex on;                        
  autoindex_exact_size off;            
  autoindex_localtime on;              
  charset utf-8,gbk;
}
```

### debian11配置SSL证书

#### 安装 Certbot

```bash
sudo apt-get install letsencrypt -y
```

#### 使用 webroot 自动生成证书

```bash
certbot certonly --webroot -w /home/admin -d example.com -m 455343442@qq.com --agree-tos
```

#### 编辑`Nginx`

```
vi /etc/nginx/conf.d/ftp.conf
```

```yaml
server {
    listen 80;
    listen [::]:80;
    root /home/admin;
    server_name  example.com;

    listen 443 ssl; # managed by Certbot

    # RSA certificate
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem; # managed by Certbot


    # Redirect non-https traffic to https
    if ($scheme != "https") {
        return 301 https://$host$request_uri;
    } # managed by Certbot
	
	  autoindex on;                        
      autoindex_exact_size off;            
      autoindex_localtime on;              
      charset utf-8,gbk;
}
```

测试配置是否有问题：

```
nginx -t
```

重启 Nginx 生效：

```
systemctl restart nginx
```

#### 自动续期

Let’s Encrypt 的证书有效期为 90 天，不过我们可以通过 crontab 定时运行命令更新证书。

先运行以下命令来测试证书的自动更新：

```
certbot renew --dry-run
```

如果一切正常，就可以编辑 crontab 定期运行以下命令：

```
crontab -e
```

```
30 2 * */2 * /usr/bin/certbot renew --quiet && /bin/systemctl restart nginx
```

查看证书有效期的命令：

```
openssl x509 -noout -dates -in /etc/letsencrypt/live/example.com/cert.pem
```

## 安装`qbittorrent-nox`

**1.**安装qbittorrent-nox

```yaml
apt update 
apt install qbittorrent-nox -y
```

**2.** 新建systemd文件，如下所示：

```bash
vi /etc/systemd/system/qbittorrent-nox.service
```

```bash
[Unit]
Description=qBittorrent Command Line Client
After=network.target
[Service]
User=root
ExecStart=/usr/bin/qbittorrent-nox
Restart=on-failure
[Install]
WantedBy=multi-user.target
```

**3.** 启用进程守护，直接执行以下命令就行了，最后一条命令执行完，出现`active`关键字就说明一切都如预期的那样跑起来了。

```
systemctl daemon-reload
systemctl start qbittorrent-nox
systemctl enable qbittorrent-nox
systemctl status qbittorrent-nox
```

至此，在浏览器中输入服务器的IP和qbittorrent-nox的端口就可以进入了，例如[http://1.1.1.1:8080](http://1.1.1.1:8080/)，这里的1.1.1.1是服务器的IP，8080是刚才进程守护文件中写入的端口。用户名是admin，用户密码：adminadmin。
强烈建议进去之后，立马修改用户名和用户密码！！！具体位置在`tool>options>webui`这里，还可以修改成中文。

**4.** 修改下载目录和设置权限

```
mkdir /home/admin
chmod 777 /home/admin
```

重启qbittorrent-nox：

```
systemctl daemon-reload
```

5.最后把下载路径设置到`/home/admin`就OK了！

## Nginx反代qbittorrent-nox的Web-GUI

### 修改监听地址

http+非标端口，总让人强迫症犯了，所以搞了个SSL和Nginx反代，让qbittorrent-nox的Web-GUI看起来舒服一些。
首先，在`tool>options>webui`中，将监听的IP地址从`*`改成`127.0.0.1`，然后执行重启命令`systemctl restart qbittorrent-nox`以生效。这样只有服务器本地才能访问，其他都不行(网页打不开，待后面配置好域名才能访问)

### 安装 nginx

```yaml
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 新建网站目录

为了便于申请证书，需要新建反代网站目录，**一定不要在`/root`目录上新建**

```
mkdir -p /var/www/qt
cp /usr/share/nginx/html/* /var/www/qt
```

### 配置 nginx

```
vi /etc/nginx/conf.d/qt.conf
```

修改配置文件，将`server_name _;`中的`_`改成域名，在`location /`中注释掉`try_files $uri $uri/ =404;`（debian11上没有这一行，不用注释），并将以下内容写入`location /字段`：

```yaml
                proxy_pass http://127.0.0.1:8080/;
                proxy_http_version 1.1;
                proxy_set_header X-Forwarded-Host $http_host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                http2_push_preload on;
```

### 配置 Nginx http 80 端口

为了使下面申请证书时能访问 http://bore.vip/.well-known/acme-challenge/… 这个链接，首先配置好http://bore.vip/.well-known/acme-challenge/…这个链接，首先配置好Nginx 80 端口，保证上述网址能顺利访问，从而顺利申请证书。所以在 nginx 配置的 server 节点下添加：

```
location ~ /.well-known {
    allow all;
}
```

最终修改为：

```yaml
server {
    listen       80;
	root   /var/www/qt;
    index index.html index.htm index.nginx-debian.html;
    server_name  qt.bore.vip;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
		
		proxy_pass http://127.0.0.1:8080/;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        http2_push_preload on;
    }
    
    location ~ /.well-known {
    allow all;
}
}
```

测试配置是否有问题：

```
nginx -t
```

重启 Nginx 生效：

```
systemctl restart nginx
```

### 配置SSL证书

实际上，我还添加了SSL（需要先注释掉server中的`listen 80 default_server;`和`listen [::]:80 default_server;`两行
）。整体示例如下，就不细说了，可以对照着自己配置文件修改。如果不熟悉的，强烈建议使用`Let's Encrypt`等一键SSL/TLS程序添加SSL功能。

#### 安装 Certbot

```
sudo apt-get install letsencrypt -y
```

#### 使用 webroot 自动生成证书

```
certbot certonly --webroot -w /var/www/qt -d qt.bore.vip -m 455343442@qq.com --agree-tos
```

----

如果提示404错误：

```
sudo chmod 755 /var/www/qt
systemctl restart nginx
systemctl restart qbittorrent-nox
```

RN可能要多申请几遍证书，bwg一次就成功了。

---

#### 编辑 `Nginx`

```
vi /etc/nginx/conf.d/qt.conf
```

```yaml
server {
    listen       80;
    server_name  qt.bore.vip;
	root /var/www/qt;
        
	# Add index.php to the list if you are using PHP
     index index.html index.htm index.nginx-debian.html;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
		proxy_pass http://127.0.0.1:8080/;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        http2_push_preload on;
    }
    
    location ~ /.well-known {
    allow all;
}

        listen 443 ssl; # managed by Certbot

        # RSA certificate
        ssl_certificate /etc/letsencrypt/live/qt.bore.vip/fullchain.pem; # managed by Certbot
        ssl_certificate_key /etc/letsencrypt/live/qt.bore.vip/privkey.pem; # managed by Certbot

	
	    # Redirect non-https traffic to https
    if ($scheme != "https") {
        return 301 https://$host$request_uri;
    } # managed by Certbot
}

```

测试配置是否有问题：

```
nginx -t
```

重启 Nginx 生效：

```
systemctl restart nginx
```

#### 自动续期

Let’s Encrypt 的证书有效期为 90 天，不过我们可以通过 crontab 定时运行命令更新证书。

先运行以下命令来测试证书的自动更新：

```
certbot renew --dry-run
```

如果一切正常，就可以编辑 crontab 定期运行以下命令：

```
crontab -e
```

```
30 2 * */2 * /usr/bin/certbot renew --quiet && /bin/systemctl restart nginx
```

查看证书有效期的命令：

```
openssl x509 -noout -dates -in /etc/letsencrypt/live/qt.bore.vip/cert.pem
```
## 配置nginx开启目录浏览

将qt下载目录结合nginx开启目录浏览，便于下载。

### 安装 nginx

```
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 配置 nginx

```
vi /etc/nginx/conf.d/ftp.conf
```

```yaml
server {
  listen  80 ;
  listen [::]:80;
  root /home/admin;
  server_name ftp.bore.vip;
  access_log  /var/log/nginx/hexo_access.log;
  error_log   /var/log/nginx/hexo_error.log;
  error_page 404 =  /404.html;
  location ~* ^.+\.(ico|gif|jpg|jpeg|png)$ {
    root /home/admin;
    access_log   off;
    expires      1d;
  }
  location ~* ^.+\.(css|js|txt|xml|swf|wav)$ {
    root /home/admin;
    access_log   off;
    expires      10m;
  }
  location / {
    root /home/admin;
    if (-f $request_filename) {
    rewrite ^/(.*)$  /$1 break;
    }
  }
  location /nginx_status {
    stub_status on;
    access_log off;
 }
 
  autoindex on;                        
  autoindex_exact_size off;            
  autoindex_localtime on;              
  charset utf-8,gbk;
}
```

### 配置 SSL 证书

#### 安装 Certbot

```
sudo apt-get install letsencrypt -y
```

#### 使用 webroot 自动生成证书

```
certbot certonly --webroot -w /home/admin -d example.com -m 455343442@qq.com --agree-tos
```

#### 编辑 `Nginx`

```
vi /etc/nginx/conf.d/ftp.conf
```

```yaml
server {
    listen 80;
    listen [::]:80;
    root /home/admin;
    server_name  ftp.bore.vip;

    listen 443 ssl; # managed by Certbot

    # RSA certificate
    ssl_certificate /etc/letsencrypt/live/ftp.bore.vip/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/ftp.bore.vip/privkey.pem; # managed by Certbot


    # Redirect non-https traffic to https
    if ($scheme != "https") {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    location / {
        root /home/admin;
        autoindex on;                        
        autoindex_exact_size off;            
        autoindex_localtime on;              
        charset utf-8,gbk;
    }
}

```

```
systemctl restart nginx
```

#### 自动续期

Let’s Encrypt 的证书有效期为 90 天，不过我们可以通过 crontab 定时运行命令更新证书。

先运行以下命令来测试证书的自动更新：

```
certbot renew --dry-run
```

如果一切正常，就可以编辑 crontab 定期运行以下命令：

```
crontab -e
```

```
30 2 * */2 * /usr/bin/certbot renew --quiet && /bin/systemctl restart nginx
```

查看证书有效期的命令：

```
openssl x509 -noout -dates -in /etc/letsencrypt/live/ftp.bore.vip/cert.pem
```

## 附录

### `vsftpd.conf`注释

```shell
# 全域性配置
# 本地系統使用者寫入許可權；
write_enable=YES

# 本地使用者建立檔案及目錄預設許可權掩碼；
local_umask=022

# 列印目錄顯示資訊，通常用於使用者第一次訪問目錄時，資訊提示；
dirmessage_enable=YES

# 啟用上傳/下載日誌記錄； 
xferlog_enable=YES

# 日誌檔案將根據xferlog的標準格式寫入；
xferlog_std_format=YES

# 指定 log 路徑
xferlog_file=/var/log/vsftpd.log

# FTP使用20埠進行資料傳輸；
connect_from_port_20=YES

# Vsftpd不以獨立的服務啟動，通過Xinetd服務管理，建議改成YES；
listen=NO

# 啟用IPV6監聽；
listen_ipv6=YES

# 登入FTP伺服器，依據/etc/pam.d/vsftpd中內容進行認證；
pam_service_name=vsftpd

# Vsftpd.user_list和ftpusers配置檔案裡使用者禁止訪問FTP；
userlist_enable=YES

# 設定vsftpd與tcp wrapper結合進行主機的訪問控制，Vsftpd伺服器檢查/etc/hosts.allow 和/etc/hosts.deny中的設定，來決定請求連線的主機，是否允許訪問該FTP伺服器。
tcp_wrappers=YES

# 限制使用者都只能讀取家目錄
chroot_local_user=YES

# 這樣子才可以正常讀取家目錄
allow_writeable_chroot=YES

# 帳號清單路徑
userlist_file=/etc/vsftpd.userlist

# 白名單，拒絕除檔案中的使用者外的使用者FTP訪問
userlist_deny=NO

# 是否使用本地時間？vsftpd 預設使用 GMT 時間(格林威治)，所以會比台灣晚 8 小時，建議設定為 YES 吧
use_localtime=YES

# 這個選項必須指定一個空的資料夾且任何登入者都不能有寫入的權限，當vsftpd 不需要file system 的權限時，就會將使用者限制在此資料夾中。預設值為/usr/share/empty
secure_chroot_dir=/var/run/vsftpd/empty

# 這樣子有可能在傳中文不會有亂碼
syslog_enable=YES

# 同一個IP最大同時下載人數，預設沒有限制
max_per_ip=1

# 連線閒置時間超180秒就中斷，單位以second
accept_timeout=180(DEFAULT:60)

# 資料傳送閒置時間超180秒就中斷，單位以second
data_connection_timeout=180(DEFAULT:YES)

# 本地使用者配置
# 啟用本地系統使用者訪問；
local_enable=YES

# 本地使用者建立檔案及目錄預設許可權掩碼；
local_umask=022

# 修改本地使用者登入時訪問的目錄路徑
local_root=/home/ftp

# 匿名使用者訪問配置（最大許可權）
# 開啟匿名使用者訪問；
anonymous_enable=NO

# 匿名使用者上傳檔案的umask值
anon_umask=022

# 允許匿名使用者上傳檔案
anon_upload_enable=YES

# 允許匿名使用者建立目錄
anon_mkdir_write_enable=YES

# 允許匿名使用者修改目錄名稱或刪除目錄
anon_other_write_enable=YES

# 修改匿名使用者登入時訪問的目錄路徑
anon_root=/data/ftpdata
```

## 参考链接

+ [1.解决 Debian 下使用 vi 时方向键乱码，退格键不能使用的问题](https://www.uskvm.com/p/32.html)
+ [2.Debian安装vsftpd](https://shixiongfei.com/debian-vsftpd.html)
+ [3.Debian下vsftpd设置允许root登录分析](https://blog.fish2bird.com/?p=706)
+ [4.putty保存登录账号和密码](https://zhuanlan.zhihu.com/p/83730878)
+ [5.如何在Debian 9上使用VSFTPD设置FTP服务器](https://www.myfreax.com/how-to-setup-ftp-server-with-vsftpd-on-debian-9/)
+ [6.Ubuntu安装Transmission并美化WEB UI实操教程](https://cloud.tencent.com/developer/article/1946063)
+ [7.Update: Using Free Let’s Encrypt SSL/TLS Certificates with NGINX](https://www.nginx.com/blog/using-free-ssltls-certificates-from-lets-encrypt-with-nginx/)
+ 8.[Debian 11安装qbittorrent-nox并设置Nginx反代](https://pa.ci/210.html)
+ [9.Debian安装qbittorrent-nox](https://zxqme.com/archives/143/)

