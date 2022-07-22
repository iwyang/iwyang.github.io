---
title: Debian使用备忘
categories:
  - 技术
tags:
  - linux
abbrlink: 9eb70758
date: 2022-05-29 01:12:45
cover: false
---

由于一些原因，之前服务器上用的Centos换成了Debian。Debian虽然和Centos大同小异，但是还是有些东西要记一下。

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
echo "admin" | sudo tee -a /etc/vsftpd/user_list
```

（5）关闭防火墙

```bash
systemctl stop firewalld.service
systemctl disable firewalld.service 
```

（6）重启 vsftpd 服务

保存文件并重新启动 vsftpd 服务，以使更改生效：

```
sudo systemctl restart vsftpd
```

---

4.设置允许root登录

```bash
vi /etc/ftpusers
```
文件中的root前加`#`

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