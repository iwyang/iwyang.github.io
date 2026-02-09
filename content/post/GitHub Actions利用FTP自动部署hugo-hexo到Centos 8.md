---
title: GitHub Actions利用FTP自动部署hugo-hexo到Centos 8
categories:
  - 技术
tags:
  - 服务器
  - hugo
  - hexo
  - github
slug: c7ccd27d
date: 2021-08-15 08:39:34
cover: false
---



部署hugo到服务器，网上一般方法是利用`git hook`。这里记录一种新的方法：利用FTP Deploy GitHub Actions自动部署hugo到Centos8服务器。今后只要提交源码到`github`仓库，剩下的事就交给`GitHub Actions`了。

## 本地操作

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

