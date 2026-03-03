---
title: GitHub Actions利用FTP&&rsync自动部署hugo-hexo到Centos 8
categories:
  - 技术
tags:
  - linux
  - github
slug: c7ccd27d
date: 2021-08-15 08:39:34
cover: false
---

## rsync同步

这是一份**没有任何遗漏、从零开始**的终极部署指南。为了彻底解决你之前遇到的权限（Permission denied）和命令缺失（rsync not found）问题，请严格按照这 5 个阶段操作。

我们采用**“重置一切”**的策略，确保环境绝对干净。

---

### 阶段一：服务器 (VPS) 准备

**场景**：你在 VPS 的终端里操作。
**目标**：安装必要软件，建立网站目录，清理旧的 SSH 配置。

1. **登录服务器**：
使用你现有的方式（密码或控制台）登录到 `142.171.177.173`。
2. **安装 Rsync (修复 code 12 报错)**：
这是之前报错的核心原因，必须安装。
```bash
# 如果是 Debian/Ubuntu:
sudo apt-get update && sudo apt-get install rsync -y

# 如果是 CentOS/RHEL:
sudo yum install rsync -y

```


*验证*：输入 `rsync --version`，看到版本号即成功。
3. **创建网站存放目录**：
确保 GitHub 机器人有地方放文件。
```bash
# 创建目录
sudo mkdir -p /var/www/blog

# 将目录所有权交给 admin 用户 (至关重要！)
sudo chown -R admin:admin /var/www/blog

# 设置目录权限
sudo chmod -R 755 /var/www/blog

```


4. **初始化 SSH 目录 (修复权限报错)**：
即使目录已存在，也请运行一遍以修正权限。
```bash
# 确保在用户主目录下
cd /home/admin

# 创建 .ssh 目录
mkdir -p .ssh

# 锁死目录权限 (只有 admin 能进)
chmod 700 .ssh

# 确保所有权正确
sudo chown -R admin:admin .ssh

```



---

### 阶段二：生成“专用钥匙” (本地电脑)

**场景**：在你自己的电脑终端（Git Bash / Terminal）里操作。
**目标**：制作一对全新的钥匙，一把给 GitHub，一把给 VPS。

1. **生成密钥**：
```bash
# 不要设置密码，一路回车
ssh-keygen -t ed25519 -C "github-actions-deploy" -f deploy_key
```


2. **查看并复制公钥 (给 VPS 用)**：
```bash
cat deploy_key.pub
```


👉 **动作**：复制输出的那一整行内容（以 `ssh-ed25519` 开头）。
3. **查看并复制私钥 (给 GitHub 用)**：
```bash
cat deploy_key
```


👉 **动作**：复制**全部内容**，包括 `-----BEGIN...` 和 `-----END...`。

---

### 阶段三：安装“锁” (VPS)

**场景**：回到 VPS 的终端里操作。
**目标**：把阶段二里复制的**公钥**，写入服务器白名单。

1. **写入公钥**：
请将下面的 `你的公钥内容` 替换为你刚才复制的那一长串字符。
```bash
echo "你的公钥内容" > /home/admin/.ssh/authorized_keys
```


*例如：* `echo "ssh-ed25519 AAAAC3Nz... github-actions-deploy" > /home/admin/.ssh/authorized_keys`
2. **设置文件权限 (至关重要)**：
SSH 规定，如果这个文件权限太开放，它会拒绝登录。
```bash
# 只能你自己读写
chmod 600 /home/admin/.ssh/authorized_keys

# 再次确认所有权
sudo chown admin:admin /home/admin/.ssh/authorized_keys
```


3. **最终检查**：
```bash
cat /home/admin/.ssh/authorized_keys
```


*确认看到的是你的新公钥。*

---

### 阶段四：配置“持钥人” (GitHub)

**场景**：在 GitHub 网页上操作。
**目标**：把阶段二里复制的**私钥**，交给 GitHub 机器人。

1. 打开你的 GitHub 仓库页面。
2. 点击 **Settings** -> **Secrets and variables** -> **Actions**。
3. 找到 `SERVER_SSH_KEY` (如果有旧的，直接删除新建，或者点击 Update)。
4. **粘贴阶段二里复制的私钥内容**。
5. 点击 **Add secret**。

