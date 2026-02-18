---
title: Hexo迁移笔记
categories:
  - 技术
tags:
  - hexo
slug: b7fa73bc
date: 2020-04-27 16:27:11
cover: false
---
### 1. 更换电脑、重装系统        

首先安装安装 Git 和 Node.js  ，然后配置好SSH 公钥，将`id_rsa.pub`上传到博客仓库的 Settings->Deploy keys->add deploy key。

如果提示port 22问题或速度过慢，参考 [port22](/archives/2284a148/?highlight=port)

**用https克隆，不要用ssh协议克隆，否则即使daili了速度还是很慢。**

```bash
git clone -b backup https://github.com/iwyang/iwyang.github.io blog 
```


```
cd blog
npm install -g hexo-cli	    
npm install	
hexo s
```

最后将服务器原来的SSH 公钥先删除，再上传新的SSH 公钥。具体操作如下:

服务器上输入（一步一步复制粘贴）：

```
su git
cd ~/.ssh
touch authorized_keys
vi authorized_keys
```

现在要打开本地的 `Git Bash`，输入 `vi ~/.ssh/id_rsa.pub`，把里面的内容复制下来粘贴到上面打开的文件里。

---

PS：**或者**先删除再创建粘贴（还是一步一步复制粘贴）：

```
su git
rm -rf .ssh
mkdir .ssh && cd .ssh
touch authorized_keys
vi authorized_keys
```

---

接着把 ssh 目录设置为只有属主有读、写、执行权限。代码如下：

```bash
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

测试一下，如果在 Git Bash 中输入 `ssh git@服务器的IP地址` 能够远程登录的话，则表示设置成功了。

ps: 如果配置完成还是提示要输入密码，可以使用 `ssh-copy-id`，在本地打开 Git Bash 输入：

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub git@服务器ip地址
```

最终登录成功会提示：

```bash
$ ssh git@142.171.177.173
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

