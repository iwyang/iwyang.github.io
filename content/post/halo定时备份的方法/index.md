---
title: halo定时备份的方法
categories:
  - 技术
tags:
  - halo
slug: 3a4bd17
date: 2020-07-26 13:49:25
cover: false
---



 在网上查询了一下halo定时备份有三种方案：邮箱和Dropbox，以及github。

## 备份到QQ邮箱

### **安装邮件发送依赖组件**

#### Centos 7

```bash
yum install sendmail mailx -y
```

#### Centos 8

```bash
yum -y install postfix sendmail-cf mailx
service postfix start
sudo systemctl enable postfix
```
#### Debian
1. 安装 mailtuils:
```bash
sudo apt install mailutils -y
```
2. 安装postfix后缀:
```bash
sudo apt install postfix
```
在安装过程即将结束时，您将看到一个类似于下图中的窗口的窗口。默认选项是`Internet Site`。这是本教程的推荐选项，请按`TAB`，然后按`ENTER`。
之后，您将获得另一个窗口，就像下一个图像中的窗口一样。该系统邮件名称应该是一样的，你分配给服务器，当你在创造它的名字。如果它显示子域`subdomain.example.com`，请将其更改为`ust example.com`。完成后，按`TAB`，然后`ENTER`。



### 修改附件发送大小限制

看下现在邮件的大小限制：

```bash
sudo postconf message_size_limit
```

<div class="note info">message_size_limit = 20480000</div>

差不多是10M，放大20倍，应该差不多了。

```bash
sudo postconf -e "message_size_limit = 204800000"
```

### 获得&编辑备份脚本

```bash
wget https://raw.githubusercontent.com/iwyang/scripts/master/halo_email_backup.sh
```

#### 创建备份文件夹

<div class="note primary">如果选择将文件备份到临时目录的话，这步可跳过，直接修改脚本即可。我直接跳过了这一步。</div>

```bash
mkdir -p /home/back
```

#### 修改脚本

脚本原来模样：

```js
#!/bin/bash
# 进入到备份文件夹
cd /home/back
#压缩网站数据
tar zcvf web_$(date +"%Y%m%d").tar.gz 网站目录
# 导出数据库到备份文件夹内
mysqldump -uroot -p数据库密码 数据库名称 > web_data_$(date +"%Y%m%d").sql
# 以附件形式发送数据库到指定邮箱
echo "Blog date"|mail -s "Backup$(date +%Y-%m-%d)" -a web_data_$(date +"%Y%m%d").sql 收件人邮箱
# 删除本地3天前的数据
rm -rf web_$(date -d -3day +"%Y%m%d").tar.gz web_data_$(date -d -3day +"%Y%m%d").sql
# 登录FTP
lftp ftp地址 -u ftp用户名,ftp密码 << EOF
# 进入FTP根目录
cd ftp根目录文件夹
# 删除3天前备份文件
mrm web_$(date -d -3day +"%Y%m%d").tar.gz
mrm web_data_$(date -d -3day +"%Y%m%d").sql
# 上传当天备份文件
mput web_$(date +"%Y%m%d").tar.gz
mput web_data_$(date -d -3day +"%Y%m%d").sql
bye
EOF
```

根据实际需求，改成下面模样：

```
vi email.sh
```

```js
#!/bin/bash
cd /tmp
tar zcvf web_$(date +"%Y%m%d").tar.gz /root/.halo
echo "Blog date"|mail -s "Backup$(date +%Y-%m-%d)" -a web_$(date +"%Y%m%d").tar.gz 455343442@qq.com
rm -f web_$(date +"%Y%m%d").tar.gz
```
上面代码中最后的`rm -f web_$(date +"%Y%m%d").tar.gz`，表示删除本地的临时文件。
>**注意**在**Debian**下要讲`-a` 改成 `-A`（如下）

