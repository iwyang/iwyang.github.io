---
title: Hexo迁移笔记
categories:
  - 技术
tags:
  - hexo
abbrlink: b7fa73bc
date: 2020-04-27 16:27:11
cover: false
---
### 1. 更换电脑、重装系统  

```bash
git clone -b backup git@github.com:iwyang/iwyang.github.io.git blog 
```

```
cd blog
npm install -g hexo-cli	    
npm install	
hexo s
```

最后将服务器原来的SSH 公钥先删除，再上传新的SSH 公钥。具体操作如下:

服务器上输入：

```
su git
cd ~/.ssh
rm -rf authorized_keys
```

本地Git Bash里输入：

```
ssh-copy-id -i ~/.ssh/id_rsa.pub git@服务器ip地址
```

如果在git bash中输入ssh git@服务器的IP地址,能够远程登录的话，则表示设置成功了。如若还是要输入密码，就修改目录权限：

```
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

登录成功会提示：

```powershell
$ ssh git@104.224.191.88
Last login: Sat Feb 26 02:33:30 2022 from 171.81.158.144
[git@special-beep-1 ~]$
```

###  2. 更换服务器

最好首先克隆`github`上的源码。

```powershell
git config --global user.name "iwyang"
git config --global user.email "455343442@qq.com"
git clone -b backup git@github.com:iwyang/iwyang.github.io.git blog
ssh-copy-id -i ~/.ssh/id_rsa.pub git@104.224.191.88
ssh git@104.224.191.88
git clone git@github.com:iwyang/pic.git pic
```

**可结合[hexo通过git备份&还原源码](https://bore.vip/archives/hexo-backup/)这篇文章来看**。

参考：

+ [ubuntu 搭建hexo-服务器操作部分](https://bore.vip/archives/45284.html#服务器%E6%93%8D%E4%BD%9C)
+ [centos8 搭建hexo-服务器操作部分](https://bore.vip/archives/cb52221e.html#服务器%E6%93%8D%E4%BD%9C)

