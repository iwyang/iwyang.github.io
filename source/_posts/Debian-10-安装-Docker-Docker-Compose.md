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
cd /root/data/docker_data/joplin  # 进入docker-compose所在的文件夹

docker-compose down    # 停止容器，此时不会删除映射到本地的数据

rm -rf /root/data/docker_data/joplin  # 完全删除映射到本地的数据
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
docker image prune
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

服务器拉取最新镜像：

```
cd /root/docker/tv
docker-compose pull
docker-compose up -d
docker image prune
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

方法如上，还是用[grok](https://grok.com/)，提问：此页面默认显示源的所有分类，怎样修改，才能一些分类不显示，如A和B这2个分类不显示

**注意：会省略代码，要反复确认是否是完整代码，有没有省略，尤其是部署失败的时候**，也可下载日志文件，找到失败那一步，复制错误日志给ai分析

## 搜索屏蔽指定违禁词

方法如上，还是用[grok](https://grok.com/)，上传`/src/app/api/search`下面的5个路由文件，**提问**：怎样修改才能实现搜索屏蔽指定关键词，搜索违禁词时，直接跳过搜索，返回空结果。给我完整文件，不要省略代码。

根据回答，可能会**继续提问**：新建一个 filter.ts，专门设置违禁词，其他4个文件应用就行，改改，要完整代码，文件开头注释修改的是哪个文件。

**注意：会省略代码，要反复确认是否是完整代码，有没有省略，尤其是部署失败的时候**，也可下载日志文件，找到失败那一步，复制错误日志给ai分析

## 比较屏蔽关键词逻辑

上传两个TV`src\app\api\search\ws\route.ts`下两个文件，比较一下。(因为我觉得[grok](https://grok.com/)给了两种不同屏蔽关键词方法。)

提问：比较这两个文件，分析一下，两者搜索逻辑有什么区别

答：

### 总体结构相似点

两个文件都是 Next.js 的 API 路由（GET 方法），处理搜索请求，使用 ReadableStream 实现流式响应（SSE: Server-Sent Events）。它们都：

- 检查用户认证（使用 getAuthInfoFromCookie），未认证返回 401。
- 从查询参数 'q' 获取搜索关键词，如果为空返回 400。
- 获取站点配置（getConfig）和可用 API 站点（getAvailableApiSites）。
- 对于每个 API 站点，使用 Promise.race 实现 20 秒超时搜索（searchFromApi）。
- 发送事件流，包括 'start'（搜索开始）、'source_result'（每个源的结果）、'source_error'（源错误）和 'complete'（完成）。
- 收集所有结果（allResults），在 'complete' 事件中报告 totalResults 和 completedSources。
- 处理流关闭（cancel 方法设置 streamClosed）。
- 使用 safeEnqueue 来安全推送数据到流，避免已关闭的流出错。
- 响应头包括 'text/event-stream'、'no-cache' 和 'keep-alive'。

### 搜索逻辑区别

以下是两个文件在搜索逻辑上的关键差异，按流程顺序分析：

1. 查询预处理（Query Normalization）
   - **l.route.ts**: 直接使用原查询（query = searchParams.get('q')?.trim()），无额外处理。如果查询为空，直接返回错误响应。
   - **d.route.ts**: 使用 toSimplified 将查询转换为简体中文（normalizedQuery），如果转换失败则警告但继续。如果 normalizedQuery 与原 query 不同，则创建 searchQueries 数组（[normalizedQuery, query]），并对每个查询分别搜索。这允许支持繁简体混合搜索，提高覆盖率。'start' 事件中额外包含 normalizedQuery 字段。
2. 黑名单/敏感关键词检查
   - **l.route.ts**: 在搜索前显式检查 blockedKeywords（导入自 '@/lib/blockedKeywords'），如果查询包含任何黑名单词，直接返回一个空结果流：发送 'complete' 事件（totalResults: 0, error: '搜索内容受限，已被屏蔽'），不进行任何 API 调用。这是一种前置硬屏蔽，针对赌博等关键词（文件注释提到 "新增：关键词黑名单检查"）。
   - **d.route.ts**: 没有前置黑名单检查，但文件注释提到 "已添加赌博关键词屏蔽"。屏蔽逻辑集成在 filterSensitiveContent 函数中（传入 shouldFilterAdult 和 apiSites），这发生在搜索结果获取后。可能更灵活，能过滤结果而非整个查询，但如果关键词敏感，可能导致部分或全部结果被过滤，而不是直接拒绝搜索。
3. 搜索执行（Per-Site Search）
   - **l.route.ts**: 对每个站点只搜索一次（使用原 query）。结果直接处理，无去重。
   - **d.route.ts**: 对每个站点，使用 searchQueries 数组分别搜索（可能多次，如果繁简不同），然后 flat() 平展结果数组。使用 Map 基于结果的 id 去重（uniqueMap.set(r.id, r)），避免重复项。这提高了结果的唯一性和完整性，尤其在繁简查询可能返回重叠结果时。
4. 结果过滤（Filtering）
   - **l.route.ts**: 如果 !config.SiteConfig.DisableYellowFilter，则过滤结果：检查 result.type_name 是否包含 yellowWords（导入自 '@/lib/yellow'）中的词，过滤掉匹配项。这是一种简单的字符串包含检查，针对"黄色"（成人）内容。
   - **d.route.ts**: 使用 shouldFilterAdult = !config.SiteConfig.DisableYellowFilter 来决定是否过滤成人内容，但实际过滤通过 filterSensitiveContent 函数实现（导入自 '@/lib/filter'），传入 results、shouldFilterAdult 和 apiSites。这可能更全面，包括成人内容、赌博关键词或其他敏感过滤（基于 apiSites 可能有站点特定规则）。过滤发生在去重后。
5. 结果排序（Ranking）
   - **l.route.ts**: 无排序逻辑，直接使用过滤后的结果。
   - **d.route.ts**: 在过滤后，使用 rankSearchResults（导入自 '@/lib/search-ranking'）对结果排序，传入 filteredResults 和 normalizedQuery。这引入了相关性排序，可能基于关键词匹配度、流行度等，提高结果质量。
6. 事件数据细节
   - **l.route.ts**: 事件包含更多元数据，如 timestamp（每个事件都有）。'source_result' 和 'source_error' 包含 sourceName、results/error 和 timestamp。'complete' 包含 totalResults、completedSources、timestamp（黑名单情况下额外有 error）。
   - **d.route.ts**: 事件数据更简洁，无 timestamp。'start' 包含 normalizedQuery 和 totalSources。'source_result' 只包含 source、sourceName、results。'complete' 只包含 totalResults 和 completedSources。
7. 错误和超时处理
   - 两者类似：捕获错误，发送 'source_error'。但 l.route.ts 在警告中打印更多细节（如 console.warn(搜索失败 ${site.name}:, error)）。
   - l.route.ts 在 safeEnqueue 中有更多错误处理（检查 controller.desiredSize，捕获 enqueue 错误）。
8. 响应头和杂项
   - **l.route.ts**: 额外添加 CORS 头（如 'Access-Control-Allow-Origin': '*'），允许跨域。运行时指定 'nodejs'。
   - **d.route.ts**: 无 CORS 头，可能假设同域使用。也有 'nodejs' 运行时。

### 潜在影响

- **l.route.ts** 更注重前置屏蔽和简单过滤，适合快速拒绝非法查询，但可能遗漏繁体支持和结果优化。搜索效率较高（单查询），但结果可能重复或无关。
- **d.route.ts** 更注重结果质量（繁简支持、去重、排序、综合过滤），适合中文搜索场景，但可能增加延迟（多查询）和复杂性。过滤后置，可能允许敏感查询部分执行，但最终结果被屏蔽。
- 总体上，d.route.ts 似乎是 l.route.ts 的演进版，添加了更多中文优化和敏感内容处理（赌博屏蔽集成在过滤中）。

### 以后提问方式

如果项目搜索文件改了，处理合并冲突时，舍弃更改，保持之前的更改。然后将以前的几个搜索文件给grok，先叫它分析这几个文件的搜索逻辑，然后把项目新的搜索文件给它，提问：修改这几个文件，使它们的搜索逻辑跟上面文件一样，最终实现搜索屏蔽制定关键词。

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

## 参考链接

+ [如何在 debian 10 中安装和使用 Docker](https://www.sunqi.org/debian-10-install-docker.html)
+ [Debian 11 安装 Docker & Docker Compose](https://6xyun.cn/article/137)
+ [实用教程Debian 10系统中安装Docker Compose过程](https://www.itbulu.com/docker-compose.html)
+ [Docker 容器开机自启](https://www.jianshu.com/p/36f63f57b05d)
+ [docker-compose 关机或者重启docker同时重启容器restart always的配置](https://blog.csdn.net/fjh1997/article/details/98880638)
+ [如何删除 Docker 镜像和容器](https://chinese.freecodecamp.org/news/how-to-remove-images-in-docker/)





## 
