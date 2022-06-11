---
title: Debian使用备忘
categories:
  - 技术
tags:
  - linux
abbrlink: 9eb70758
date: 2022-05-29 01:12:45
cover: 
---

由于一些原因，之前服务器上用的Centos换成了Debian。Debian虽然和Centos大同小异，但是还是有些东西要记一下。

## putty保存登录账号和密码
1. 创建一个桌面快捷方式。

2. 进入快捷方式属性，修改目标，在后面加上 -ssh -l 用户名 -pw 密码 -i session标识 -P 端口号 IP地址。例如 "C:\Program Files\PuTTY\putty.exe" -ssh -l root -pw 123456 -i "yuanchengserver1" -P 22 142.16.187.129
```
E:\软件\putty.exe -ssh -l root -pw password -i "yansvps" -P 22 ip
```
3. 然后，通过快捷方式就可以直接登录了~

PS：`putty`没有[FinalShell](https://www.hostbuf.com/)好用。

## `vi`无法正常使用
1. 先安装`vim`：
```bash
apt install vim -y
```
2. 修改`vimrc.tiny`
`vi /etc/vim/vimrc.tiny` 将其中的语句 `set compatible` 修改为 `set nocompatible` ，非兼容模式下可以解决方向键变ABCD的问题。

在刚才那句话后面再加一句 `set backspace=2` 来解决退格键无法使用的问题。
```bash
vi /etc/vim/vimrc.tiny
set nocompatible
set backspace=2
```
3. 卸载`vim`
vim颜色太花眼了，所以最后把它卸载：
```bash
apt remove vim -y
```
## Debian安装vsftpd
1. 安装命令：
```bash
sudo apt install vsftpd -y
```
2. 安装软件包后，启动vsftpd，并使其能够在引导时自动启动：
```bash
sudo systemctl start vsftpd
sudo systemctl enable vsftpd
```
3. 编辑`vsftpd.conf`
```bash
vi /etc/vsftpd.conf
```
去掉`write_enable=YES`前面的注释，使用户可以上传文件。

4. 设置允许root登录
```bash
vi /etc/ftpusers
```
文件中的root前加`#`

5. 重启vsftpd服务
```bash
sudo systemctl restart vsftpd
```
6. 解决Nginx出现403 forbidden
```bash
chmod -R 777 /data/www/
```
7. 限制用户登录（未启用）

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

## Debian 9上安装和配置Postfix邮件
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

3. 配置Postfix
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
4. 重启Postfix。
```bash
sudo systemctl restart postfix
```
5. 测试SMTP服务器
```bash
echo "This is the body of the email" | mail -s "This is the subject line" your_email_address
```
6. debian 彻底删除posfix 然后重新安装

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
## 参考链接
+ [1.解决 Debian 下使用 vi 时方向键乱码，退格键不能使用的问题](https://www.uskvm.com/p/32.html)
+ [2.Debian安装vsftpd](https://shixiongfei.com/debian-vsftpd.html)
+ [3.Debian下vsftpd设置允许root登录分析](https://blog.fish2bird.com/?p=706)
+ [4.putty保存登录账号和密码](https://zhuanlan.zhihu.com/p/83730878)
+ [5.如何在Debian 9上使用VSFTPD设置FTP服务器](https://www.myfreax.com/how-to-setup-ftp-server-with-vsftpd-on-debian-9/)