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

**怎样修改，才能实现：**

 1. 默认分类与排序（所有页面统一逻辑）

- 电影 / 电视剧 / 综艺页面

  （type = movie / tv / show）：

  - 默认一级分类：**“全部”**
  - 默认排序：**近期热度**（sort = 'U'）
  - 数据请求默认按近期热度加载

- 动漫页面

  （type = anime）：

  - 默认一级分类：**“番剧”**（不再是“每日放送”）
  - 默认排序：**近期热度**（sort = 'U'）
  - 数据请求默认按近期热度加载（使用豆瓣推荐接口）

2. “排序”胶囊按钮显示逻辑（所有页面完全一致）

- 首次进入页面或切换任何分类时

  （包括切到番剧/剧场版）：

  - 胶囊按钮始终显示 **“排序”**（灰色文字）

- 下拉菜单默认高亮

  - 所有页面（电影/电视剧/综艺/番剧/剧场版）→ 高亮 **“近期热度”**（绿色背景+文字+边框）

- 用户手动选择排序后

  - 选择 **“综合排序”** → 胶囊按钮显示 **“排序”**（灰色文字）
  - 选择 **“近期热度” / “首映时间 / 首播时间” / “高分优先”** → 胶囊按钮显示对应具体名称（如“近期热度”），文字变为**绿色**

3. 其他筛选器行为（类型、地区、年代、平台）

- 默认显示分类名（如“类型”、“地区”）
- 选择后显示具体选项名称并变绿（标准行为）

4. 整体交互与体验

- 默认状态极简干净：所有胶囊显示分类名（“排序”永远是默认显示）
- 用户操作反馈清晰：只有选择非“综合排序”时才显示具体排序名称 + 绿色高亮
- 切换分类（包括番剧 ↔ 剧场版）时自动重置为默认状态（显示“排序”，高亮“近期热度”）
- 数据加载准确：所有页面默认按近期热度请求，用户选择后实时切换
- 动漫“每日放送”分类仍保留，但默认不再进入该分类（可手动切换）

## 播放页面源模糊匹配



### 以后提问方式

如果项目搜索文件改了，处理合并冲突时，舍弃更改，保持之前的更改。然后将以前的几个搜索文件给grok，先叫它分析这几个文件的搜索逻辑，然后把项目新的搜索文件给它，提问：修改这几个文件，使它们的搜索逻辑跟上面文件一样，最终实现搜索屏蔽制定关键词。

## 禁止访问指定网页

还是用[grok](https://grok.com/)，上传`yangtv`和`lunatv`'`\src\app\play\page.tsx`文件，**提问**：

+ 为什么yangtv开头的文件在播放“疯狂动物城2”时，不会显示“疯狂动物城2 国语版”的源；而lunatv开头的文件播放时会显示“疯狂动物城2 国语版”的源

分析完原因后**接着提问**：

+ 怎样修改才能使yangtv在播放“疯狂动物城2”时，也会显示“疯狂动物城2 国语版”的源，给我完整代码，不要省略

如果代码太长，不好生成，**接着提问**：

+ 教我如何修改原文件

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