---

### 阶段五：配置自动化脚本 (本地代码)

**场景**：在 VS Code 或本地编辑器里操作。
**目标**：告诉 GitHub 怎么用这把钥匙。

1. 打开项目中的 `.github/workflows/gh_pages.yml` 文件。
2. **完全覆盖**为以下内容（确保没有任何缩进错误）：

```yaml
name: GitHub Page Deploy

on:
  push:
    branches:
      - develop
  # 【优化1】新增手动触发按钮
  # 允许你在不修改代码的情况下，在 GitHub Actions 界面手动点击重新部署
  workflow_dispatch:

env:
  TZ: Asia/Shanghai

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout develop
        uses: actions/checkout@v4
        with:
          submodules: recursive
          fetch-depth: 0

      - name: Git Configuration
        run: git config --global core.quotePath false

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: 'latest'
          extended: true

      - name: Cache Hugo resources
        uses: actions/cache@v4
        with:
          path: |
            ~/.cache/hugo_cache
            resources
          # 【优化2】更智能的缓存 Key
          # 如果 go.sum 不存在（有些简单项目没有），则使用 hugo 配置文件做哈希，防止缓存失效
          key: ${{ runner.os }}-hugo-${{ hashFiles('go.sum') || hashFiles('hugo.*') }}
          restore-keys: |
            ${{ runner.os }}-hugo-

      - name: Build Hugo
        run: hugo --gc --minify --logLevel info

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_branch: master
          publish_dir: ./public
          commit_message: ${{ github.event.head_commit.message }}

      - name: Deploy to Server (Rsync)
        # 【优化3】锁定插件版本
        # 建议使用具体的版本号 (v5.1.0) 而不是 @main
        # @main 是开发版，可能会突然引入 Bug 导致你部署失败
        uses: easingthemes/ssh-deploy@v5.1.0
        with:
          SSH_PRIVATE_KEY: ${{ secrets.SERVER_SSH_KEY }}
          ARGS: "-avzr --delete"
          SOURCE: "public/"
          REMOTE_HOST: "142.171.177.173"
          REMOTE_USER: "admin"
          TARGET: "/var/www/blog/"
          EXCLUDE: "/.git/, /.github/"
          # 【优化4】跳过 Host Key 检查
          # 防止 VPS 重装或 IP 变动后，GitHub 报错 "Host key verification failed"
          SSH_CMD_ARGS: "-o StrictHostKeyChecking=no"
```

3. **推送代码，触发部署**：
```bash
git add .
git commit -m "Fix: Final deployment configuration"
git push origin develop
```

---

### 预期结果

只要你严格执行了：

1. **VPS 上装了 rsync**。
2. **VPS 上 `.ssh` 目录权限是 700，`authorized_keys` 是 600**。
3. **GitHub Secret 里填的是私钥**。
4. **VPS 文件里填的是公钥**。

这一次，GitHub Actions **一定会变绿**。现在开始操作吧！

## rsync vs FTP 
相比于传统的 FTP 或简单的文件拷贝，**rsync (Remote Sync)** 在网站部署和文件同步中具有压倒性的优势。对于维护像 **bore.vip** 这样基于 Hugo 的静态博客，rsync 是目前公认的最优选方案。

以下是 rsync 的核心优势：

---

### 极速的增量传输 (Delta-transfer Algorithm)

这是 rsync 的杀手锏。

* **按需更新**：它只同步源文件和目标文件之间有差异的部分。如果你只是修改了博客的一行字，它只会传输那几个字节，而不是重传整个 HTML 文件。
* **节省带宽**：由于只传差异数据，部署时间通常能从分钟级缩短到秒级，特别适合文件众多的静态网站。

### 镜像一致性与自动清理

通过 `--delete` 参数，rsync 可以确保目标文件夹（VPS）与源文件夹（GitHub 公共目录）完全一致。

* **自动删除残留**：如果你在 Hugo 中删除了一篇文章或修改了 URL，rsync 会自动删除服务器上过时的旧文件。
* **防止冗余**：这避免了服务器存储空间被不再使用的旧静态资源填满。

### 灵活的文件属性保留

在迁移或同步时，rsync 可以精准保留文件的元数据。

