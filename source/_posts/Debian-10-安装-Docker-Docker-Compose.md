---
title: Debian 10 安装 Docker & Docker Compose
categories:
  - 技术
tags:
  - docker
comments: true
cover: /img/cover/docker.jpg
abbrlink: 9755dbc8
date: 2022-08-22 17:56:32
sticky: 100
keywords:
description:
top_img:
---

{% note warning flat %}
Debian10 上安装部分应用，速度几乎为0，至少需要Debian11以上，512M内存足够。
{% endnote %}

## 安装 Docker

1.首先，更新现有的软件包列表：

```bash
sudo apt update -y
```

2.接下来，安装一些必备软件包，让 apt 通过 HTTPS 使用软件包。

```bash
sudo apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
```

3.然后将官方 Docker hub 的 GPG key 添加到系统中。

```bash
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
```

4.将 Docker 版本库添加到APT源：

```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
```

5.接下来，我们用新添加的 Docker 软件包来进行升级更新。

```yaml
sudo apt update -y
```

6.安装 Docker 

```bash
sudo apt install docker-ce -y
```

7.检查 Docker 是否正在运行

```
docker --version
sudo systemctl status docker
```



8.重启 docker 并设置开机自启

```
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

9.修改Docker配置（来自[烧饼博客](https://u.sb/debian-install-docker/)）

以下配置会增加一段自定义内网 IPv6 地址，开启容器的 IPv6 功能，以及限制日志文件大小，防止 Docker 日志塞满硬盘（泪的教训）

```bash
cat > /etc/docker/daemon.json <<EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "20m",
        "max-file": "3"
    },
    "ipv6": true,
    "fixed-cidr-v6": "fd00:dead:beef:c0::/80",
    "experimental":true,
    "ip6tables":true
}
EOF
```

然后重启 Docker 服务：

```bash
systemctl restart docker
```

## 在 Docker 中使用镜像

1.要查看已下载到计算机的镜像：

```bash
docker images
```

2.删除某个docker镜像

```bash
docker rmi <your-image-id>
```

3.一次删除多张镜像

```bash
docker rmi <your-image-id> <your-image-id> ...
```

4.一次删除所有镜像

```bash
docker rmi $(docker images -q)
```

## 在 Docker 中使用容器

1.要查看**所有**的容器对象，请使用：

```bash
docker ps -a
```

> docker ps -a -q 分解
>
> - `docker ps` 列出**活动**中容器。
> - `-a` 这个选项用于列出**所有**容器，包括停止运行的。如果没有这个选项，则默认只列出在运行的容器。
> - `-q` 这个选项列出容器的数字 ID，而不是容器的所有信息。



2.要启动已停止的容器，请使用`docker start命令+容器ID或容器名`

>- 停止所有容器运行：`docker stop $(docker ps -a -q)`



3.通过`docker rm`命令来删除不用的容器。



>+ 先使用`docker ps -a`命令查找相关镜像关联的容器的**容器ID或名称**，然后通过`docker rm`命令来删除其删除。
>+ 删除所有停止运行的容器：`docker rm $(docker ps -a -q)`

### **Docker 容器开机自启**

1.在使用docker run启动容器时，使用--restart参数来设置：

```bash
docker run -m 512m --memory-swap 1G -it -p 58080:8080 --restart=always  
```

2.如果创建时未指定 --restart=always ,可通过update 命令设置

```bash
docker update --restart=always 容器ID或名称
```

## 安装 Docker Compose

1.安装

```bash
export LATEST_VERSION=$(wget -qO- -t1 -T2 "https://api.github.com/repos/docker/compose/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
sudo curl -L https://github.com/docker/compose/releases/download/$LATEST_VERSION/docker-compose-linux-`uname -m` > ./docker-compose
sudo chmod +x ./docker-compose
sudo mv ./docker-compose /usr/local/bin/docker-compose
```

2.查看版本

```
docker-compose --version
```

3.使用 -d 选项以分离模式启动 Compose(后台)

```
docker-compose up -d
```

4.要查看正在运行的 docker 容器，请使用以下命令

```
docker-compose ps
```

5.删除容器

```
cd /root/docker/tv
docker-compose stop
docker-compose down    
cd ..
rm -rf /root/docker/tv
```

6.一些 Docker Compose 常用命令：

```
docker-compose restart  # 重启容器
docker-compose stop     # 暂停容器
docker-compose down     # 删除容器
docker-compose pull     # 更新镜像
docker-compose exec artalk bash # 进入容器
```

7.Docker Compose升级

拉取最新镜像，然后重新创建容器即可。

```
docker-compose pull
docker-compose up -d
docker image prune -f
```

**8.使用 Watchtower 自动更新**

[Watchtower](https://github.com/containrrr/watchtower) 可自动检测并更新 Docker 容器到最新镜像。

```yaml
services:
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 86400 --cleanup
    restart: always
```

### **开机自动启动应用容器**

1.方法一、通过 Docker Restart Policy 方法

在 Docker 中，支持 --restart 选项，来控制容器自动启动。在 Docker Compose 中，应该使用 restart 属性

```diff
version: '2'
services:
  database:
    build: ./mysql/
    command: mysqld --user=root --verbose
+   restart: always 
    environment:
      MYSQL_DATABASE: "web_level3_sqli"
      MYSQL_USER: "web_level3_sqli"
      MYSQL_PASSWORD: "thisisasecurepassword123"
      MYSQL_ROOT_PASSWORD: "root"
      MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
  web:
    build: ./www/
+    restart: always
    ports:
     - "12000:80"
    volumes:
      - ./www/src:/var/www/html
    links:
      - database
```

注意事项：
1）Docker 并不知道这些服务的依赖关系及启动顺序，需要我们精心编排 docker-compose.yaml 文件；
2）Docker Compose 不支持 deploy:restart_policy 属性，该属性只能用于 a swarm with docker stack deploy 环境；



2.方法二、通过进程管理服务（推荐）

该方法本质上还是在执行 docker-compose 命令。

使用 systemd 管理
如下示例，可以根据需要进行设置：

```bash
# cat /etc/systemd/system/docker-compose-app.service

[Unit]
Description=Docker Compose Application Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/srv/docker/app/
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

7.卸载 Docker Compose

```
sudo rm /usr/local/bin/docker-compose
```

## Docker Compose 部署tv

参考：[Memos Docker-Compose部署](/archives/d5e37958/?highlight=mem#Docker-Compose部署)

### 创建 tv 工作目录

```yaml
mkdir -p /root/docker/tv
cd /root/docker/tv
vi docker-compose.yml
```

### 编写 `docker-compose.yml` 文件：

注意更改   `- PASSWORD=你的密码`

```
vi docker-compose.yml
```

```yaml
services:
  decotv-core:
    image: ghcr.io/decohererk/decotv:latest
    container_name: decotv-core
    restart: always  # You can keep 'unless-stopped' or 'always' as preferred
    ports:
      - '3000:3000'
    environment:
      - USERNAME=admin
      - PASSWORD=你的密码
      - NEXT_PUBLIC_STORAGE_TYPE=kvrocks
      - KVROCKS_URL=redis://decotv-kvrocks:6666
      - NEXT_PUBLIC_DISABLE_YELLOW_FILTER=false
    networks:
      - decotv-network
    depends_on:
      - decotv-kvrocks

  decotv-kvrocks:
    image: apache/kvrocks
    container_name: decotv-kvrocks
    restart: always  # You can keep 'unless-stopped' or 'always' as preferred
    volumes:
      - kvrocks-data:/var/lib/kvrocks
    networks:
      - decotv-network

  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 86400 --cleanup
    restart: always  # You can keep 'unless-stopped' or 'always' as preferred

networks:
  decotv-network:
    driver: bridge

volumes:
  kvrocks-data:
```

### 执行命令

`tv` 后端程序将运行在 `http://localhost:端口号`

```
docker-compose up -d
```

### 配置域名访问

参考：[域名访问](/archives/d5e37958/?highlight=mem#配置域名访问)

```yaml
server {
  listen 80;
  server_name tv.bore.vip;

  # Redirect all HTTP traffic to HTTPS
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl http2;
  server_name tv.bore.vip;
  root /data/wwwroot/tv.bore.vip;

  # SSL setting
  ssl_certificate /etc/letsencrypt/live/tv.bore.vip/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/tv.bore.vip/privkey.pem;
  ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;
  add_header Strict-Transport-Security "max-age=31536000";

  # proxy to 3000
  location / {
    proxy_pass http://127.0.0.1:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header REMOTE-HOST $remote_addr;
    add_header X-Cache $upstream_cache_status;
    # cache
    add_header Cache-Control no-cache;
    expires 12h;
  }

  location ^~ /.well-known/acme-challenge/ {
    default_type "text/plain";
    allow all;
    root /data/wwwroot/tv.bore.vip/;
  }
}
```

### 视频源配置

- **基础版**（20+站点）：[config_isadult.json](https://www.mediafire.com/file/upztrjc0g1ynbzy/config_isadult.json/file)
- **增强版**（94 站点）：[configplus_isadult.json](https://www.mediafire.com/file/ff60ynj6z21iqfb/configplus_isadult.json/file)
- 精简版：[精简版](https://raw.githubusercontent.com/hafrey1/LunaTV-config/refs/heads/main/jin18.txt)

精简版见：[LunaTV-config](https://github.com/hafrey1/LunaTV-config)

### 更新镜像

*注意：更新前最好在后台先备份数据*

```yaml
cd /root/docker/tv
docker-compose pull
docker-compose up -d
docker image prune -f
```

---

PS：是否需要 `docker-compose down`？（问chatgpt）

一般 **不需要**，除非：

- 改过网络、volume、端口等会冲突的配置
- 某些服务需要完全重建
- 想彻底清理旧容器

如果你只是更新镜像 → 重启服务，那么 **不加 `down` 是正确的**。

---

## 自定义tv

### fork仓库

这一步简单，fork后可克隆到本地修改代码，修改完成后提交，注意先**添加本地SSH公钥**到仓库，参考：[配置 SSH 公钥](/archives/8b53a475/#配置SSH-公钥)

克隆：

```
git clone https://github.com/iwyang/DecoTV.git
```

修改后提交：

```
git add .
git commit -m "更新"
git push origin main
```

---

**github退回旧版本**

+ 退回到指定版本

如果你想彻底回退到 `ba82571f837d9e0a7abf1d667c9354543e87c130`，并删除该提交之后的所有历史记录，使用以下命令：

```
git reset --hard ba82571f837d9e0a7abf1d667c9354543e87c130
```

**注意**：这会丢失所有在目标提交之后的更改，包括工作区和暂存区的内容。

+ 推送更改到远程仓库

```
git push origin main --force
```

---

**服务器拉取最新镜像：**

```
cd /root/docker/tv
docker-compose pull
docker-compose up -d
docker image prune -f
```

### 创建 github 访问 token

1. 在任何页面的右上角，单击个人资料照片，然后单击 “设置”。

2. 在左侧边栏中，单击 “开发人员设置”。
3. 请在左侧边栏的 “Personal access token” 下，单击 “细粒度令牌” 。
4. 单击 “生成新令牌”。
5. 在 “令牌名称” 下，输入令牌的名称。
6. 在 “过期时间” 下，选择令牌的过期时间（永不过期）。
7. 然后权限要开启 **repo** 和 **workflow**和**write:package**s以及**read:packages** 的权限

### 添加环境变量 secret

在 `settings/secrets(Secrets and variables)/actions` 里把 Github 的 Token 设置上，比如 workflow 写的是secrets.GHCR_TOKEN，所以添加的时候 Name 填写 GHCR_TOKEN，Secret 里填写上一步创建 Token 内容。

### 修改docker-image.yml

把.github/workflows/docker-image.yml中的`secrets.GITHUB_TOKEN `改成`secrets.GHCR_TOKEN`，大概有三处要改。**GitHub actions成功运行后就可以创建自己的镜像。**

### 修改`docker-compose.yml` 文件

**注意修改自己的密码**

```
vi docker-compose.yml
```

```yaml
services:
  decotv-core:
    image: ghcr.io/iwyang/decotv:latest
    container_name: decotv-core
    restart: always  # You can keep 'unless-stopped' or 'always' as preferred
    ports:
      - '3000:3000'
    environment:
      - USERNAME=admin
      - PASSWORD=你的密码
      - NEXT_PUBLIC_STORAGE_TYPE=kvrocks
      - KVROCKS_URL=redis://decotv-kvrocks:6666
      - NEXT_PUBLIC_DISABLE_YELLOW_FILTER=false
    networks:
      - decotv-network
    depends_on:
      - decotv-kvrocks

  decotv-kvrocks:
    image: apache/kvrocks
    container_name: decotv-kvrocks
    restart: always  # You can keep 'unless-stopped' or 'always' as preferred
    volumes:
      - kvrocks-data:/var/lib/kvrocks
    networks:
      - decotv-network

  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 86400 --cleanup
    restart: always  # You can keep 'unless-stopped' or 'always' as preferred

networks:
  decotv-network:
    driver: bridge

volumes:
  kvrocks-data:
```

## 修改TV logo和PWA启动图片

+ logo在根目录`public`文件夹下，favicon.ico和logo.png
+ pwa启动图片在根目录`public\icons`文件夹下（根目录scripts\generate-manifest.js文件可查看）

## douban页面隐藏数据源选择器

1.提问[grok](https://grok.com/)（附件添加[src](https://github.com/iwyang/DecoTV/tree/main/src)/[app](https://github.com/iwyang/DecoTV/tree/main/src/app)/[douban](https://github.com/iwyang/DecoTV/tree/main/src/app/douban)/page.tsx）：

怎样修改，才能隐藏 ：数据源(30) 聚合🎬-爱qiyi......

 2.接着追问：能给我修改好的完整文件吗（grok发的代码经常不完整，导致部署出错）

3.如果部署报错，下载日志文件给它分析：**点击`Explain error`右边的小齿轮选择`Download logs arichive`**，下载日志文件，找到失败那一步，复制错误日志给ai分析

**修改完成效果：**

- “数据源(30)” 那一整行完全消失
- 不再加载任何第三方 CMS 源
- 所有与 useSourceFilter、sourceData、filteredSourceCategories 等相关代码已删除
- 页面只显示豆瓣原生内容或 Bangumi 每日放送，体验更纯粹、加载更快

直接替换原来的 page.tsx 即可。祝使用愉快！

## 隐藏源指定分类

方法如上，还是用[grok](https://grok.com/)，提问：

**默认此页面会显示源的所有分类，帮我修改代码，实现以下过滤规则：**

- **如果源名称包含 “艾旦影视” → 完全隐藏所有分类（不显示任何分类按钮）**
- **其他所有源 → 自动隐藏以下敏感分类，如福利、伦理、里番动画等**

**给我完整代码，不要省略代码**

**注意：会省略代码，要反复确认是否是完整代码，有没有省略，尤其是部署失败的时候**，也可下载日志文件，找到失败那一步，复制错误日志给ai分析

## 搜索屏蔽指定违禁词

方法如上，还是用[grok](https://grok.com/)，上传`/src/app/api/search`下面的5个路由文件，**提问**：

**怎样修改才能实现：**
**1.搜索违禁词时，直接跳过搜索，返回空结果。**

**2.当搜索结果含有违禁词时，屏蔽显示该结果**

**3.新建一个 filter.ts，专门设置违禁词，其他 4 个文件引用就行**

**给我完整代码，不要省略代码，文件开头注释修改的是哪个文件。**

---

**注意：会省略代码，要反复确认是否是完整代码，有没有省略，尤其是部署失败的时候**，也可下载日志文件，找到失败那一步，复制错误日志给ai分析

## 电影、动漫等页面排序

还是用[grok](https://grok.com/)，上传`\src\app\douban\page.tsx`和`\src\components\MultiLevelSelector.tsx`2个文件，**提问**：

---

我想修改代码达到以下最终效果，请帮我给出完整代码（不要省略），并解释关键改动：

【页面/功能】：Douban页面 / 排序筛选器 / 动漫分类等

【当前文件】：page.tsx / MultiLevelSelector.tsx

【想要的最终效果】（越详细越好，按优先级列点）：

1. 电影/电视剧/综艺页面默认分类是“全部”，默认排序是“近期热度”（sort = ‘U’），胶囊显示“近期热度”
2. 动漫页面默认显示“番剧”分类，“番剧”分类和“剧场版”分类默认排序是“近期热度”（sort = ‘U’），胶囊显示“近期热度”
3. 切换到“综合排序”时，胶囊按钮显示“排序”（灰色）
4. 选择“近期热度”或其他非综合排序时，胶囊显示具体名称（绿色）
5. 下拉菜单里默认高亮“近期热度”

【其他要求】（如果有）：
- 不要改变其他筛选器的行为
- 保持现有加载更多、骨架屏等逻辑不变
- 请给出完整文件代码，不要省略

当前代码请参考附件：[拖入或贴上最新 page.tsx / MultiLevelSelector.tsx 代码]

## 播放源只显示标题开头的源

还是用[grok](https://grok.com/)，上传`yangtv`'下`\src\app\play\page.tsx`文件，**提问**：(得到最终需要的版本后，问grok：以后要修改代码，达到这种效果的话，**要怎样向你提问**)

**我希望播放源过滤规则变成：**
**核心条件：**
- **result.title（忽略空格、大小写）必须以主标题（videoTitle 或 searchTitle）开头**
- **年份要匹配（如果有 year 参数）**

**类型处理：**
- **如果 searchType 是 movie，允许 episodes.length <= 5 的源通过**
- **如果 searchType 是 tv，还是要求 episodes.length > 1**
- **如果没有 searchType，就不限制类型**

**请直接给出修改后的完整 filter 代码块**

```yaml
const results = data.results.filter((result: SearchResult) => {
  if (!result.title) return false;

  // 主标题处理（忽略大小写、去掉所有空格）
  const mainTitle = (searchTitle || videoTitleRef.current || '')
    .trim()
    .replace(/\s+/g, '')           // 推荐用这个正则，更彻底去空格
    .toLowerCase();

  // 源标题同样处理
  const sourceTitleClean = result.title
    .trim()
    .replace(/\s+/g, '')
    .toLowerCase();

  // ★ 最核心条件：必须以主标题开头（最能保证相关性）
  const isPrefixMatch = sourceTitleClean.startsWith(mainTitle);

  // 年份匹配（建议保留）
  const yearMatch = videoYearRef.current
    ? (result.year || '').toLowerCase() === videoYearRef.current.toLowerCase()
    : true;

  // 类型判断放宽（解决电影被标成 tv 的常见问题）
  const episodeCount = result.episodes?.length ?? 0;
  const isLikelyMovie = episodeCount <= 5;  // 允许 1~5 集（处理分上下部、误标、长片分段等）
  const isLikelyTv = episodeCount > 1;

  let typeMatch = true;

  if (searchType) {
    if (searchType === 'movie') {
      typeMatch = isLikelyMovie;           // 电影要求：看起来像电影即可
    } else if (searchType === 'tv') {
      typeMatch = isLikelyTv;              // 电视剧还是要求多集
    }
  }

  // 最终返回条件：标题开头是必须的，类型已放宽
  return isPrefixMatch && yearMatch && typeMatch;
});
```

## 播放源屏蔽子标题的源

还是用[grok](https://grok.com/)，提问：**“请修改过滤逻辑，将 `mainTitle` 的来源由 `stitle` 改为仅限 `title` 参数，确保源列表只显示以主标题开头的资源。”**

**修改前的逻辑（第 552 行左右）：**

```typescript
// 只要匹配 stitle 或主标题任何一个开头，就会显示
const mainTitle = (searchTitle || videoTitleRef.current || '')
  .trim()
  .replace(/\s+/g, '')
  .toLowerCase();
```

**修改后的逻辑：**

```typescript
// 仅使用主标题，彻底无视 stitle 的前缀干扰
const mainTitle = (videoTitleRef.current || '')
  .trim()
  .replace(/\s+/g, '')
  .toLowerCase();
```

## 屏蔽集数超过30%的源

还是用[grok](https://grok.com/)，**提问**：

我正在修改 `fetchSourcesData` 函数里的 `filter` 过滤逻辑（或者评分逻辑）。 **【业务场景】**：目前在搜索 [某种类型，如：电视剧] 时，会出现 [某种问题，如：有很多集数不全的脏数据]。 **【逻辑规则】**：

1. 请帮我区分 `movie` 和 `vod` 两种类型。
2. 如果是 `vod`，当 [条件，如：集数误差 > 30%] 时，执行拦截。
3. 如果是 `movie`，执行 [条件，如：集数 > 5 就拦截]。 **【动作目标】**：请直接在 `filter` 中返回 `false` **直接屏蔽**，不要只在评分里降分。 **【当前代码】**：[粘贴你相关的代码片段]

**最终效果：**

```
总结一下，这次修改通过将“拦截逻辑”前置到搜索阶段，实现了播放源列表的**“自动精简化”**。以下是最终实现的效果：

1. 电视剧：自动过滤“残血源”与“杂质源”
众数定标： 系统会自动分析搜索结果，找出大家公认的集数（如 40 集）。

30% 强力拦截： * 屏蔽残缺源： 如果某个源只有 20 集（低于 28 集），它会从列表里直接消失。

屏蔽灌水源： 如果某个源因为带了太多花絮导致有 60 集（高于 52 集），也会被直接干掉。

结果： 你看到的电视剧源列表将非常整齐，基本都是集数达标的正片源。

2. 电影：彻底杜绝“剧版”干扰
强制 1 集基准： 电影模式下不再统计众数，默认就是 1 集。

硬拦截（> 5集）： 搜电影时，凡是集数超过 5 集的（通常是同名的 30-40 集电视剧）会被瞬间过滤。

结果： 解决了“搜电影出来一堆电视剧”的痛点，列表极其干净。

3. 评分系统：回归纯粹性能比拼
纯净打分： calculateSourceScore 不再背负“惩罚误差源”的包袱，也不再需要处理业务逻辑参数。

比拼硬实力： 能够进入评分环节的都是“集数合格”的源，它们现在只纯粹地比拼 画质是否清晰（4K/1080P）、加载速度快慢 以及 网络延迟低秒。

4. 系统表现：更轻、更快、更省
节省测速资源： 那些不合格的源在第一步就被 filter 掉了，系统不会再去请求它们的 API 进行画质和速度测试。

加载提速： 减少了无效源的并行测试，整体搜索结果渲染出来的速度会更快，也节省了服务器和客户端的流量。

一句话总结： 现在的系统像加了一个智能安检门，电视剧只放行“足量”的，电影只放行“本体”，最后剩下的都是精品，你只需要在其中挑一个最快的就行。
```

## 设置暂无海报

搜索lunatv源码，查找需要修改的文件和代码位置（搜索暂无海报），`\src\components\VideoCard.tsx`，如果直接复制代码到yangtv相应位置，部署会报错，下载错误日志，上传`VideoCard.tsx`和错误日志给grok分析错误原因，没有给出正确修改方法，上传`VideoCard.tsx`和错误日志问[gemini](https://gemini.google.com/app)得到了正确修改方法（先问grok，不行再问Gemini）。

**问题在于：** 你的组件中定义的状态变量名称是 `isLoading` 和 `setIsLoading`（第 82 行），但你在错误处理回调函数中却尝试调用一个不存在的 `setImageLoaded` 函数。

------

**修复方案**

你需要将 `setImageLoaded(true)` 更改为组件中实际定义的 `setIsLoading(true)`。

**修改步骤：**

1. 打开 `src/components/VideoCard.tsx`。
2. 找到第 **571** 行左右。
3. 将 `setImageLoaded(true);` 替换为 `setIsLoading(true);`。

```yaml
              } else {
                // 重试失败，使用通用占位图
                img.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="200" height="300" viewBox="0 0 200 300"%3E%3Crect fill="%23374151" width="200" height="300"/%3E%3Cg fill="%239CA3AF"%3E%3Cpath d="M100 80 L100 120 M80 100 L120 100" stroke="%239CA3AF" stroke-width="8" stroke-linecap="round"/%3E%3Crect x="60" y="140" width="80" height="100" rx="5" fill="none" stroke="%239CA3AF" stroke-width="4"/%3E%3Cpath d="M70 160 L90 180 L130 140" stroke="%239CA3AF" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/%3E%3C/g%3E%3Ctext x="100" y="270" font-family="Arial" font-size="12" fill="%239CA3AF" text-anchor="middle"%3E暂无海报%3C/text%3E%3C/svg%3E';
                setIsLoading(true);
              }
```

## 为豆瓣添加2026年的筛选选项

`src/components/MultiLevelSelector.tsx`

```diff

       options: [
         { label: '全部', value: 'all' },
         { label: '2020年代', value: '2020s' },
+        { label: '2026', value: '2026' },
         { label: '2025', value: '2025' },
         { label: '2024', value: '2024' },
```

## 播放源排序

问[gemini](https://gemini.google.com/app)：

“我想修改 `page.tsx` 里的播放逻辑，实现‘无感知优选’。 **详细逻辑：**

1. **起播策略：**
   - **有指定源：** 立即起播，不显示测速加载动画。
   - **无指定源：** 允许显示短暂加载（如 2 秒），测速完成后自动播放评分最高的源。
2. **后台逻辑：** 无论哪种情况，起播后都要在后台持续完成所有源的并发测速。
3. **UI 排序：** 测速结束后，侧边栏列表按评分（速度+分辨率）降序排列。
4. **置顶保护：** 更新列表时，当前正在播放的源必须锁定在第一位，其余源按评分排序，防止 UI 闪烁或错位。 **文件：** [上传 page.tsx]”

## 屏蔽每日放送，调整首页

用[grok](https://grok.com/)，准备3个文件，index.page.tsx、douban.page.tsx、DoubanSelector.tsx，**自己提问：**

1.屏蔽动漫页面下“每日放送”分类 2.将首页“每日放送”改为“热门番剧”，显示“番剧”分类下“近期热度”内容 3.将首页“热门电影”显示内容改为“电影”全部分类下的“近期热度” 4.将首页“热门剧集”显示内容改为“剧集”全部分类下的“近期热度” 4.将首页“热门综艺”显示内容改为“综艺”全部分类下的“近期热度” 给我完整代码

  **AI提问：**

```
请帮我修改以下三个文件，实现以下具体需求：
1. 首页 index.page.tsx：每个板块（热门电影、热门剧集、热门番剧、热门综艺）显示18张近期热度（sort=U）的豆瓣推荐影片，去掉原来的 .slice(0,8)
2. douban.page.tsx：动漫页面彻底移除“每日放送”，默认选中“番剧”
3. DoubanSelector.tsx：修复 React 19 的 ref 类型错误（ref 回调返回 void）

请给出每个文件的**完整修改后代码**，不要省略，不要只给 diff。
```

## 修复收藏不显示、清空二次确认

### 修复收藏不显示

上传old.page.tsx和new.page.tsx两个文件，提问[gemini](https://gemini.google.com/app)：**old.page.tsx改成new.page.tsx，收藏夹内容无法正确显示**

```tsx
/* eslint-disable @typescript-eslint/no-explicit-any, react-hooks/exhaustive-deps, no-console */

'use client';

import { ChevronRight } from 'lucide-react';
import Link from 'next/link';
import { Suspense, useEffect, useState } from 'react';

// --- API Imports ---
import {
  BangumiCalendarData,
  GetBangumiCalendarData,
} from '@/lib/bangumi.client';
import {
  clearAllFavorites,
  getAllFavorites,
  getAllPlayRecords,
  subscribeToDataUpdates,
} from '@/lib/db.client';
import { getDoubanRecommends } from '@/lib/douban.client';
import { DoubanItem } from '@/lib/types';

// --- Component Imports ---
import CapsuleSwitch from '@/components/CapsuleSwitch';
import ContinueWatching from '@/components/ContinueWatching';
import DecoTVFooterCard from '@/components/DecoTVFooterCard';
import PageLayout from '@/components/PageLayout';
import ScrollableRow from '@/components/ScrollableRow';
import { useSite } from '@/components/SiteProvider';
import VideoCard from '@/components/VideoCard';

// --- Interfaces ---
interface FavoriteItem {
  id: string;
  source: string;
  title: string;
  poster: string;
  episodes: number;
  source_name: string;
  currentEpisode?: number;
  search_title?: string;
  origin?: 'vod' | 'live';
  year?: string;
}

function HomeClient() {
  const [activeTab, setActiveTab] = useState<'home' | 'favorites'>('home');
  const [hotMovies, setHotMovies] = useState<DoubanItem[]>([]);
  const [hotTvShows, setHotTvShows] = useState<DoubanItem[]>([]);
  const [hotVarietyShows, setHotVarietyShows] = useState<DoubanItem[]>([]);
  const [hotAnimes, setHotAnimes] = useState<DoubanItem[]>([]);
  const [loading, setLoading] = useState(true);
  
  const { siteName, announcement } = useSite();
  const [showAnnouncement, setShowAnnouncement] = useState(false);
  const [favoriteItems, setFavoriteItems] = useState<FavoriteItem[]>([]);

  // Announcement Logic
  useEffect(() => {
    if (typeof window !== 'undefined' && announcement) {
      const hasSeen = localStorage.getItem('hasSeenAnnouncement');
      if (hasSeen !== announcement) {
        setShowAnnouncement(true);
      }
    }
  }, [announcement]);

  // Data Fetching Logic
  useEffect(() => {
    const fetchAllData = async () => {
      try {
        setLoading(true);
        const [moviesRes, tvRes, varietyRes, animeRes, bangumiRes] = await Promise.all([
          getDoubanRecommends({ kind: 'movie', pageLimit: 20, sort: 'U' }),
          getDoubanRecommends({ kind: 'tv', pageLimit: 20, format: '电视剧', sort: 'U' }),
          getDoubanRecommends({ kind: 'tv', pageLimit: 20, format: '综艺', sort: 'U' }),
          getDoubanRecommends({ kind: 'tv', pageLimit: 20, category: '动画', format: '电视剧', sort: 'U' }),
          GetBangumiCalendarData(),
        ]);

        if (moviesRes.code === 200) setHotMovies(moviesRes.list);
        if (tvRes.code === 200) setHotTvShows(tvRes.list);
        if (varietyRes.code === 200) setHotVarietyShows(varietyRes.list);
        if (animeRes.code === 200) setHotAnimes(animeRes.list);
      } catch (error) {
        console.error('Fetch Error:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchAllData();
  }, []);

  // Favorites Management
  const updateFavoriteItems = async (allFavorites: Record<string, any>) => {
    const allPlayRecords = await getAllPlayRecords();
    const sorted = Object.entries(allFavorites)
      .sort(([, a], [, b]) => b.save_time - a.save_time)
      .map(([key, fav]) => {
        const plusIndex = key.indexOf('+');
        const source = key.slice(0, plusIndex);
        const id = key.slice(plusIndex + 1);
        const playRecord = allPlayRecords[key];
        
        return {
          id,
          source,
          title: fav.title,
          year: fav.year,
          poster: fav.cover,
          episodes: fav.total_episodes,
          source_name: fav.source_name,
          currentEpisode: playRecord?.index,
          search_title: fav?.search_title,
          origin: fav?.origin,
        } as FavoriteItem;
      });
    setFavoriteItems(sorted);
  };

  useEffect(() => {
    if (activeTab !== 'favorites') return;
    const loadFavorites = async () => {
      const allFavorites = await getAllFavorites();
      await updateFavoriteItems(allFavorites);
    };
    loadFavorites();
    const unsubscribe = subscribeToDataUpdates('favoritesUpdated', (newFavs: any) => {
      updateFavoriteItems(newFavs);
    });
    return unsubscribe;
  }, [activeTab]);

  const handleCloseAnnouncement = (msg: string) => {
    setShowAnnouncement(false);
    localStorage.setItem('hasSeenAnnouncement', msg);
  };

  return (
    <PageLayout>
      {/* Header Visual Section */}
      <div className="relative pt-20 pb-10 sm:pt-32 sm:pb-16 overflow-hidden">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-75 h-75 sm:w-150 sm:h-150 bg-purple-500/20 rounded-full blur-[80px] sm:blur-[120px] -z-10 pointer-events-none animate-pulse" />
        <div className="flex flex-col items-center justify-center text-center px-4">
          <div className="relative group">
            <h1 className="text-6xl sm:text-8xl font-black tracking-tighter deco-brand drop-shadow-2xl select-none transition-transform duration-500 group-hover:scale-105">
              {siteName || 'DecoTV'}
            </h1>
            <div className="absolute -inset-8 bg-gradient-to-r from-blue-500/20 via-purple-500/20 to-pink-500/20 blur-2xl -z-10 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
          </div>
          <div className="mt-8 animate-fade-in-up">
            <div className="inline-flex items-center gap-3 px-6 py-2.5 rounded-full bg-white/50 dark:bg-black/30 backdrop-blur-md border border-white/20 dark:border-white/10 shadow-lg">
              <span className="text-base sm:text-lg font-medium text-gray-800 dark:text-gray-100">发现</span>
              <span className="w-1 h-1 rounded-full bg-gray-300 dark:bg-gray-600" />
              <span className="text-base sm:text-lg font-medium text-gray-800 dark:text-gray-100">收藏</span>
              <span className="w-1 h-1 rounded-full bg-gray-300 dark:bg-gray-600" />
              <span className="text-base sm:text-lg font-medium text-gray-800 dark:text-gray-100">继续观看</span>
            </div>
          </div>
        </div>
      </div>

      <div className="px-2 sm:px-10 py-4 sm:py-8">
        <div className="mb-8 flex justify-center">
          <CapsuleSwitch
            options={[{ label: '首页', value: 'home' }, { label: '收藏夹', value: 'favorites' }]}
            active={activeTab}
            onChange={(v) => setActiveTab(v as any)}
          />
        </div>

        <div className="max-w-[95%] mx-auto">
          {activeTab === 'favorites' ? (
            <section className="mb-8">
              <div className="mb-4 flex items-center justify-between">
                <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200">我的收藏夹</h2>
                {favoriteItems.length > 0 && (
                  <button 
                    className="text-sm text-gray-400 hover:text-red-500 transition-colors"
                    onClick={async () => { if(confirm('Clear all?')) { await clearAllFavorites(); setFavoriteItems([]); } }}
                  >
                    清空
                  </button>
                )}
              </div>
              <div className="grid grid-cols-3 gap-x-2 gap-y-14 sm:grid-cols-[repeat(auto-fill,minmax(11rem,1fr))] sm:gap-x-8 sm:gap-y-20">
                {favoriteItems.map((item) => (
                  <VideoCard key={item.id + item.source} query={item.search_title} {...item} from="favorite" type={item.episodes > 1 ? 'tv' : ''} />
                ))}
                {favoriteItems.length === 0 && <div className="col-span-full text-center py-20 text-gray-400">暂无收藏内容</div>}
              </div>
            </section>
          ) : (
            <>
              <ContinueWatching />

              {/* 1. Movies */}
              <section className="mb-8">
                <div className="mb-4 flex items-center justify-between">
                  <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200">热门电影</h2>
                  <Link href="/douban?type=movie" className="flex items-center text-sm text-gray-500 hover:text-gray-700">
                    查看更多 <ChevronRight className="w-4 h-4 ml-1" />
                  </Link>
                </div>
                <ScrollableRow>
                  {loading ? Array.from({ length: 12 }).map((_, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44 h-64 bg-gray-200 dark:bg-gray-800 animate-pulse rounded-lg" />
                  )) : hotMovies.slice(0, 18).map((item, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44">
                      <VideoCard from="douban" title={item.title} poster={item.poster} douban_id={Number(item.id)} rate={item.rate} year={item.year} type="movie" />
                    </div>
                  ))}
                </ScrollableRow>
              </section>

              {/* 2. TV Shows */}
              <section className="mb-8">
                <div className="mb-4 flex items-center justify-between">
                  <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200">热门剧集</h2>
                  <Link href="/douban?type=tv" className="flex items-center text-sm text-gray-500 hover:text-gray-700">
                    查看更多 <ChevronRight className="w-4 h-4 ml-1" />
                  </Link>
                </div>
                <ScrollableRow>
                  {loading ? Array.from({ length: 12 }).map((_, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44 h-64 bg-gray-200 dark:bg-gray-800 animate-pulse rounded-lg" />
                  )) : hotTvShows.slice(0, 18).map((item, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44">
                      <VideoCard from="douban" title={item.title} poster={item.poster} douban_id={Number(item.id)} rate={item.rate} year={item.year} />
                    </div>
                  ))}
                </ScrollableRow>
              </section>

              {/* 3. Anime */}
              <section className="mb-8">
                <div className="mb-4 flex items-center justify-between">
                  <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200">热门番剧</h2>
                  <Link href="/douban?type=anime" className="flex items-center text-sm text-gray-500 hover:text-gray-700">
                    查看更多 <ChevronRight className="w-4 h-4 ml-1" />
                  </Link>
                </div>
                <ScrollableRow>
                  {loading ? Array.from({ length: 12 }).map((_, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44 h-64 bg-gray-200 dark:bg-gray-800 animate-pulse rounded-lg" />
                  )) : hotAnimes.slice(0, 18).map((item, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44">
                      <VideoCard from="douban" title={item.title} poster={item.poster} douban_id={Number(item.id)} rate={item.rate} year={item.year} />
                    </div>
                  ))}
                </ScrollableRow>
              </section>

              {/* 4. Variety Shows */}
              <section className="mb-8">
                <div className="mb-4 flex items-center justify-between">
                  <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200">热门综艺</h2>
                  <Link href="/douban?type=show" className="flex items-center text-sm text-gray-500 hover:text-gray-700">
                    查看更多 <ChevronRight className="w-4 h-4 ml-1" />
                  </Link>
                </div>
                <ScrollableRow>
                  {loading ? Array.from({ length: 12 }).map((_, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44 h-64 bg-gray-200 dark:bg-gray-800 animate-pulse rounded-lg" />
                  )) : hotVarietyShows.slice(0, 18).map((item, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44">
                      <VideoCard from="douban" title={item.title} poster={item.poster} douban_id={Number(item.id)} rate={item.rate} year={item.year} />
                    </div>
                  ))}
                </ScrollableRow>
              </section>

              <DecoTVFooterCard />
            </>
          )}
        </div>
      </div>

      {/* Announcement Modal */}
      {announcement && showAnnouncement && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-in fade-in duration-300">
          <div className="w-full max-w-md rounded-xl bg-white p-6 shadow-2xl dark:bg-gray-900 animate-in zoom-in-95 duration-300">
            <div className="flex justify-between items-start mb-4">
              <h3 className="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-purple-500 via-pink-400 to-indigo-500 border-b-2 border-purple-400 pb-1">
                系统公告
              </h3>
              <button 
                onClick={() => handleCloseAnnouncement(announcement)}
                className="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <div className="mb-6">
              <div className="relative overflow-hidden rounded-lg p-4 bg-gradient-to-r from-purple-50 via-pink-50 to-indigo-50 dark:from-purple-900/20 dark:via-pink-900/20 dark:to-indigo-900/20 shadow-inner">
                <div className="absolute inset-y-0 left-0 w-1 bg-gradient-to-b from-purple-500 to-indigo-500" />
                <p className="ml-2 text-gray-700 dark:text-gray-200 leading-relaxed font-medium whitespace-pre-wrap">
                  {announcement}
                </p>
              </div>
            </div>
            <button
              onClick={() => handleCloseAnnouncement(announcement)}
              className="w-full rounded-lg bg-gradient-to-r from-purple-600 to-indigo-600 py-3 text-white font-bold shadow-lg hover:opacity-90 active:scale-95 transition-all"
            >
              我知道了
            </button>
          </div>
        </div>
      )}
    </PageLayout>
  );
}

export default function Home() {
  return (
    <Suspense fallback={<div className="min-h-screen flex items-center justify-center">Loading...</div>}>
      <HomeClient />
    </Suspense>
  );
}
```

### 清空二次确认

1. 修改继续观看组件 (src/components/ContinueWatching.tsx)

```tsx
/* eslint-disable no-console */
'use client';

import { useEffect, useState } from 'react';

import type { PlayRecord } from '@/lib/db.client';
import {
  clearAllPlayRecords,
  getAllPlayRecords,
  subscribeToDataUpdates,
} from '@/lib/db.client';

import ScrollableRow from '@/components/ScrollableRow';
import VideoCard from '@/components/VideoCard';

interface ContinueWatchingProps {
  className?: string;
}

export default function ContinueWatching({ className }: ContinueWatchingProps) {
  const [playRecords, setPlayRecords] = useState<
    (PlayRecord & { key: string })[]
  >([]);
  const [loading, setLoading] = useState(true);

  // 处理播放记录数据更新的函数
  const updatePlayRecords = (allRecords: Record<string, PlayRecord>) => {
    // 将记录转换为数组并根据 save_time 由近到远排序
    const recordsArray = Object.entries(allRecords).map(([key, record]) => ({
      ...record,
      key,
    }));

    // 按 save_time 降序排序（最新的在前面）
    const sortedRecords = recordsArray.sort(
      (a, b) => b.save_time - a.save_time
    );

    setPlayRecords(sortedRecords);
  };

  useEffect(() => {
    const fetchPlayRecords = async () => {
      try {
        setLoading(true);

        // 从缓存或API获取所有播放记录
        const allRecords = await getAllPlayRecords();
        updatePlayRecords(allRecords);
      } catch (error) {
        console.error('获取播放记录失败:', error);
        setPlayRecords([]);
      } finally {
        setLoading(false);
      }
    };

    fetchPlayRecords();

    // 修复点：显式为 allRecords 指定类型 Record<string, PlayRecord>
    const unsubscribe = subscribeToDataUpdates(
      'playRecordsUpdated',
      (allRecords: Record<string, PlayRecord>) => {
        updatePlayRecords(allRecords);
      }
    );

    return () => {
      unsubscribe();
    };
  }, []);

  // 如果没有播放记录，则不渲染组件
  if (!loading && playRecords.length === 0) {
    return null;
  }

  // 计算播放进度百分比
  const getProgress = (record: PlayRecord) => {
    if (record.total_time === 0) return 0;
    return (record.play_time / record.total_time) * 100;
  };

  // 从 key 中解析 source 和 id
  const parseKey = (key: string) => {
    const plusIndex = key.indexOf('+');
    return {
      source: key.substring(0, plusIndex),
      id: key.substring(plusIndex + 1),
    };
  };

  return (
    <section className={`mb-8 ${className || ''}`}>
      <div className='mb-4 flex items-center justify-between'>
        <h2 className='text-xl font-bold text-gray-800 dark:text-gray-200'>
          继续观看
        </h2>
        {!loading && playRecords.length > 0 && (
          <button
            className='text-sm font-medium text-gray-500 hover:text-purple-600 dark:text-gray-400 dark:hover:text-purple-400 transition-colors'
            onClick={async () => {
              // 添加确认弹窗
              if (confirm('确定清空所有观看记录吗？')) {
                await clearAllPlayRecords();
                setPlayRecords([]);
              }
            }}
          >
            清空
          </button>
        )}
      </div>
      <ScrollableRow>
        {loading
          ? Array.from({ length: 6 }).map((_, index) => (
              <div
                key={index}
                className='min-w-24 w-24 sm:min-w-45 sm:w-44'
              >
                <div className='relative aspect-2/3 w-full overflow-hidden rounded-lg bg-gray-200 animate-pulse dark:bg-gray-800'>
                  <div className='absolute inset-0 bg-gray-300 dark:bg-gray-700'></div>
                </div>
                <div className='mt-2 h-4 bg-gray-200 rounded animate-pulse dark:bg-gray-800'></div>
                <div className='mt-1 h-3 bg-gray-200 rounded animate-pulse dark:bg-gray-800'></div>
              </div>
            ))
          : playRecords.map((record) => {
              const { source, id } = parseKey(record.key);
              return (
                <div
                  key={record.key}
                  className='min-w-24 w-24 sm:min-w-45 sm:w-44'
                >
                  <VideoCard
                    id={id}
                    title={record.title}
                    poster={record.cover}
                    year={record.year}
                    source={source}
                    source_name={record.source_name}
                    progress={getProgress(record)}
                    episodes={record.total_episodes}
                    currentEpisode={record.index}
                    query={record.search_title}
                    from='playrecord'
                    onDelete={() =>
                      setPlayRecords((prev) =>
                        prev.filter((r) => r.key !== record.key)
                      )
                    }
                    type={record.total_episodes > 1 ? 'tv' : ''}
                  />
                </div>
              );
            })}
      </ScrollableRow>
    </section>
  );
}
```

2. 同步更新首页代码 (src/app/page.tsx)

```tsx
/* eslint-disable @typescript-eslint/no-explicit-any, react-hooks/exhaustive-deps, no-console */

'use client';

import { ChevronRight } from 'lucide-react';
import Link from 'next/link';
import { Suspense, useEffect, useState } from 'react';

// --- API Imports ---
import {
  clearAllFavorites,
  getAllFavorites,
  getAllPlayRecords,
  subscribeToDataUpdates,
} from '@/lib/db.client';
import { getDoubanRecommends } from '@/lib/douban.client';
import { DoubanItem } from '@/lib/types';

// --- Component Imports ---
import CapsuleSwitch from '@/components/CapsuleSwitch';
import ContinueWatching from '@/components/ContinueWatching';
import DecoTVFooterCard from '@/components/DecoTVFooterCard';
import PageLayout from '@/components/PageLayout';
import ScrollableRow from '@/components/ScrollableRow';
import { useSite } from '@/components/SiteProvider';
import VideoCard from '@/components/VideoCard';

// --- Interfaces ---
interface FavoriteItem {
  id: string;
  source: string;
  title: string;
  poster: string;
  episodes: number;
  source_name: string;
  currentEpisode?: number;
  search_title?: string;
  origin?: 'vod' | 'live';
  year?: string;
}

function HomeClient() {
  const [activeTab, setActiveTab] = useState<'home' | 'favorites'>('home');
  const [hotMovies, setHotMovies] = useState<DoubanItem[]>([]);
  const [hotTvShows, setHotTvShows] = useState<DoubanItem[]>([]);
  const [hotVarietyShows, setHotVarietyShows] = useState<DoubanItem[]>([]);
  const [hotAnimes, setHotAnimes] = useState<DoubanItem[]>([]);
  const [loading, setLoading] = useState(true);
  
  const { siteName, announcement } = useSite();
  const [showAnnouncement, setShowAnnouncement] = useState(false);
  const [favoriteItems, setFavoriteItems] = useState<FavoriteItem[]>([]);

  // Announcement logic
  useEffect(() => {
    if (typeof window !== 'undefined' && announcement) {
      const hasSeen = localStorage.getItem('hasSeenAnnouncement');
      if (hasSeen !== announcement) {
        setShowAnnouncement(true);
      }
    }
  }, [announcement]);

  // Data fetching logic
  useEffect(() => {
    const fetchAllData = async () => {
      try {
        setLoading(true);
        const [moviesRes, tvRes, varietyRes, animeRes] = await Promise.all([
          getDoubanRecommends({ kind: 'movie', pageLimit: 20, sort: 'U' }),
          getDoubanRecommends({ kind: 'tv', pageLimit: 20, format: '鐢佃鍓?, sort: 'U' }),
          getDoubanRecommends({ kind: 'tv', pageLimit: 20, format: '缁艰壓', sort: 'U' }),
          getDoubanRecommends({ kind: 'tv', pageLimit: 20, category: '鍔ㄧ敾', format: '鐢佃鍓?, sort: 'U' }),
        ]);

        if (moviesRes.code === 200) setHotMovies(moviesRes.list);
        if (tvRes.code === 200) setHotTvShows(tvRes.list);
        if (varietyRes.code === 200) setHotVarietyShows(varietyRes.list);
        if (animeRes.code === 200) setHotAnimes(animeRes.list);
      } catch (error) {
        console.error('Fetch Error:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchAllData();
  }, []);

  // Sync favorites and play records
  const updateFavoriteItems = async (allFavorites: Record<string, any>) => {
    const allPlayRecords = await getAllPlayRecords();
    const sorted = Object.entries(allFavorites)
      .sort(([, a], [, b]) => b.save_time - a.save_time)
      .map(([key, fav]) => {
        const plusIndex = key.indexOf('+');
        const source = key.slice(0, plusIndex);
        const id = key.slice(plusIndex + 1);
        const playRecord = allPlayRecords[key];
        
        return {
          id,
          source,
          title: fav.title,
          year: fav.year,
          poster: fav.cover,
          episodes: fav.total_episodes,
          source_name: fav.source_name,
          currentEpisode: playRecord?.index,
          search_title: fav?.search_title,
          origin: fav?.origin,
        } as FavoriteItem;
      });
    setFavoriteItems(sorted);
  };

  useEffect(() => {
    if (activeTab !== 'favorites') return;
    const loadFavorites = async () => {
      const allFavorites = await getAllFavorites();
      await updateFavoriteItems(allFavorites);
    };
    loadFavorites();
    const unsubscribe = subscribeToDataUpdates('favoritesUpdated', (newFavs: any) => {
      updateFavoriteItems(newFavs);
    });
    return unsubscribe;
  }, [activeTab]);

  const handleCloseAnnouncement = (msg: string) => {
    setShowAnnouncement(false);
    localStorage.setItem('hasSeenAnnouncement', msg);
  };

  return (
    <PageLayout>
      {/* Visual Header Section */}
      <div className="relative pt-20 pb-10 sm:pt-32 sm:pb-16 overflow-hidden">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-75 h-75 sm:w-150 sm:h-150 bg-purple-500/20 rounded-full blur-[80px] sm:blur-[120px] -z-10 pointer-events-none animate-pulse" />
        <div className="flex flex-col items-center justify-center text-center px-4">
          <div className="relative group">
            <h1 className="text-6xl sm:text-8xl font-black tracking-tighter deco-brand drop-shadow-2xl select-none transition-transform duration-500 group-hover:scale-105">
              {siteName || 'DecoTV'}
            </h1>
            <div className="absolute -inset-8 bg-gradient-to-r from-blue-500/20 via-purple-500/20 to-pink-500/20 blur-2xl -z-10 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
          </div>
          <div className="mt-8 animate-fade-in-up">
            <div className="inline-flex items-center gap-3 px-6 py-2.5 rounded-full bg-white/50 dark:bg-black/30 backdrop-blur-md border border-white/20 dark:border-white/10 shadow-lg">
              <span className="text-base sm:text-lg font-medium text-gray-800 dark:text-gray-100">鍙戠幇</span>
              <span className="w-1 h-1 rounded-full bg-gray-300 dark:bg-gray-600" />
              <span className="text-base sm:text-lg font-medium text-gray-800 dark:text-gray-100">鏀惰棌</span>
              <span className="w-1 h-1 rounded-full bg-gray-300 dark:bg-gray-600" />
              <span className="text-base sm:text-lg font-medium text-gray-800 dark:text-gray-100">缁х画瑙傜湅</span>
            </div>
          </div>
        </div>
      </div>

      <div className="px-2 sm:px-10 py-4 sm:py-8">
        {/* Tab Switcher */}
        <div className="mb-8 flex justify-center">
          <CapsuleSwitch
            options={[{ label: '棣栭〉', value: 'home' }, { label: '鏀惰棌澶?, value: 'favorites' }]}
            active={activeTab}
            onChange={(v) => setActiveTab(v as any)}
          />
        </div>

        <div className="max-w-[95%] mx-auto">
          {activeTab === 'favorites' ? (
            /* --- Favorites View --- */
            <section className="mb-8">
              <div className="mb-4 flex items-center justify-between">
                <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200">鎴戠殑鏀惰棌澶?/h2>
                {favoriteItems.length > 0 && (
                  <button 
                    className="text-sm font-medium text-gray-500 hover:text-purple-600 dark:text-gray-400 dark:hover:text-purple-400 transition-colors"
                    onClick={async () => { 
                      if(confirm('纭畾娓呯┖鎵€鏈夋敹钘忚褰曞悧锛?)) { 
                        await clearAllFavorites(); 
                        setFavoriteItems([]); 
                      } 
                    }}
                  >
                    娓呯┖
                  </button>
                )}
              </div>
              <div className="grid grid-cols-3 gap-x-2 gap-y-14 sm:grid-cols-[repeat(auto-fill,minmax(11rem,1fr))] sm:gap-x-8 sm:gap-y-20">
                {favoriteItems.map((item) => (
                  <VideoCard key={item.id + item.source} query={item.search_title} {...item} from="favorite" type={item.episodes > 1 ? 'tv' : ''} />
                ))}
                {favoriteItems.length === 0 && (
                  <div className="col-span-full text-center py-20 text-gray-400">鏆傛棤鏀惰棌鍐呭</div>
                )}
              </div>
            </section>
          ) : (
            <>
              {/* --- Home Sections --- */}
              <ContinueWatching />

              {/* 1. Movies */}
              <section className="mb-8">
                <div className="mb-4 flex items-center justify-between">
                  <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200">鐑棬鐢靛奖</h2>
                  <Link href="/douban?type=movie" className="flex items-center text-sm text-gray-500 hover:text-gray-700">
                    鏌ョ湅鏇村 <ChevronRight className="w-4 h-4 ml-1" />
                  </Link>
                </div>
                <ScrollableRow>
                  {loading ? Array.from({ length: 12 }).map((_, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44 h-64 bg-gray-200 dark:bg-gray-800 animate-pulse rounded-lg" />
                  )) : hotMovies.slice(0, 18).map((item, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44">
                      <VideoCard from="douban" title={item.title} poster={item.poster} douban_id={Number(item.id)} rate={item.rate} year={item.year} type="movie" />
                    </div>
                  ))}
                </ScrollableRow>
              </section>

              {/* 2. TV Shows */}
              <section className="mb-8">
                <div className="mb-4 flex items-center justify-between">
                  <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200">鐑棬鍓ч泦</h2>
                  <Link href="/douban?type=tv" className="flex items-center text-sm text-gray-500 hover:text-gray-700">
                    鏌ョ湅鏇村 <ChevronRight className="w-4 h-4 ml-1" />
                  </Link>
                </div>
                <ScrollableRow>
                  {loading ? Array.from({ length: 12 }).map((_, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44 h-64 bg-gray-200 dark:bg-gray-800 animate-pulse rounded-lg" />
                  )) : hotTvShows.slice(0, 18).map((item, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44">
                      <VideoCard from="douban" title={item.title} poster={item.poster} douban_id={Number(item.id)} rate={item.rate} year={item.year} />
                    </div>
                  ))}
                </ScrollableRow>
              </section>

              {/* 3. Anime */}
              <section className="mb-8">
                <div className="mb-4 flex items-center justify-between">
                  <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200">鐑棬鐣墽</h2>
                  <Link href="/douban?type=anime" className="flex items-center text-sm text-gray-500 hover:text-gray-700">
                    鏌ョ湅鏇村 <ChevronRight className="w-4 h-4 ml-1" />
                  </Link>
                </div>
                <ScrollableRow>
                  {loading ? Array.from({ length: 12 }).map((_, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44 h-64 bg-gray-200 dark:bg-gray-800 animate-pulse rounded-lg" />
                  )) : hotAnimes.slice(0, 18).map((item, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44">
                      <VideoCard from="douban" title={item.title} poster={item.poster} douban_id={Number(item.id)} rate={item.rate} year={item.year} />
                    </div>
                  ))}
                </ScrollableRow>
              </section>

              {/* 4. Variety Shows */}
              <section className="mb-8">
                <div className="mb-4 flex items-center justify-between">
                  <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200">鐑棬缁艰壓</h2>
                  <Link href="/douban?type=show" className="flex items-center text-sm text-gray-500 hover:text-gray-700">
                    鏌ョ湅鏇村 <ChevronRight className="w-4 h-4 ml-1" />
                  </Link>
                </div>
                <ScrollableRow>
                  {loading ? Array.from({ length: 12 }).map((_, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44 h-64 bg-gray-200 dark:bg-gray-800 animate-pulse rounded-lg" />
                  )) : hotVarietyShows.slice(0, 18).map((item, i) => (
                    <div key={i} className="min-w-24 w-24 sm:min-w-45 sm:w-44">
                      <VideoCard from="douban" title={item.title} poster={item.poster} douban_id={Number(item.id)} rate={item.rate} year={item.year} />
                    </div>
                  ))}
                </ScrollableRow>
              </section>

              <DecoTVFooterCard />
            </>
          )}
        </div>
      </div>

      {/* --- Announcement Modal --- */}
      {announcement && showAnnouncement && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-in fade-in duration-300">
          <div className="w-full max-w-md rounded-xl bg-white p-6 shadow-2xl dark:bg-gray-900 animate-in zoom-in-95 duration-300">
            <div className="flex justify-between items-start mb-4">
              <h3 className="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-purple-500 via-pink-400 to-indigo-500 border-b-2 border-purple-400 pb-1">
                绯荤粺鍏憡
              </h3>
              <button 
                onClick={() => handleCloseAnnouncement(announcement)}
                className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <div className="mb-6">
              <div className="relative overflow-hidden rounded-lg p-4 bg-gradient-to-r from-purple-50 via-pink-50 to-indigo-50 dark:from-purple-900/20 dark:via-pink-900/20 dark:to-indigo-900/20 shadow-inner">
                <div className="absolute inset-y-0 left-0 w-1 bg-gradient-to-b from-purple-500 to-indigo-500" />
                <p className="ml-2 text-gray-700 dark:text-gray-200 leading-relaxed font-medium whitespace-pre-wrap">
                  {announcement}
                </p>
              </div>
            </div>
            <button
              onClick={() => handleCloseAnnouncement(announcement)}
              className="w-full rounded-lg bg-gradient-to-r from-purple-600 to-indigo-600 py-3 text-white font-bold shadow-lg hover:opacity-90 active:scale-95 transition-all"
            >
              鎴戠煡閬撲簡
            </button>
          </div>
        </div>
      )}
    </PageLayout>
  );
}

export default function Home() {
  return (
    <Suspense fallback={<div className="min-h-screen flex items-center justify-center">Loading...</div>}>
      <HomeClient />
    </Suspense>
  );
}
```

---

**AI提问：**

**标题：开发 [功能名称] 组件，要求实时数据同步与交互一致性**

**1. 功能背景：** 我正在使用 Next.js (App Router) 开发一个 [例如：收藏夹/播放历史] 模块。数据存储在客户端的 [例如：IndexedDB/localStorage] 中。

**2. 核心逻辑要求：**

- **数据获取与排序**：初始化时从数据库获取所有记录。如果记录中有 `save_time`，请按时间倒序排列（最新的在前）。
- **实时同步**：必须使用 `subscribeToDataUpdates` 订阅模式。当数据库发生变化（如 `playRecordsUpdated` 事件）时，组件能自动更新状态。
- **空状态处理**：如果数据为空且不在加载中，则不渲染任何内容。

**3. 交互与 UI 要求：**

- **清空功能**：在标题右侧添加一个“清空”按钮，样式参考 `text-gray-500 hover:text-purple-600`。
- **二次确认**：点击清空时，必须弹出 `confirm()` 确认框，用户确认后再执行清空数据库和更新状态的操作。
- **Skeleton 加载**：在数据加载期间，显示占位动画（骨架屏），并保持与列表项相同的容器尺寸。

**4. 技术细节与安全性：**

- **TypeScript 规范**：请确保所有回调函数的参数都有明确的类型定义，禁止使用 `any` 或 `unknown`（避免 Docker 构建时出现类型检查错误）。
- **生命周期管理**：在 `useEffect` 卸载时，必须调用 `unsubscribe` 函数防止内存泄漏。
- **代码风格**：使用 `client component` 模式，禁止 console 日志输出。

## 去空格搜索

方法如上，还是问[gemini](https://gemini.google.com/app)：，上传`/src/app/api/search`下面的5个路由文件，**提问**：

**标题：解决后端存储与前端搜索关键词的“空格不敏感”聚合问题**

**1. 现状描述：**

> “我的系统中有一个视频搜索功能，后端使用 Kvrocks（兼容 Redis）存储。目前发现一个 Bug：当用户搜索带空格的关键词（如‘剑来 第二季’）和不带空格的关键词（如‘剑来第二季’）时，返回的播放源数量不一致。带空格的链接能搜到更多源，而无空格的链接漏掉了很多源。”

**2. 提供核心代码：**

> “这是我处理搜索的核心文件：
>
> - `route.ts` / `ws.route.ts`：负责发起搜索请求。
> - `one.route.ts`：负责在播放页精准匹配特定源。
> - `suggestions.route.ts`：负责搜索建议。 （此处粘贴你之前的代码片段）”

**3. 明确逻辑预期：**

> “我希望实现以下效果：
>
> - **搜索阶段**：无论用户输入是否有空格，都能同时查询带空格和不带空格的 Key。
> - **过滤阶段**：在对比标题时，自动忽略空格和大小写，实现‘脱水匹配’。
> - **展示阶段**：依然保留数据库原始的标题显示格式，不要修改原始数据。
>
> 请告诉我为了实现这个‘全链路空格容错’，我需要分别修改这几个文件的哪些位置？”

## 加空格搜索

方法如上，还是问[gemini](https://gemini.google.com/app)：，上传`/src/app/api/search`下面的5个路由文件，**提问**：

**提示词：** 我正在修改一个视频搜索的 API 逻辑，代码在 `route.ts` 中。

**1. 上下文：** > 当前逻辑通过 `normalizedQuery` 和 `query` 生成一个 `searchQueries` 数组进行并发搜索。

**2. 核心需求：** > 我需要优化搜索关键词的生成逻辑。如果用户输入类似“剑来第二季”这种“名称+第x季/部”的标题，系统应该同时搜索两个版本：

- **原版/紧凑版**：例如“剑来第二季”
- **带空格版本**：例如“剑来 第二季”

**3. 逻辑要求：**

- 请使用正则表达式匹配“第[数字]季/部”。
- 同时保留现有的“空格合并”逻辑（将带空格的词转为不带空格的词）。
- 使用 `Set` 或 `includes` 检查进行去重，防止重复搜索。
- 也要对原始输入（`query`）和简体化输入（`normalizedQuery`）同时做这种处理。

请给出这部分逻辑的整体替换代码。

---

~~如果你希望效果更完美（包含联想词）：~~

~~你可以在提问最后加上：~~

> ~~“同时，请帮我修改 `suggestions.route.ts` 的逻辑，让搜索建议在返回结果时，如果发现匹配季数的内容，自动补全另一种（带空格或不带空格）的建议项。”~~

## 禁止访问指定网页

### 项目根目录新建middleware.ts

```
// middleware.ts （放在项目根目录）
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// 禁止关键词列表（支持多个）
const BANNED_KEYWORDS = [
  'AAA',
  'BBB',  
  // '另一个禁止标题',
];

export function middleware(request: NextRequest) {
  // 直接获取 title 参数（Next.js 已自动解码汉字）
  const title = request.nextUrl.searchParams.get('title');

  // 检查 title 是否包含禁止关键词（不区分大小写）
  if (title) {
    const lowerTitle = title.toLowerCase();
    const isBanned = BANNED_KEYWORDS.some(keyword =>
      lowerTitle.includes(keyword.toLowerCase())
    );

    if (isBanned) {
      // 返回 404（推荐使用自定义页面）
      return NextResponse.rewrite(new URL('/404', request.url));
      // 或使用内置：return new Response('Not Found', { status: 404 });
    }
  }

  // 正常通过
  return NextResponse.next();
}

// 确保对所有路径生效（特别是 /play）
export const config = {
  matcher: '/:path*',
};
```

### 创建自定义 404 页面（app/404.tsx）

```
// app/404.tsx
import Link from 'next/link';

export default function Custom404() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-50 dark:bg-gray-900">
      <h1 className="text-6xl font-bold text-red-600 mb-6">404</h1>
      <p className="text-2xl mb-8">页面不存在或已被禁止访问</p>
      <Link href="/" className="px-8 py-4 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
        返回首页
      </Link>
    </div>
  );
}
```

这样，当访问包含 title=AAA（无论是否编码）的链接时，都会直接显示 404 页面，且真实返回 404 状态码。

## 移除版本检测

问[Gemini](https://gemini.google.com/app)：怎样修改才能使目标仓库无论何时更新，v0.8都是最新版本

答：方案二：锁定本地时间戳为“未来时间”

如果您不想改动函数逻辑，可以通过设置一个**极大**的时间戳来欺骗系统。版本检测模块通过 `YYYYMMDDHHMMSS` 格式进行 `BigInt` 比较 

1. **修改 `VERSION.txt`：** 将其改为一个远未来的时间（例如 2099 年） 。
   + 内容改为：`20991231235959`
2. **修改 `version.ts` 中的 `BUILD_TIMESTAMP`：** 确保回退值也足够大。
   - 修改为：`export const BUILD_TIMESTAMP = '20991231235959';`

## 固定V0.9版本

V0.9版本最快

1.新建仓库，如：https://github.com/iwyang/yangtv

2.创建 github 访问 token，并添加到仓库环境变量，名称为`YANGTV`（方法见上）

3.下载V0.9源码到本地

4.修改 docker-image.yml

```yaml
name: Build & Push Docker Image

on:
  workflow_dispatch:
    inputs:
      tag:
        description: 'Docker 标签'
        required: false
        default: 'latest'
        type: string
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

permissions:
  contents: write
  packages: write
  actions: write

jobs:
  build:
    strategy:
      matrix:
        include:
          - platform: linux/amd64
            os: ubuntu-latest
          - platform: linux/arm64
            os: ubuntu-24.04-arm
    runs-on: ${{ matrix.os }}

    steps:
      - name: Prepare platform identifier
        id: platform
        run: |
          PLATFORM_ID=$(echo "${{ matrix.platform }}" | sed 's|/|-|g')
          echo "id=${PLATFORM_ID}" >> $GITHUB_OUTPUT

      - name: Checkout source code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.YANGTV }}

      - name: Set lowercase repository owner
        id: lowercase
        run: echo "owner=$(echo '${{ github.repository_owner }}' | tr '[:upper:]' '[:lower:]')" >> "$GITHUB_OUTPUT"

      - name: Extract version from package.json
        id: version
        run: |
          VERSION=$(node -p "require('./package.json').version")
          echo "version=v${VERSION}" >> "$GITHUB_OUTPUT"
          echo "Detected version: v${VERSION}"

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4

        with:
          images: ghcr.io/${{ steps.lowercase.outputs.owner }}/yangtv
          tags: |
            type=raw,value=${{ github.event.inputs.tag || 'latest' }},enable={{is_default_branch}}
            type=raw,value=${{ steps.version.outputs.version }},enable={{is_default_branch}}

      - name: Build and push by digest
        id: build
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./Dockerfile
          platforms: ${{ matrix.platform }}
          labels: ${{ steps.meta.outputs.labels }}
          tags: |
            ghcr.io/${{ steps.lowercase.outputs.owner }}/yangtv:${{ github.event.inputs.tag || 'latest' }}
            ghcr.io/${{ steps.lowercase.outputs.owner }}/yangtv:${{ steps.version.outputs.version }}
          outputs: type=image,name=ghcr.io/${{ steps.lowercase.outputs.owner }}/yangtv,name-canonical=true,push=true

      - name: Export digest
        run: |
          mkdir -p /tmp/digests
          digest="${{ steps.build.outputs.digest }}"
          touch "/tmp/digests/${digest#sha256:}"

      - name: Upload digest
        uses: actions/upload-artifact@v4
        with:
          name: digests-${{ steps.platform.outputs.id }}
          path: /tmp/digests/*
          if-no-files-found: error
          retention-days: 1

  merge:
    runs-on: ubuntu-latest
    needs:
      - build
    steps:
      - name: Download digests
        uses: actions/download-artifact@v4
        with:
          path: /tmp/digests
          pattern: digests-*
          merge-multiple: true

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.YANGTV }}

      - name: Set lowercase repository owner
        id: lowercase
        run: echo "owner=$(echo '${{ github.repository_owner }}' | tr '[:upper:]' '[:lower:]')" >> "$GITHUB_OUTPUT"

      - name: Download package.json
        uses: actions/checkout@v4
        with:
          sparse-checkout: |
            package.json
          sparse-checkout-cone-mode: false

      - name: Extract version from package.json
        id: version
        run: |
          VERSION=$(node -p "require('./package.json').version")
          echo "version=v${VERSION}" >> "$GITHUB_OUTPUT"
          echo "Detected version: v${VERSION}"

      - name: Create manifest list and push
        working-directory: /tmp/digests
        run: |
          docker buildx imagetools create -t ghcr.io/${{ steps.lowercase.outputs.owner }}/yangtv:${{ github.event.inputs.tag || 'latest' }} \
            $(printf 'ghcr.io/${{ steps.lowercase.outputs.owner }}/yangtv@sha256:%s ' *)
          docker buildx imagetools create -t ghcr.io/${{ steps.lowercase.outputs.owner }}/yangtv:${{ steps.version.outputs.version }} \
            $(printf 'ghcr.io/${{ steps.lowercase.outputs.owner }}/yangtv@sha256:%s ' *)

  cleanup-refresh:
    runs-on: ubuntu-latest
    needs:
      - merge
    if: always()
    steps:
      - name: Delete workflow runs
        uses: Mattraks/delete-workflow-runs@main
        with:
          token: ${{ secrets.YANGTV }}
          repository: ${{ github.repository }}
          retain_days: 0
          keep_minimum_runs: 2
```

6.本地进行其他修改，见上

7.提交源码到第一步新建的仓库

```
git init
git checkout -b main
git remote add origin git@github.com:iwyang/yangtv.git
git add .
git commit -m "首次提交"
git push --force origin main
```

8.修改 `docker-compose.yml` 文件

**注意修改自己的密码**

```
vi docker-compose.yml
```

```yaml
services:
  yangtv-core:
    image: ghcr.io/iwyang/yangtv:latest
    container_name: yangtv-core
    restart: always  # You can keep 'unless-stopped' or 'always' as preferred
    ports:
      - '3000:3000'
    environment:
      - USERNAME=admin
      - PASSWORD=你的密码
      - NEXT_PUBLIC_STORAGE_TYPE=kvrocks
      - KVROCKS_URL=redis://yangtv-kvrocks:6666
      - NEXT_PUBLIC_DISABLE_YELLOW_FILTER=false
    networks:
      - yangtv-network
    depends_on:
      - yangtv-kvrocks

  yangtv-kvrocks:
    image: apache/kvrocks
    container_name: yangtv-kvrocks
    restart: always  # You can keep 'unless-stopped' or 'always' as preferred
    volumes:
      - kvrocks-data:/var/lib/kvrocks
    networks:
      - yangtv-network

  watchtower:
    image: containrrr/watchtower
    container_name: watchtower-yangtv
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 86400 --cleanup
    restart: always  # You can keep 'unless-stopped' or 'always' as preferred

networks:
  yangtv-network:
    driver: bridge

volumes:
  kvrocks-data:
```

## 参考链接

+ [如何在 debian 10 中安装和使用 Docker](https://www.sunqi.org/debian-10-install-docker.html)
+ [Debian 11 安装 Docker & Docker Compose](https://6xyun.cn/article/137)
+ [实用教程Debian 10系统中安装Docker Compose过程](https://www.itbulu.com/docker-compose.html)
+ [Docker 容器开机自启](https://www.jianshu.com/p/36f63f57b05d)
+ [docker-compose 关机或者重启docker同时重启容器restart always的配置](https://blog.csdn.net/fjh1997/article/details/98880638)
+ [如何删除 Docker 镜像和容器](https://chinese.freecodecamp.org/news/how-to-remove-images-in-docker/)
