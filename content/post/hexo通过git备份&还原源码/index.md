---
title: hexo通过git备份&还原源码
categories:
  - 技术
tags:
  - hexo
slug: c5bb486d
date: 2020-05-10 15:09:25
cover: false
---

 上回做过[hexo迁移笔记](https://bore.vip/archives/a0c508c1.html)，基本思路是利用U盘拷贝，或者网盘自动同步来备份，这回是通过git备份还原hexo源码。

> Hexo博客存在一个问题：我们仅仅将博客的静态页面文件部署到了github远程仓库中，而我们的站点源文件仍在本地存储。如果存储站点源文件的电脑系统崩溃了，或者我们换了其他电脑，我们便无法实时更新博客了。

<!-- more -->

> 如果选择重新搭建站点，不仅过程繁琐，而且还需要大量时间安装依赖、主题配置、博客优化，极其麻烦。所以我们需要将站点必要文件也部署到远程仓库中。然而github的私有仓库是要收费的，如果用免费仓库，暴露hexo源码，尤其是配置文件是很不安全的，因为配置文件中可能含有你的隐私信息，比如各种秘钥等。所以有一个私人仓库是很有利的。你可以通过购买服务器搭建自己的git私人服务器并备份hexo源码。你也可以在coding等这样提供私人仓库的服务商进行hexo源码备份。
> 我们采取的远程仓库部署策略是：使用coding的私人仓库，一个仓库两个分支。仓库即[[yourname.coding.me](http://yourname.coding.me)]，一个分支[master]用于托管演示页面，一个分支[backup]用于备份Hexo博客站点的必要文件。

## 备份

多机同步更新的前提：backup分支（也可以是其他名称的分支或者新的仓库）

Hexo博客站点的必要文件：

```yaml
.
├── scaffolds    # 文章模板
├── source       # 用户源文件：页面，文章markdown文件
├── themes       # 主题
├── .gitignore   # git忽略文件信息
├── _config.yml  # 站点配置文件
├── package.json # 已安装插件映射表，下次只需npm install即直接安装表中的插件
├── package-lock.json

```

使git上传远程git服务器（这里是coding）时可忽略不必要的文件，做法是编辑**站点根目录**下的`.gitignore`文件，复制粘贴一下内容到`.gitignore`文件中。

```yaml
.DS_Store
Thumbs.db
db.json
*.log
node_modules/
public/
.deploy*/
```

### 删除必要文件

删除`themes/你的主题`中的`.git`，`.github`，`.gitignore`等git仓库文件，只保留站点根目录下的`.gitignore`。

### 利用脚本备份_posts文件夹到dropbox

问[grok](https://grok.com/)：windows 下，在e盘新建sh脚本，将E:\blog\source_posts 文件夹复制到E:\Dropbox\资料\文档\个人，先删除E:\Dropbox\资料\文档\个人 里面的_posts 文件夹，再复制。

在博客根目录新建`deploy.sh`

```
#!/bin/bash
echo -e "\033[0;32mDeploying updates to vps...\033[0m"
git add .	
git commit -m "site backup"
git push --force origin backup
node link.js
hexo clean
hexo g -d

#!/usr/bin/env bash

# 一句话暴力解决
rm -rf "E:/Dropbox/资料/文档/个人/_posts" 2>/dev/null
cp -r "E:/blog/source/_posts" "E:/Dropbox/资料/文档/个人/"

echo "完成！"
```

### hexo源码备份

#### 备份到gitee backup分支

2020.7.8 现在没用这种备份方法

```yaml
git init                  
git checkout -b backup  	 
git add .				 	  
git commit -m "提交说明" 	  
git remote add origin git@gitee.com:iwyang/iwyang.git  
git push --force origin backup	 
```

#### 备份到github master分支

2020.7.8 目前采用这种备份方法（**一步一步的执行**）

```bash
git init
git remote add origin git@github.com:iwyang/hexo.git
git add .
git commit -m "site backup"
git push --force origin master
```

---

**PS**: 如果执行第二步`git checkout -b backup`后，提示`fatal: A branch named 'backup' already exists.`，则执行以下操作

```bash
git remote rm origin
git checkout -b backup
```

实在不行先执行下面命令：

```bash
git branch -D backup #删除分支:必须切换到其他的分之下才可操作
```

---

#### 备份到github backup分支

2022.2.4 目前采用这种备份方法（**一步一步的执行**）

```bash
git init                  
git checkout -b backup  	 			 	  	  
git remote add origin git@github.com:iwyang/iwyang.github.io.git  
git add .	
git commit -m "site backup" 
git push --force origin backup
```

如果出现问题参考上面解决方法。

### 部署脚本

根目录新建`deploy.sh`：

```bash
#!/bin/bash
echo -e "\033[0;32mDeploying updates to gitee...\033[0m"
git add .	
git commit -m "site backup"
git push --force origin backup
hexo clean
hexo g -d
```

## 还原

### 还原前提

安装Git，nodejs，配置环境变量。

### hexo源码还原

```bash
$ git clone git@github.com:iwyang/hexo.git	# 克隆master分支到本地，私有仓库需要输入用户名和密码
$ cd hexo-master		     # 进入hexo-master文件夹
$ npm install -g hexo-cli	 # 全局安装hexo
$ npm install				 # 安装所有依赖(hexo以及插件的依赖)，根据package.json自动安装之前安装过的插件
```

### Git配置用户信息（新系统环境下）

在Git bash中输入：

1.设置用户名

```bash
git config --global user.name '这里填写自己的用户名'
```

2.设置用户名邮箱

```bash
git config --global user.email '这里填写自己的用户邮箱'
```

3.查看配置信息

```bash
git config --list
```

注意：该设置在GitHub仓库主页显示谁提交了该文件，注意这里的 - 有两个！

### 配置网络协议

SSH协议，长期部署推荐SSH，一劳永逸。

1.SSH秘钥：

```bash
$ ssh-keygen -t rsa -C "youremail@example.com"		# 生成rsa秘钥
$ cd ~/.ssh		 		# 进入虚拟目录ssh文件中
$ cat id_rsa.pub		# 显示id_rsa.pub文件内容
```

2.复制秘钥至github/coding->用户setting->SSH keys，New SSH Key

3.验证是否添加成功

```bash
$ ssh -T git@github.com  # 验证github是否添加成功
$ ssh -T git@git.coding.net  # 验证coding是否添加成功
```

4.编辑**站点配置文件**`_config.yml`

```bash
deploy:
    type: git
    repo: 
        github: git@github.com:yourname/yourname.github.io.git 
        coding: git@git.coding.net:yourname/yourname.coding.me.git 
    branch: master
```

### 及时更新hexo源码到coding

发表文章、更新文章、修改源码，要及时更新hexo源码到coding。

```bash
git add .
git commit -m "更新"
git push --force origin master
```

2020.7.8 把这段代码放在自动部署脚本里即可。

## 参考链接

[1.通过git备份还原hexo源码](https://www.qcmoke.site/blog/hexo_backup.html)

[2.git报错：'fatal:remote origin already exists'怎么处理](https://www.cnblogs.com/leaf930814/p/6664706.html)

[3.git 常用命令](https://blog.csdn.net/www1056481167/article/details/80046132)