```diff
- echo "Blog date"|mail -s "Backup$(date +%Y-%m-%d)" -a web_$(date +"%Y%m%d").tar.gz 455343442@qq.com
+ echo "Blog date"|mail -s "Backup$(date +%Y-%m-%d)" -A web_$(date +"%Y%m%d").tar.gz 455343442@qq.com
```

#### 设置定时任务

##### 赋予文件执行权限

```bash
chmod +x /root/email.sh
```

运行的时候就输入下面的代码即可：`./email.sh`

##### 设定自动任务

```bash
crontab -e
```

```bash
01 00 * * * /root/email.sh
```

意思是每天凌晨0:01运行这个脚本。

## 备份到Dropbox

### 创建Dropbox应用

首先，需要创建一个Dropbox应用，可以从该网址进行创建：https://www.dropbox.com/developers/apps/create

在这里，应用类型选择`Dropbox API`，数据存储类型选择`App folder`，然后`命名`创建。然后切换到`Permissions`选项卡，勾选相应权限。最后记录下`App key`，`App secret`，下面要用。

![](dropbox_uploader.jpg)

### 下载dropbox_uploader.sh

[dropbox_uploader](https://github.com/andreafabrizi/Dropbox-Uploader/) 是一个第三方Dropbox备份脚本，首先下载脚本：

```bash
curl "https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh" -o dropbox_uploader.sh
```

然后，为该脚本添加执行权限：

```bash
chmod +x dropbox_uploader.sh
```

执行该脚本，绑定APP：

```bash
./dropbox_uploader.sh
```
在终端里输入`App key`，`App secret`，接着会返回一个网址，浏览器打开，复制得到的`token`，最后在终端里完成绑定。

之后可以执行下面的命令测试上传，提示Done就是绑定成功了：

```bash
./dropbox_uploader.sh upload /etc/passwd /backup/passwd.old
```
如果报错`unlink`,先执行命令`rm ~/.dropbox_uploader`，删除相应文件夹，然后删除上面申请的APP。按上面的操作重新申请

APP、重新绑定，一般第二次申请就会成功。

### 编写备份脚本

编写定时备份脚本，取名为`backup.sh`。代码原来模样如下：

```bash
vi backup.sh
```

```js
#!/bin/bash
SCRIPT_DIR="/root" #这个改成你存放刚刚下载下来的dropbox_uploader.sh的文件夹位置
DROPBOX_DIR="/backup" #这个改成你的备份文件想要放在Dropbox下面的文件夹名称，如果不存在，脚本会自动创建
BACKUP_SRC="/home/wwwroot /usr/local/nginx/conf" #这个是你想要备份的本地服务器上的文件，不同的目录用空格分开
BACKUP_DST="/tmp" #这个是你暂时存放备份压缩文件的地方，一般用/tmp即可
MYSQL_SERVER="localhost" #这个是你mysql服务器的地址，一般填这个本地地址即可
MYSQL_USER="mysqluser" #这个是你mysql的用户名名称，比如root或admin之类的
MYSQL_PASS="password" #这个是你mysql用户的密码
# 下面的一般不用改了
NOW=$(date +"%Y.%m.%d")
DESTFILE="$BACKUP_DST/$NOW.tar.gz"
# 备份mysql数据库并和其它备份文件一起压缩成一个文件
mysqldump -u $MYSQL_USER -h $MYSQL_SERVER -p$MYSQL_PASS --all-databases > "$NOW-Databases.sql"
echo "数据库备份完成，打包网站数据中..."
tar cfzP "$DESTFILE" $BACKUP_SRC "$NOW-Databases.sql"
echo "所有数据打包完成，准备上传..."
# 用脚本上传到dropbox
$SCRIPT_DIR/dropbox_uploader.sh upload "$DESTFILE" "$DROPBOX_DIR/$NOW.tar.gz"
if [ $? -eq 0 ];then
     echo "上传完成"
else
     echo "上传失败，重新尝试"
fi
# 删除本地的临时文件
rm -f "$NOW-Databases.sql" "$DESTFILE"
```

根据实际情况改成下面模样：

```js
#!/bin/bash
SCRIPT_DIR="/root" 
DROPBOX_DIR="/backup" 
BACKUP_SRC="/root/.halo" 
BACKUP_DST="/tmp"
NOW=$(date +"%Y.%m.%d")
DESTFILE="$BACKUP_DST/$NOW.tar.gz"
echo "打包网站数据中..."
tar cfzP "$DESTFILE" $BACKUP_SRC
echo "所有数据打包完成，准备上传..."
$SCRIPT_DIR/dropbox_uploader.sh delete "$DROPBOX_DIR"
$SCRIPT_DIR/dropbox_uploader.sh upload "$DESTFILE" "$DROPBOX_DIR/$NOW.tar.gz"
if [ $? -eq 0 ];then
     echo "上传完成"
else
     echo "上传失败，重新尝试"
fi
rm -f "$DESTFILE"
```

**先用`$SCRIPT_DIR/dropbox_uploader.sh delete "$DROPBOX_DIR"`删除`Dropbox`备份文件夹，再上传文件。这样就保证`Dropbox`永远只有一个最新的备份文件，不用手动删除多余的备份文件了**。

---

当然也可以通过脚本设置保留旧数据的时长。如下面一个脚本就是让旧数据在Dropbox保留7天，本地保留10天。（不过觉得没有必要，还是上面的方法简单，下面方法尝试过，老是出现问题，旧数据删除不了，不想折腾了）

```js
#!/bin/bash
 
# 定义需要备份的目录
WEB_DIR=/home/www # 网站数据存放目录
 
# 定义备份存放目录
DROPBOX_DIR=/$(date +%Y-%m-%d) # Dropbox上的备份目录
LOCAL_BAK_DIR=/home/backup # 本地备份文件存放目录
 
# 定义备份文件名称
DBBakName=DB_$(date +%Y%m%d).tar.gz
WebBakName=Web_$(date +%Y%m%d).tar.gz
 
# 定义旧数据名称
Old_DROPBOX_DIR=/$(date -d -7day +%Y-%m-%d)
OldDBBakName=DB_$(date -d -10day +%Y%m%d).tar.gz
OldWebBakName=Web_$(date -d -10day +%Y%m%d).tar.gz
 
cd $LOCAL_BAK_DIR
 
#使用命令导出数据库
mongodump --out $LOCAL_BAK_DIR/mongodb/ --db bastogne
 
#压缩数据库文件合并为一个压缩文件
tar zcf $LOCAL_BAK_DIR/$DBBakName $LOCAL_BAK_DIR/mongodb
rm -rf $LOCAL_BAK_DIR/mongodb
 
#压缩网站数据
cd $WEB_DIR
tar zcf $LOCAL_BAK_DIR/$WebBakName ./*
 
cd ~
#开始上传
./dropbox_uploader.sh upload $LOCAL_BAK_DIR/$DBBakName $DROPBOX_DIR/$DBBakName
./dropbox_uploader.sh upload $LOCAL_BAK_DIR/$WebBakName $DROPBOX_DIR/$WebBakName
 
#删除旧数据
rm -rf $LOCAL_BAK_DIR/$OldDBBakName $LOCAL_BAK_DIR/$OldWebBakName
./dropbox_uploader.sh delete $Old_DROPBOX_DIR/
 
echo -e "Backup Done!"
```

---

### 赋予文件执行权限

```bash
chmod +x backup.sh
```

运行的时候就输入下面的代码即可：`./backup.sh`

### 设置定时任务

```bash
crontab -e
```

```bash
02 00 * * * /root/backup.sh
```

这样，就可以每天凌晨00:02自动备份到Dropbox了。

## 备份到github

### 准备工作

首先当然是在服务器上安装`GIt`，配置`ssh公钥`，并且在`github`上添加服务器`ssh公钥`。具体过程略。

### 初始化仓库

```bash
cd /root/.halo
git init
git remote add origin git@github.com:iwyang/halo.git
git add .
git commit -m "site backup"
git push --force origin master
```

---

注意要删除主题文件夹下的`.git`文件夹，不然的话就无法备份主题了。当然也可以不备份主题，因为主题所有配置选项都在数据库里。如果这样的话，命令要作如下调整：

```bash
git add application.yaml upload/ db/
```

---

### 设置定时任务

#### 编写备份脚本

```bash
cd /root
vi github.sh
```

脚本原来模样：

```js
#!/bin/bash
#进入到网站根目录，记得修改为自己的站点
cd /home/xxx.com
#将数据库导入到该目录，这里以mysql为例，passwd为数据库密码，typecho为数据库名称，typecho.sql为备份的数据库文件
mysqldump -uroot -ppasswd typecho > typecho.sql
git add -A
git commit -m "backsite"
git push -u origin master
```

根据实际情况修改如下：

```js
#!/bin/bash
echo -e "\033[0;32mDeploying updates to github...\033[0m"
cd /root/.halo
git add .	
git commit -m "site backup"
git push --force origin master
```

为了防止服务器里`.git`文件夹过大，脚本可以作如下调整：

```js
#!/bin/bash
echo -e "\033[0;32mDeploying updates to github...\033[0m"
cd /root/.halo
rm -rf .git
git init
git remote add origin git@github.com:iwyang/halo.git
git add .    
git commit -m "site backup"
git push --force origin master
rm -rf .git
```

#### 赋予文件执行权限

```bash
chmod +x /root/github.sh
```

#### 设定自动任务

```bash
crontab -e
```

```js
03 00 * * * /root/github.sh
```

意思是每天凌晨0:03运行这个脚本。

### 还原博客

```bash
git clone git@github.com:iwyang/halo.git .halo
```

 接下来就是配置个 Java 环境，下载个 Halo 运行包，配置域名访问。具体可参考[官方文档](https://halo.run/)。

## 总结

`halo`博客迁移后，最好删除`logs`文件夹下的日志文件。

---

## SCP命令

### 下载文件

从服务器下载文件到本地，在`Git Bash`执行：

```bash
scp root@104.224.191.88:/root/.ssh/mysite ssh
```

意思是将服务器`/root/.ssh`目录下的mysite文件复制到当前路径下`ssh`文件夹下。

### 上传文件

从本地上传文件到服务器，在`Git Bash`执行：

```bash
scp .halo.zip root@137.220.43.191:/root/
```

意思是将当前目录下`.halo.ip`文件上传到服务器`/root/目录下`。

## wordpress相关

### wordpress常用mysql命令

```yaml
# 1.删除数据库
mysqladmin -u root -p drop wordpress
# 2.新建一个空数据库
mysqladmin -u root -p create wordpress
# 3.导入数据
mysql -uroot -p”你的密码” wordpress < 你的数据sql文件
# 4.更新Url
# 4.1.连接数据库
mysql -u root -p
# 4.2. 选择数据库
use wordpress
# 4.3.更新URL
SELECT * FROM wp_options WHERE option_name = 'home';
UPDATE wp_options SET option_value="https://new_url/" WHERE option_name = "home";

SELECT * FROM wp_options WHERE option_name = 'siteurl';
UPDATE wp_options SET option_value="https://new_url/" WHERE option_name = "siteurl";
```

---

### Debian 10 五分钟/一键安装Wordpress

```bash
#Debian8下载脚本
wget http://w3.gubo.org/pubfiles/tylemp/10/tylemp.sh 
#安装稳定版Nginx+PHP+MariaDB
bash tylemp.sh stable
#安装wordpress，www.yourdomain.com即为你的域名
bash tylemp.sh wordpress www.yourdomain.com 
```

命令列表

```bash
bash tylemp.sh system # 优化系统，删除不需要组件，dropbear替代sshd 
bash tylemp.sh exim4 # 更轻量级邮件系统 
bash tylemp.sh mysql # 安装mysql 
bash tylemp.sh nginx # 安装nginx，默认一个进程，可调整
bash tylemp.sh php # 安装php，包含php5-gd，可使用验证码
bash tylemp.sh stable # 安装上面所有，软件是debian官方stable源，版本较旧
bash tylemp.sh wordpress www.yourdomain.com # 一键安装wordpress, 数据库自动配置好。 
bash tylemp.sh vhost www.yourdomain.com # 一键安装静态虚拟主机。
bash tylemp.sh dhost www.yourdomain.com # 一键安装动态虚拟主机，方便直接上传网站程序。
bash tylemp.sh typecho www.yourdomain.com # 安装typecho，提供数据库名，密码等自主添加完成安装
bash tylemp.sh phpmyadmin www.yourdomain.com # 一键安装phpmyadmin 数据库管理软件，用http://www.yourdomain.com/phpMyAdmin访问 
bash tylemp.sh addnginx 2 #调整nginx进程，这里2表示调整后的进程数，请根据vps配置（cpu核心数）更改
bash tylemp.sh sshport 22022 #更改ssh端口号22022，建议更改10000以上端口。重启后生效。
bash tylemp.sh rainloop www.yourdomain.com  # 增加Gmail的web客户端一键安装
bash tylemp.sh carbon www.yourdomain.com  # 增加Carbon Forum的一键安装
```

### 修改 WordPress 上传文件大小限制

1.查找php.ini配置文件

```
find / -name "php.ini"
```

会出现两个结果，修改类似`/etc/php/7.3/fpm/php.ini`



2.修改 `php.ini`

```
vi /etc/php/7.3/fpm/php.ini
```

在其中搜索并修改以下配置：

```bash
upload_max_filesize = 512M
post_max_size = 512M
max_execution_time = 3000
```

这里配置上限为 512 MB，同时增加了最大处理时间。



3.修改 nginx.conf

```
vi /etc/nginx/conf.d/blog.bore.vip.conf
```

在 `http` 或 `server` 配置下添加

```
client_max_body_size 512M;
```

这里配置上限为 512 MB。



4.重启nginx和php

```
service nginx restart
service php7.3-fpm restart
```

## `nginx`: command not found 解决方案

只需要输入`source /etc/profile` ，让配置文件重新生效一下即可。

## 参考链接

+ [1.Linux 每日自动备份到FTP及数据库通过邮箱发送方法](https://www.moerats.com/archives/69/)
+ [2.fetchmail: SMTP error: 552 5.3.4 Message size exceeds fixed limit](http://blog.sina.com.cn/s/blog_7edf8b9f0100to4p.html)
+ [3.如何将服务器上的网站数据定时自动备份到Dropbox](http://sufaming.com/?p=189)
+ [4.Linux 定时备份服务器/网站数据到Github私人仓库](https://www.moerats.com/archives/858/)
+ [5.MySQL 教程](https://www.runoob.com/mysql/mysql-tutorial.html)
+ [6.Changing the WordPress site URL using the MySQL command line](https://precisionsec.com/changing-the-wordpress-site-url-using-the-mysql-command-line/)
+ [7.CentOs8系统安装mailx发邮件](https://blog.csdn.net/jia12216/article/details/106098267)
+ [8.Impossible to unlink](https://github.com/andreafabrizi/Dropbox-Uploader/issues/459)
+ [9.如何在Debian 9上安装和配置Postfix作为仅发送SMTP服务](https://cloud.tencent.com/developer/article/1363216)
+ [10.Debian LNMP/LEMP/WordPress一键脚本](https://www.gubo.org/debian-lemp-script/)
+ [11.修改 WordPress 上传文件大小限制](https://blog.nex3z.com/2020/07/14/%E4%BF%AE%E6%94%B9-wordpress-%E4%B8%8A%E4%BC%A0%E6%96%87%E4%BB%B6%E5%A4%A7%E5%B0%8F%E9%99%90%E5%88%B6/)