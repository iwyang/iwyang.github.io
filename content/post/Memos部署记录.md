---
title: Memos部署记录
categories:
  - 技术
tags:
  - hexo
comments: true
cover: /img/cover/memos.jpg
slug: d5e37958
date: 2022-09-20 19:44:19
sticky:
keywords:
description:
top_img:
---

> Memos是什么：一个开源的、支持私有化部署的碎片化知识卡片管理工具。可以说是支持 Docker 自部署的 flomo
>
> 官网：https://usememos.com/
>
> 仓库地址：https://github.com/usememos/memos
>

## Docker部署

```
docker run -d --name memos -p 5230:5230 -v ~/.memos/:/var/opt/memos neosmemo/memos:latest
```

## Docker Compose部署

1.创建 Memos 工作目录

```
mkdir memos && cd memos
vi docker-compose.yaml
```

2.编写 `docker-compose.yaml` 文件：

```yaml
version: "3.0"
services:
  memos:
    image: neosmemo/memos:latest
    restart: always 
    container_name: memos
    volumes:
      - ~/.memos/:/var/opt/memos
    ports:
      - 5230:5230
```

更多参考：[`docker-compose.yaml`](https://github.com/usememos/memos/blob/main/docker-compose.yaml)

3.执行命令，`Memos` 后端程序将运行在 `http://localhost:端口号`

```
docker-compose up -d
```

通过访问 `localhost:5230` 即可打开 Memos，首次安装会提示注册用户，请记牢您的而密码。数据文件默认存储在 **`~/.memos`** 中。

> PS：如果使用vultr，注意由于默认vultr什么端口都没有开放，安装后要记得要开放5230端口：

```
iptables -I INPUT -p tcp --dport 5230 -j ACCEPT
```

4.**更新**。删除现有容器，拉取最新镜像，然后重新创建容器即可。

**Docker Compose**

```
cd memos
docker-compose down  
docker-compose pull
docker-compose up -d
```

> 可选命令：
>
> `cp -r /root/.memos /root/.memos.archive`  事先备份，以防万一（将`/root/.memos`文件夹下的数据库复制到`/root/.memos.archive`文件夹下）
>
> `docker image prune ` 用来删除不再使用的 docker 对象。删除所有未被 tag 标记和未被容器使用的镜像
>
> 提示：
>
> ```
> WARNING! This will remove all dangling images.
> Are you sure you want to continue? [y/N] 
> ```

**Docker**

```yaml
docker stop memos

docker rm -f memos

cp -r /root/data/docker_data/memos/.memos /root/data/docker_data/memos/.memos.archive  # 万事先备份，以防万一

docker pull neosmemo/memos:latest  # 拉取最新镜像

docker run -it -d \
  --name memos \
  --publish 5230:5230 \
  --volume /root/data/docker_data/memos/.memos/:/var/opt/memos \
  neosmemo/memos:latest \
  --mode prod \
  --port 5230
```

> `/root/data/docker_data/memos/.memos/`这个可以换成你自己服务器的路径；

5.卸载

```
docker stop memos

docker rm -f memos  # 停止容器，此时不会删除映射到本地的数据

rm -rf /root/data/docker_data/memos  # 完全删除映射到本地的数据
```

6.一些 Docker Compose 常用命令：

```
docker-compose restart  # 重启容器
docker-compose stop     # 暂停容器
docker-compose down     # 删除容器
docker-compose pull     # 更新镜像
docker-compose exec artalk bash # 进入容器
```

## 配置域名访问

```
vi /etc/nginx/conf.d/memos.conf
```

```bash
server
{
  listen 80;
  server_name me.bore.vip;
  
  # proxy to 5230
  location / {
    proxy_pass http://127.0.0.1:5230;
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
    root /data/wwwroot/me.bore.vip/;
  }  
}
```

重启Nginx：`systemctl restart nginx`

## 申请SSL证书

参考：[Nginx 配置 ssl 证书](/archives/58fed3fc/#Debian10上的操作)

1.新建文件夹：

```
mkdir -p /data/wwwroot/me.bore.vip
```

2.申请证书

```
sudo apt-get install letsencrypt -y
```

```
certbot certonly --webroot -w /data/wwwroot/me.bore.vip -d me.bore.vip -m 455343442@qq.com --agree-tos
```

3.编辑 Nginx

**（1）未启用端口复用：**

```
vi /etc/nginx/conf.d/memos.conf
```

```
server
{
  listen 80;
  listen 443 ssl http2;
  server_name me.bore.vip;
  root /data/wwwroot/me.bore.vip;

  # SSL setting
  ssl_certificate /etc/letsencrypt/live/me.bore.vip/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/me.bore.vip/privkey.pem;
  ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;
  add_header Strict-Transport-Security "max-age=31536000";

  # proxy to 5230
  location / {
    proxy_pass http://127.0.0.1:5230;
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
    root /data/wwwroot/me.bore.vip/;
  }  
}
```

**（2）启用端口复用：**

```bash
server
{
  listen 80;
  listen 127.0.0.1:1314 ssl http2 proxy_protocol;
  set_real_ip_from 127.0.0.1;
  real_ip_header proxy_protocol; 
  port_in_redirect off;  
  server_name me.bore.vip;
  root /data/wwwroot/me.bore.vip;
  if ($host != 'me.bore.vip' ) {
      rewrite ^/(.*)$ https://me.bore.vip/$1 permanent;
  }  

  # SSL setting
  ssl_certificate /etc/letsencrypt/live/me.bore.vip/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/me.bore.vip/privkey.pem;
  ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;
  add_header Strict-Transport-Security "max-age=31536000";

  # proxy to 5230
  location / {
    proxy_pass http://127.0.0.1:5230;
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
    root /data/wwwroot/me.bore.vip/;
  }  
}
```

4.重启Nginx、xr

## 证书自动续期

参考：[自动续期](/archives/58fed3fc/#使用-webroot-自动生成证书-1)

## 安卓快捷方式发送Memos

参考：[安卓手机上快捷方式发送](/archives/6c31209c/#安卓手机上快捷方式发送)

注意：

1.变量只添加一个`content`即可

2.`响应体/响应参数`，选择`自定义类型`，Content-Type 填写 `application/json`，请求体填写：(最好不要直接点复制按钮复制代码，直接拖动选择所有行代码，这样张贴就会保留空格)

```json
{
    "content": "{content}"
}
```

{% note warning flat %}
注意：上面的`{content}`  需要先删除，然后点击旁边的 `{}` 插入变量（插入的变量颜色是蓝色）。不能直接填写！！！
{% endnote %}

3.`#tag `后面必须有个空格才能创建tag

## 首页轮播

> API 调用最新 10 条 memos 在博客首页轮播显示。

```html
<div id="bber-talk"></div>
<style>
#bber-talk{display:-webkit-flex;display:flex;width:100%;line-height:35px;height:45px;max-width:760px;text-align:left;padding:5px 15px;margin:20px 0;position: relative;background-color: var(--light-header);border-radius:8px;font-size:15px;overflow:hidden;}
#bber-talk svg{fill: currentColor;vertical-align: middle;display: inline;margin-right:5px;margin-top: -4px;}
.talk-wrap{width:100%;}
.talk-list{margin: 0;height: 35px;}
.talk-list li {list-style:none;margin-bottom:10px;width: 100%;white-space: nowrap;text-overflow: ellipsis;overflow: hidden;zoom: 1;}
.talk-list li .datetime{margin-right:2px;}
.talk-list li a{text-decoration:none;}
.dark-theme #bber-talk{background-color: var(--dark-header);}
.dark-theme .talk-list{color: var(--dark-color);}
@media only screen and (max-width:683px) {
	#bber-talk{margin:2em 1em 1em;width:94%;}
}
</style>
<script src="https://cdn.jsdelivr.net/npm/dayjs@1.11.5/dayjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/dayjs@1.11.5/locale/zh-cn.js"></script>
<script src="https://cdn.jsdelivr.net/npm/dayjs@1.11.5/plugin/relativeTime.js"></script>
<script>dayjs.locale('zh-cn');dayjs.extend(window.dayjs_plugin_relativeTime)</script>
<script>
var bbUrl = "https://me.edui.fun/api/memo?creatorId=101&limit=10"
fetch(bbUrl).then(res => res.json()).then( resdata =>{
    var result = '',resultAll="",data = resdata.data
    console.log(data)
    for(var i=0;i < data.length;i++){
        var bbTime = dayjs.unix(data[i].createdTs).fromNow()
        var bbCont = data[i].content
        var newbbCont = bbCont.replace(/(https?:[^:<>"]*\/)([^:<>"]*)(\.((png!thumbnail)|(png)|(jpg)|(webp)|(jpeg)|(gif))(!blogimg)?)/g,' 🌅 ')
        var newbbCont = newbbCont.replace(/\bhttps?:\/\/(?!\S+(?:jpe?g|png|bmp|gif|webp|jfif|gif))\S+/g,' 🔗 ')
        result += `<li class="item"><span class="datetime">${bbTime}</span>： <a href="https://me.edui.fun/u/101" target="_blank">${newbbCont}</a></li>`;
    }
    var bbDom = document.querySelector('#bber-talk');
    var bbBefore = `<span class="index-talk-icon"><svg viewBox="0 0 1024 1024" width="21" height="21"><path d="M184.32 891.667692c-12.603077 0-25.206154-2.363077-37.809231-7.876923-37.021538-14.966154-59.864615-49.624615-59.864615-89.009231v-275.692307c0-212.676923 173.292308-385.969231 385.969231-385.969231h78.76923c212.676923 0 385.969231 173.292308 385.969231 385.969231 0 169.353846-137.846154 307.2-307.2 307.2H289.083077l-37.021539 37.021538c-18.904615 18.116923-43.323077 28.356923-67.741538 28.356923zM472.615385 195.347692c-178.018462 0-322.953846 144.935385-322.953847 322.953846v275.692308c0 21.267692 15.753846 29.144615 20.48 31.507692 4.726154 2.363077 22.055385 7.876923 37.021539-7.08923l46.473846-46.473846c6.301538-6.301538 14.178462-9.452308 22.055385-9.452308h354.461538c134.695385 0 244.184615-109.489231 244.184616-244.184616 0-178.018462-144.935385-322.953846-322.953847-322.953846H472.615385z"></path><path d="M321.378462 512m-59.076924 0a59.076923 59.076923 0 1 0 118.153847 0 59.076923 59.076923 0 1 0-118.153847 0Z"></path><path d="M518.301538 512m-59.076923 0a59.076923 59.076923 0 1 0 118.153847 0 59.076923 59.076923 0 1 0-118.153847 0Z"></path><path d="M715.224615 512m-59.076923 0a59.076923 59.076923 0 1 0 118.153846 0 59.076923 59.076923 0 1 0-118.153846 0Z"></path></svg></span><div class="talk-wrap"><ul class="talk-list">`
    var bbAfter = `</ul></div>`
    resultAll = bbBefore + result + bbAfter
    bbDom.innerHTML = resultAll;
});
setInterval(function() {
    for (var s, n = document.querySelector(".talk-list"), e = n.querySelectorAll(".item"), t = 0; t < e.length; t++)
    setTimeout(function() {
      n.appendChild(e[0])
    },1000)
},1000)
</script>
```

## 单页部署代码

> 已做 js 文件调用处理，找个页面丢入以下 html + js + css 即可。当然，得先部署个 [Memos](https://immmmm.com/hi-memos/)，或者，找个好朋友开个 id 也可以。

```html
<div id="bber"></div>
<script type="text/javascript">
  var bbMemos = {
    memos : 'https://me.edui.fun/',//修改为自己的 apiurl，末尾有 / 斜杠
    limit : '',//默认每次显示 10条 
    creatorId:'' ,//默认为 101用户 https://demo.usememos.com/u/101
    domId: '',//默认为 <div id="bber"></div>
  }
</script>
<script src="https://immmmm.com/bb-lmm.js"></script>
<script src="https://fastly.jsdelivr.net/gh/Tokinx/ViewImage/view-image.min.js"></script>
<script src="https://fastly.jsdelivr.net/gh/Tokinx/Lately/lately.min.js"></script>
```

样式代码供参考：

```css
#bber{margin-top:1em;}
.timeline ul {margin:0;}
.timeline ul li {background:#3b3d42;list-style-type:none;position:relative;width:3px;margin-left:1em;padding:0.8em 0 2em;}
.timeline ul li::after {transform: rotate(45deg);content:'';background-color: #3b3d42;display: block;position: absolute;top: 10px;left: -5px;width: 0.8em;height: 0.8em;outline:15px solid #fff;}
.timeline ul li div {position:relative;top:-13px;left:1em;width:670px;padding:0px 16px 0px;}
.timeline ul li p.datatime{color: #fafafa;font-size: 0.75em;font-style: italic;background-color: #3b3d42;display: inline-block;padding:0.25em 1em 0.2em 1em;}
.timeline ul li p.datacont{white-space: pre-wrap;margin:0.65em 0 0.3em;}
.timeline ul li p.datacont img{display:block;max-height:340px !important;}
.timeline ul li p.datacont img[src*="emotion"]{display:inline-block;width:auto;}
.timeline ul li p.datafrom{color: #aaa;font-size: 0.75em !important;font-style: italic;}
.timeline ul li p{margin:0;font-size:16px;letter-spacing:1px;color: #3b3d42;}
.timeline ul li p.datacont .img{cursor: pointer;border:1px solid #3b3d42;max-width:20rem;margin:6px 0 6px 0;}
button{border-radius:0;}
.dark-theme .timeline ul li div p{color:#fafafa;}
.dark-theme .timeline ul li div p svg{fill:#fafafa;}
.dark-theme .timeline ul li p.datafrom{color: #aaa;}
.dark-theme .timeline ul li{background:#3b3d42;}
.dark-theme .timeline ul li::after{outline: 15px solid #2f2f2f;}
@media (max-width:860px) {
  .timeline ul li{margin-left:0;}
  .timeline ul li div{width:calc(100vw - 75px);left:30px;}
}
```

## 定时备份数据库

参考：[halo 定时备份的方法](/archives/3a4bd17/)

## 总结

感觉还是小康speak和Butterfly主题更搭，况且小康speak也可以独立部署，所以还是用前者吧！

## 参考链接

[Hi，Memos](https://immmmm.com/hi-memos/)

[哔哔点啥 By Memos](https://immmmm.com/bb-by-memos/)

[搭建属于你自己的 flomo 应用 :Memos](https://1900.live/build_your_own_flomo_applications/)

[好玩儿的Docker项目](https://blog.laoda.de/archives/docker-install-memos)