* **权限与时间戳**：使用 `-a` (Archive) 参数，可以一键保留文件的权限（Permissions）、所有者（Owner）和修改时间（Timestamps）。
* **软链接处理**：它能正确处理符号链接，而 FTP 往往会在这方面出错。

### 高安全性与加密传输

rsync 通常运行在 SSH 协议之上（即 **rsync over SSH**）。

* **加密通道**：所有的文件传输和认证过程都经过 SSH 加密，防止密码或数据在公网被窃听。
* **免密部署**：配合 SSH Key（如 `SERVER_SSH_KEY`），可以实现 GitHub Actions 到 VPS 的全自动安全登录，无需在代码中明文暴露密码。

---

### rsync vs FTP 优势对比表

| 特性 | rsync (推荐) | FTP (不推荐) |
| --- | --- | --- |
| **传输方式** | **增量同步**，只传变动部分 | **全量传输**，每次都要重传整个文件 |
| **速度** | **极快**，尤其是文件多、改动少时 | **较慢**，且建立连接开销大 |
| **安全性** | **高**，基于 SSH 加密 | **低**，通常是明文传输，不安全 |
| **一致性** | 完美保持镜像，支持**自动删除**旧文件 | 需手动删除服务器上的过时文件 |
| **适用场景** | 自动化部署、服务器备份 | 零星的单文件上传 |

---

### 您现在的部署状态

您已经成功修复了服务器上的权限问题并安装了 rsync 软件。现在您的 **gh_pages.yml** 工作流已经利用了 rsync 的这些优势：通过加密的 `SERVER_SSH_KEY` 实现了秒级的增量同步，并能自动清理旧文章产生的冗余文件。

**既然 rsync 已经通了，您想了解如何利用 rsync 配合脚本实现博客的“一键备份”到本地电脑吗？**


## 本地操作

部署hugo到服务器，网上一般方法是利用`git hook`。这里记录一种新的方法：利用FTP Deploy GitHub Actions自动部署hugo到Centos8服务器。今后只要提交源码到`github`仓库，剩下的事就交给`GitHub Actions`了。

