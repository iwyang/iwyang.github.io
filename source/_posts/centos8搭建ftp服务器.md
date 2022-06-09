---
title: centos8搭建ftp服务器
categories:
  - 技术
tags:
  - 服务器
abbrlink: 9c35b5ba
date: 2020-06-06 11:34:25
---

## 安装vsftpd

```bash
sudo yum install vsftpd -y
```

安装软件包后，启动vsftpd，并使其能够在引导时自动启动：

```bash
sudo systemctl start vsftpd
sudo systemctl enable vsftpd
```

## 配置vsftpd

```bash
vi /etc/vsftpd/vsftpd.conf
```

要仅允许某些用户登录FTP服务器，需要在`userlist_enable=YES`下面，加上：

```bash
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO
```

启用此选项后，您需要通过将用户名添加到`/etc/vsftpd/user_list`文件（每行一个用户）来明确指定哪些用户可以登录。

完成编辑后，vsftpd配置文件应如下所示：

```bash
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
#anon_upload_enable=YES
#anon_mkdir_write_enable=YES
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
#chown_uploads=YES
#chown_username=whoever
#xferlog_file=/var/log/xferlog
xferlog_std_format=YES
#idle_session_timeout=600
#data_connection_timeout=120
#nopriv_user=ftpsecure
#async_abor_enable=YES
#ascii_upload_enable=YES
#ascii_download_enable=YES
#ftpd_banner=Welcome to blah FTP service.
#deny_email_enable=YES
#banned_email_file=/etc/vsftpd/banned_emails
#chroot_local_user=YES
#chroot_list_enable=YES
#chroot_list_file=/etc/vsftpd/chroot_list
#ls_recurse_enable=YES
listen=NO
listen_ipv6=YES
pam_service_name=vsftpd
userlist_enable=YES
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO
```

## 重启vsftpd服务

保存文件并重新启动vsftpd服务，以使更改生效：

```bash
sudo systemctl restart vsftpd
```

## 设置防火墙

最直接方法关闭防火墙。

## 创建FTP用户

创建一个新用户，名为admin:

```bash
sudo adduser admin
sudo passwd admin
```

将用户添加到允许的FTP用户列表中：

```bash
echo "admin" | sudo tee -a /etc/vsftpd/user_list
```

设置正确的权限：

```bash
sudo chmod 750 /home/admin
sudo chown -R admin: /home/admin
```

如果遇到文件无法下载，可能需要更改文件所属用户组，例如：

```bash
chown admin 文件名
```

## 修改vsftpd的默认根目录

```bash
vi /etc/vsftpd/vsftpd.conf
```

加入如下几行：

```bash
local_root=/var/www/html
anon_root=/var/www/html
```

**注**：`local_root` 针对系统用户；`anon_root` 针对匿名用户，如果禁止匿名登录，不用加此项。网上说还要加上`chroot_local_user=YES`，加上此项后根本无法登陆。

重新启动服务：

```bash
sudo systemctl restart vsftpd
```

任何一个用户ftp登录到这个服务器上都会chroot到/var/www/html目录下。

## 参考链接

+ [1.如何在CentOS 7上使用VSFTPD设置FTP服务器](https://www.myfreax.com/how-to-setup-ftp-server-with-vsftpd-on-centos-7/)

+ [2.基于 CentOS 搭建 FTP 文件服务](https://blog.csdn.net/zyw_java/article/details/75212608)

