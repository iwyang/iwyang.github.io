---
title: hugo利用Github Actions自动构建博客
categories:
  - 技术
tags:
  - hugo
  - github
abbrlink: 23eeae2f
date: 2020-07-06 09:19:19
cover: false
---

## 初始化 GitHub 仓库

Github上新建一个名为`iwyang.github.io`的仓库。

## 配置`ACTIONS_DEPLOY_KEY`

### 生成公钥

Windows 上安装 [Git for Windows](https://git-for-windows.github.io/) 之后在开始菜单里打开 Git Bash 输入：

```bash
git config --global user.name "你的用户名"
git config --global user.email "你的电子邮箱"
```

```bash
cd ~
mkdir .ssh
cd .ssh
ssh-keygen -t rsa
```

在系统当前用户文件夹下生成了私钥 `id_rsa` 和公钥 `id_rsa.pub`。

### 上传id_rsa.pub

点击博客仓库的Settings->Deploy keys->add deploy key，Title填写`ACTIONS_DEPLOY_KEY`，Key填写`id_rsa.pub`文件的内容。

### 上传id_rsa

点击博客仓库的Settings->Secrets->Add a new secret，Name填写`ACTIONS_DEPLOY_KEY`，Value填写`id_rsa`文件的内容。

## 利用`FTP-Deploy-Action`上传文件

这里在`Github actions`里利用`FTP-Deploy-Action`上传文件到服务器。项目地址：[SamKirkland](https://github.com/SamKirkland)/[FTP-Deploy-Action](https://github.com/SamKirkland/FTP-Deploy-Action)

首先是搭建ftp服务器。

### 安装vsftpd

```bash
sudo yum install vsftpd -y
```

安装软件包后，启动vsftpd，并使其能够在引导时自动启动：

```bash
sudo systemctl start vsftpd
sudo systemctl enable vsftpd
```

### 配置vsftpd

```bash
vi /etc/vsftpd/vsftpd.conf
```

在`userlist_enable=YES`下面，加上：

```bash
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO
```

### 创建FTP用户

+ 创建一个新用户，名为git:

```bash
sudo adduser git
sudo passwd git
```

+ 将用户添加到允许的FTP用户列表中：

```bash
echo "git" | sudo tee -a /etc/vsftpd/user_list
```

+ 设置正确的权限

为了使ftp用户可以上传网站文件到相应目录：

```bash
sudo chmod 755 /var/www/hexo
sudo chown -R git: /var/www/hexo
```

+ 重启vsftpd服务。

保存文件并重新启动vsftpd服务，以使更改生效：

```bash
sudo systemctl restart vsftpd
```

## 配置`FTP_MIRROR_PASSWORD`

点击博客仓库的Settings->Secrets->Add a new secret，Name填写`FTP_MIRROR_PASSWORD`，Value填写用户密码。

## 配置 Github actions

在博客根目录新建`.github/workflows/gh_pages.yml`文件。代码（**不添加缓存**）如下：最好使用下面添加了缓存的。

```yaml
name: GitHub Page Deploy

on:
  push:
    branches:
      - develop
jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout master
        uses: actions/checkout@v2.3.4
        with:
          submodules: true  # Fetch Hugo themes (true OR recursive)
          fetch-depth: 0    # Fetch all history for .GitInfo and .Lastmod
      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2.5.0
        with:
          hugo-version: 'latest'
          extended: true

      - name: Build Hugo
        run: hugo --minify

      - name: Deploy Hugo to gh-pages
        uses: peaceiris/actions-gh-pages@v3.8.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          PUBLISH_BRANCH: master
          PUBLISH_DIR: ./public
        # cname:
        
      - name: Deploy Hugo to Server
        uses: SamKirkland/FTP-Deploy-Action@4.1.0
        with:
          server: 104.224.191.88
          username: git
          password: ${{ secrets.FTP_MIRROR_PASSWORD }}
          local-dir: ./public/
          server-dir: /var/www/hexo/
```

**添加缓存：**

```yaml
name: GitHub Page Deploy

on:
  push:
    branches:
      - develop
jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout master
        uses: actions/checkout@v2.3.4
        with:
          submodules: true  # Fetch Hugo themes (true OR recursive)
          fetch-depth: 0    # Fetch all history for .GitInfo and .Lastmod
      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2.5.0
        with:
          hugo-version: 'latest'
          extended: true
          
      - name: Cache resources # 缓存 resource 文件加快生成速度
        uses: actions/cache@v2
        with:
          path: resources
         # 检查照片文件变化
          key: ${{ runner.os }}-hugocache-${{ hashFiles('content/**/*') }}
          restore-keys: ${{ runner.os }}-hugocache-

      - name: Build Hugo
        run: hugo --minify --gc

      - name: Deploy Hugo to gh-pages
        uses: peaceiris/actions-gh-pages@v3.8.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          PUBLISH_BRANCH: master
          PUBLISH_DIR: ./public
        # cname:
        
      - name: Deploy Hugo to Server
        uses: SamKirkland/FTP-Deploy-Action@4.1.0
        with:
          server: 104.224.191.88
          username: git
          password: ${{ secrets.FTP_MIRROR_PASSWORD }}
          local-dir: ./public/
          server-dir: /var/www/hexo/
```

**第三方：**

```yaml
name: GitHub Page

on:
    push:
        branches:
            - master # master 更新触发

jobs:
    deploy:
        runs-on: ubuntu-18.04
        steps:
            - uses: actions/checkout@v2
              with:
                  submodules: true # clone submodules
                  fetch-depth: 0 # 克隆所有历史信息

            - name: Setup Hugo
              uses: peaceiris/actions-hugo@v2
              with:
                  hugo-version: "0.87.0" # Hugo 版本
                  extended: true # hugo插件版 Stack主题 必须启用

            - name: Cache resources # 缓存 resource 文件加快生成速度
              uses: actions/cache@v2
              with:
                  path: resources
                  # 检查照片文件变化
                  key: ${{ runner.os }}-hugocache-${{ hashFiles('content/**/*') }}
                  restore-keys: ${{ runner.os }}-hugocache-

            - name: Build # 生成网页 删除无用 resource 文件 削减空行
              run: hugo --minify --gc

            - name: Deploy # 部署到 GitHub Page
              uses: peaceiris/actions-gh-pages@v3
              with:
                  # 如果在同一个仓库下使用请使用 github_token 并注释 deploy_key
                  # github_token: ${{ secrets.GITHUB_TOKEN }}
                  deploy_key: ${{ secrets.ACTIONS_DEPLOY_KEY }}

                  # 如果在同一个仓库请注释
                  external_repository: # 你的 GitHub page 仓库 example/example.github.io

                  publish_dir: ./public
                  user_name: "github-actions[bot]"
                  user_email: "github-actions[bot]@users.noreply.github.com"
                  full_commit_message: Deploy from ${{ github.repository }}@${{ github.sha }} 🚀
```

### 提交源码

初始化git，新建并切换到`develop`分支，将源码提交到`develop`分支。稍等片刻，github action会自动部署blog到`master`分支。

```bash
git init
git checkout -b develop
git remote add origin git@github.com:iwyang/iwyang.github.io.git
git add .
git commit -m "备份源码"
git push --force origin develop
```

 ### 最终部署脚本

```bash
#!/bin/bash

echo -e "\033[0;32mDeploying updates to gitee...\033[0m"

# backup
git config --global core.autocrlf false
git add .
git commit -m "site backup"
git push origin develop --force
```

## 本地操作

```bash
git clone -b develop git@github.com:iwyang/iwyang.github.io.git blog --recursive
```
因为使用`Submodule`管理主题，所以最后要加上 `--recursive`，因为使用 git clone 命令默认不会拉取项目中的子模块，你会发现主题文件是空的。（另外一种方法：`git submodule init && git submodule update`）

### 同步更新源文件

```bash
git pull
```

### 同步主题文件

```bash
git submodule update --remote
```

运行此命令后， Git 将会自动进入子模块然后抓取并更新，更新后重新提交一遍，子模块新的跟踪信息便也会记录到仓库中。这样就保证仓库主题是最新的。

## 服务器通过git拉取更新

2021.8.15 已经不用此方法，现在直接在`Github actions`利用`FTP-Deploy-Action`上传文件到服务器。

### 克隆仓库

```bash
rm -rf /var/www/hexo
git clone git@github.com:iwyang/iwyang.github.io.git /var/www/hexo
```

### 出现问题

执行上一步可能会出现问题：` Permission denied (publickey). Could not read from remote repository`。

解决方法：

#### 服务器生成ssh key

```bash
yum install rsync -y
ssh-keygen -t rsa -C "455343442@qq.com"
```

一路回车即可，会生成你的ssh key。然后再终端下执行命令：

```bash
ssh -v git@github.com
```

这时会报错，最后两句是：

```bash
No more authentication methods to try.  
　　Permission denied (publickey).
```

在终端再执行以下命令：

```bash
ssh-agent -s 
```

接着在执行:

```bash
ssh-add ~/.ssh/id_rsa
```

出现问题：`Could not open a connection to your authentication agent.`

解决方法：使用：`ssh-agent bash` 命令，然后再次使用`ssh-add ~/.ssh/id_rsa_name`这个命令就没问题了。(**注意**：Identity added: ...这是ssh key文件路径的信息，如`/.ssh/id_rsa`)

#### 配置github

打开你刚刚生成的`id_rsa.pub`，将里面的内容复制，进入你的github账号，在settings下，SSH and GPG keys下new SSH key，然后将id_rsa.pub里的内容复制到Key中，完成后Add SSH Key。

#### 验证Key

```bash
ssh -T git@github.com 
```

### 设置crontab定时任务：

```bash
crontab -e
*/5 * * * * git -C /var/www/hexo pull
```

这样只要提交源码给github，`github action`就会帮你部署博客到`github page`，服务器通过`git pull`定时拉取更新。换台电脑不用再搭建环境，直接在gtihub新建或者修改文章，剩下的工作就交给`github action`。注意回本地电脑先`git pull`拉取更新，再提交源码。

**注意：好像先要从源码仓库clone一份源码到本地，才能利用`git pull`拉取github已有的更新。只有先拉取github已有的更新，再在本地提交源码，github上的更新才不会被删除**。


## 附：使用Git Submodule管理Hugo主题

+ 如果克隆库的时候要初始化子模块，请加上 `--recursive` 参数，如：

```bash
git clone -b develop git@github.com:iwyang/iwyang.github.io.git blog --recursive
```

+ 如果已经克隆了主库但没初始化子模块，则用：

```bash
git submodule update --init --recursive
```

+ 如果已经克隆并初始化子模块，而需要从子模块的源更新这个子模块，则：

```bash
git submodule update --recursive --remote
```

更新之后主库的 git 差异中会显示新的 SHA 码，把这个差异选中提交即可。

---

+ 其他命令：在主仓库更新所有子模块：`git submodule foreach git pull origin master`

## 参考链接

+ [1.使用Github Actions自动编译部署基于hugo的博客](https://yanlong.me/post/deploy-blog-use-github-actions/)
+ [2.用 Hugo 自动构建 搭建 GitHub Pages](https://juejin.im/post/5e0d9f61f265da5d0d435a24)
+ [3.使用 GitHub Action 自动部署博客到远程服务器](https://blog.lunawen.com/posts/20200628-luna-tech-github-action-blog-autodeployment/)
+ [4.使用 GitHub Actions 实现博客自动化部署](https://frostming.com/2020/04-26/github-actions-deploy)
+ [5.解决git@github.com: Permission denied (publickey). Could not read from remote repository](https://blog.csdn.net/ywl470812087/article/details/104459288)
+ [6.GIT 子模块](https://yihui.org/cn/2017/03/git-submodule/)
+ [7.子模块](https://zj-git-guide.readthedocs.io/zh_CN/stable/basic/%E5%AD%90%E6%A8%A1%E5%9D%97.html)
+ [8.Stack主题 + GitHub Action](https://blog.zhixuan.dev/posts/ce103e3b/)