参考：[hugo部署到coding&gitee&备份源码-本地操作](/archives/hugo-install-on-coding-and-gitee/#本地操作)

## 服务器操作

### 安装 Nginx

准备工作：如果服务器端口不是22，先要更改SSH端口：

```bash
vi /etc/ssh/sshd_config
port 22
```

然后重启生效。

首先，在服务器上安装`nginx`。

```bash
yum update -y
yum install nginx -y
```

如果是centos 7，先要安装安装epel：`yum install epel-release`，才能安装nginx。

### 启动 Nginx

Nginx 安装完成后需要手动启动，启动Nginx并设置开机自启：

```bash
systemctl start nginx
systemctl enable nginx
```

关闭防火墙：

```bash
systemctl stop firewalld.service
systemctl disable firewalld.service 
```

配置完成后，访问使用浏览器服务器 ip ，如果能看到以下界面，表示运行成功。

### 创建新的网站目录

**为了图方便，可以直接将网站目录改为FTP家目录。**

为了方便期间，我们在 `/var/www/` 目录下为每个站点创建一个文件夹。

```bash
sudo mkdir -p /var/www/blog
sudo chown -R $USER:$USER /var/www/blog
sudo chmod -R 755 /var/www
```

+ 解决Nginx出现403 forbidden

如果后面利用FTP上传网页后，出现`403 Forbidden`，解决方法：

假设网站根目录在`/var/www/blog/`，则执行：

```shell
chmod -R 777 /var/www
```

### 配置 nginx

```bash
vi /etc/nginx/conf.d/blog.conf
```

```bash
server {
  listen  80 ;
  listen [::]:80;
  root /var/www/blog;
  server_name bore.vip www.bore.vip;
  access_log  /var/log/nginx/hexo_access.log;
  error_log   /var/log/nginx/hexo_error.log;
  error_page 404 =  /404.html;
  location ~* ^.+\.(ico|gif|jpg|jpeg|png)$ {
    root /var/www/blog;
    access_log   off;
    expires      1d;
  }
  location ~* ^.+\.(css|js|txt|xml|swf|wav)$ {
    root /var/www/blog;
    access_log   off;
    expires      10m;
  }
  location / {
    root /var/www/blog;
    if (-f $request_filename) {
    rewrite ^/(.*)$  /$1 break;
    }
  }
  location /nginx_status {
    stub_status on;
    access_log off;
 }
}
```

重启 Nginx 服务器，使服务器设定生效：

```bash
sudo systemctl restart nginx
```

### 配置ssl证书

> 更多查看：[Nginx 配置 ssl 证书](/archives/58fed3fc/)

这里记下怎样添加 Let’s Encrypt 免费证书。（貌似只有上传了文件到网站目录，才能申请证书成功。）如果想启用阿里证书，可查看：[启用阿里免费证书](/archives/enable-ssl-on-nginx/#启用阿里免费证书)

#### 安装Certbot

```bash
yum install epel-release -y
yum install certbot -y
```

然后执行：

```bash
certbot certonly --webroot -w /var/www/blog -d bore.vip -m 455343442@qq.com --agree-tos
```

#### 配置Nginx

```bash
vi /etc/nginx/conf.d/blog.conf
```

```bash
server {
    listen 80;
    server_name bore.vip www.bore.vip;
    rewrite ^(.*)$ https://$server_name$1 permanent;
}
server {
  listen 443;
  root /var/www/blog;
  server_name bore.vip www.bore.vip;
  ssl on;
  ssl_certificate /etc/letsencrypt/live/bore.vip/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/bore.vip/privkey.pem;
  ssl_session_timeout 5m;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
  ssl_prefer_server_ciphers on;
  access_log  /var/log/nginx/hexo_access.log;
  error_log   /var/log/nginx/hexo_error.log;
  error_page 404 =  /404.html;
  location ~* ^.+\.(ico|gif|jpg|jpeg|png)$ {
    root /var/www/blog;
    access_log   off;
    expires      1d;
  }
  location ~* ^.+\.(css|js|txt|xml|swf|wav)$ {
    root /var/www/blog;
    access_log   off;
    expires      10m;
  }
  location / {
    root /var/www/blog;
    if (-f $request_filename) {
    rewrite ^/(.*)$  /$1 break;
    }
  }
  location /nginx_status {
    stub_status on;
    access_log off;
 }
}
```

重启Nginx生效：

```bash
systemctl restart nginx
```

#### 证书自动更新

由于这个证书的时效只有 90 天，我们需要设置自动更新的功能，帮我们自动更新证书的时效。首先先在命令行模拟证书更新：

```bash
certbot renew --dry-run
```

模拟更新成功的效果如下(略)

在无法确认你的 nginx 配置是否正确时，一定要运行模拟更新命令，确保certbot和服务器通讯正常。使用 crontab -e 的命令来启用自动任务，命令行：

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

### 安装vsftpd

Debian查看：[Debian安装vsftpd](/archives/9eb70758/#Debian安装vsftpd)，Centos参考下面的。

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

创建一个新用户，名为admin:

```bash
sudo adduser admin
sudo passwd admin
```

将用户添加到允许的FTP用户列表中：

```bash
echo "admin" | sudo tee -a /etc/vsftpd/user_list
```

设置正确的权限（使ftp用户可以上传网站文件到相应目录）：

```bash
sudo chmod 755 /var/www/blog
sudo chown -R admin: /var/www/blog
```

### 关闭防火墙

```bash
systemctl stop firewalld.service
systemctl disable firewalld.service 
```

### 重启vsftpd服务

保存文件并重新启动vsftpd服务，以使更改生效：

```bash
sudo systemctl restart vsftpd
```

更多有关ftp部分可查看：[centos8搭建ftp服务器](/archives/centos8-enable-ftp/)

## 允许root登录FTP

1. 将`root`添加到允许的FTP用户列表中：

```bash
echo "root" | sudo tee -a /etc/vsftpd/user_list
```
2. 修改/etc/vsftpd/user_list和/etc/vsftpd/ftpusers两个设置文件脚本，将root账户前加上#号变为注释（使

root账户从禁止登录的用户列表中排除）。
```bash
vi /etc/vsftpd/user_list
```
```bash
vi /etc/vsftpd/ftpusers
```
3. 重启vsftpd服务
```bash
sudo systemctl restart vsftpd
```
## Github操作

### 配置`FTP_MIRROR_PASSWORD`

点击博客仓库的Settings->Secrets->Add a new secret，Name填写`FTP_MIRROR_PASSWORD`，Value填写用户密码。

### 配置 Github actions

在博客根目录新建`.github/workflows/gh_pages.yml`文件。代码（**不添加缓存**）如下：最好使用下面添加了缓存的。

```bash
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
        uses: SamKirkland/FTP-Deploy-Action@4.2.0
        with:
          server: 104.224.191.88
          username: admin
          password: ${{ secrets.FTP_MIRROR_PASSWORD }}
          local-dir: ./public/
          server-dir: /var/www/blog/
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
        uses: SamKirkland/FTP-Deploy-Action@4.3.0
        with:
          server: 104.224.191.88
          username: root
          password: ${{ secrets.FTP_MIRROR_PASSWORD }}
          local-dir: ./public/
          server-dir: /usr/share/nginx/html/
```

**第三方：**

```bash
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



## 提交源码

初始化git，新建并切换到`develop`分支，将源码提交到`develop`分支。稍等片刻，github action会自动部署blog到`master`分支和服务器。

```bash
git init
git checkout -b develop
git remote add origin git@github.com:iwyang/iwyang.github.io.git
git add .
git commit -m "备份源码"
git push --force origin develop
```

最终部署脚本：

```bash
#!/bin/bash

echo -e "\033[0;32mDeploying updates to gitee...\033[0m"

# backup
git config --global core.autocrlf false
git add .
git commit -m "site backup"
git push origin develop --force
```

## 克隆源码到本地

```bash
git clone -b develop git@github.com:iwyang/iwyang.github.io.git blog --recursive
```

因为使用`Submodule`管理主题，所以最后要加上 `--recursive`，因为使用 git clone 命令默认不会拉取项目中的子模块，你会发现主题文件是空的。（另外一种方法：`git submodule init && git submodule update`）

### 同步更新源文件

```bash
git pull origin develop
```

### 同步主题文件

```bash
git submodule update --remote
```

运行此命令后， Git 将会自动进入子模块然后抓取并更新，更新后重新提交一遍，子模块新的跟踪信息便也会记录到仓库中。这样就保证仓库主题是最新的。

## github、gitee、服务器三线部署hexo

将hexo三线部署（由于部署hexo较慢，如果单独为`gitee`建立一个`workflows`，gitee会先部署完成，这样无法同步；hugo可以单独为`gitee`建立一个`workflows`，因为`hugo`部署到服务器会先于部署到`gitee`）：

```yaml
name: Hexo Deploy

# 只监听 source 分支的改动
on:
  push:
    branches:
      - develop

# 自定义环境变量
env:
  POST_ASSET_IMAGE_CDN: true

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      # 获取博客源码和主题
      - name: Checkout
        uses: actions/checkout@v2.3.4

      - name: Checkout theme repo
        uses: actions/checkout@v2.3.4
        with:
          repository: jerryc127/hexo-theme-butterfly
          ref: master
          path: themes/butterfly

      # 这里用的是 Node.js 14.x
      - name: Set up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '14'

      # 设置 yarn 缓存，npm 的话可以看 actions/cache@v2 的文档示例
      - name: Get yarn cache directory path
        id: yarn-cache-dir-path
        run: echo "::set-output name=dir::$(yarn cache dir)"

      - name: Use yarn cache
        uses: actions/cache@v2.1.6
        id: yarn-cache
        with:
          path: ${{ steps.yarn-cache-dir-path.outputs.dir }}
          key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
          restore-keys: |
            ${{ runner.os }}-yarn-

      # 安装依赖
      - name: Install dependencies
        run: |
          yarn install --prefer-offline --frozen-lockfile

      # 从之前设置的 secret 获取部署私钥
      - name: Set up environment
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: |
          sudo timedatectl set-timezone "Asia/Shanghai"
          mkdir -p ~/.ssh
          echo "$DEPLOY_KEY" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan github.com >> ~/.ssh/known_hosts

      # 生成并部署
      - name: Deploy
        run: |
          npx hexo deploy --generate
          
      - name: Deploy Hexo to Server
        uses: SamKirkland/FTP-Deploy-Action@4.1.0
        with:
          server: 104.224.191.88
          username: admin
          password: ${{ secrets.FTP_MIRROR_PASSWORD }}
          local-dir: ./public/
          server-dir: /var/www/blog/
          
      - name: Sync to Gitee
        uses: wearerequired/git-mirror-action@master
        env:
          # 注意在 Settings->Secrets 配置 GITEE_RSA_PRIVATE_KEY
          SSH_PRIVATE_KEY: ${{ secrets.GITEE_RSA_PRIVATE_KEY }}
        with:
          # 注意替换为你的 GitHub 源仓库地址
          source-repo: git@github.com:iwyang/iwyang.github.io.git
          # 注意替换为你的 Gitee 目标仓库地址
          destination-repo: git@gitee.com:iwyang/iwyang.git

      - name: Build Gitee Pages
        uses: yanglbme/gitee-pages-action@main
        with:
          # 注意替换为你的 Gitee 用户名
          gitee-username: iwyang
          # 注意在 Settings->Secrets 配置 GITEE_PASSWORD
          gitee-password: ${{ secrets.GITEE_PASSWORD }}
          # 注意替换为你的 Gitee 仓库，仓库名严格区分大小写，请准确填写，否则会出错
          gitee-repo: iwyang/iwyang
          # 要部署的分支，默认是 master，若是其他分支，则需要指定（指定的分支必须存在）
          branch: master
```

## github、gitee、服务器三线部署hugo

由于部署到`github`和服务器先于`gitee`，所有可以建立两个`workflows`。

1. 根目录新建`.github/workflows/deploy.yml`（用于部署到`github`和服务器）

```bash
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
          username: admin
          password: ${{ secrets.FTP_MIRROR_PASSWORD }}
          local-dir: ./public/
          server-dir: /var/www/blog/
```

2. 根目录新建`.github/workflows/Sync to Gitee.yml`（用于部署到`gitee`）

```yaml
name: Sync to Gitee

on:
  push:
    branches: develop

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Sync to Gitee
        uses: wearerequired/git-mirror-action@master
        env:
          # 注意在 Settings->Secrets 配置 GITEE_RSA_PRIVATE_KEY
          SSH_PRIVATE_KEY: ${{ secrets.GITEE_RSA_PRIVATE_KEY }}
        with:
          # 注意替换为你的 GitHub 源仓库地址
          source-repo: git@github.com:iwyang/iwyang.github.io.git
          # 注意替换为你的 Gitee 目标仓库地址
          destination-repo: git@gitee.com:iwyang/iwyang.git

      - name: Build Gitee Pages
        uses: yanglbme/gitee-pages-action@main
        with:
          # 注意替换为你的 Gitee 用户名
          gitee-username: iwyang
          # 注意在 Settings->Secrets 配置 GITEE_PASSWORD
          gitee-password: ${{ secrets.GITEE_PASSWORD }}
          # 注意替换为你的 Gitee 仓库，仓库名严格区分大小写，请准确填写，否则会出错
          gitee-repo: iwyang/iwyang
          # 要部署的分支，默认是 master，若是其他分支，则需要指定（指定的分支必须存在）
          branch: master
```

## 解决问题

1.**Error: FTPError: 550 Remove directory operation failed**

```yaml
rm -rf /var/www/blog

sudo mkdir -p /var/www/blog
sudo chown -R $USER:$USER /var/www/blog
sudo chmod -R 755 /var/www

sudo chmod 755 /var/www/blog
sudo chown -R admin: /var/www/blog

sudo systemctl restart vsftpd
```

## 参考链接

[1.从 0 开始搭建 hexo 博客](https://eliyar.biz/how_to_build_hexo_blog/)

[2.为博客添加 Let’s Encrypt 免费证书](https://blog.yizhilee.com/post/letsencrypt-certificate/)

[3.SamKirkland](https://github.com/SamKirkland)/[FTP-Deploy-Action](https://github.com/SamKirkland/FTP-Deploy-Action)

[4.vsftpd参数设置，并允许root账户登录ftp](https://blog.csdn.net/weixin_43782998/article/details/109163384)

[5.Stack主题 + GitHub Action](https://blog.zhixuan.dev/posts/ce103e3b/)

