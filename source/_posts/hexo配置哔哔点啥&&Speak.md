---
title: hexo配置哔哔点啥&&Speak
categories:
  - 技术
tags:
  - hexo
  - hugo
abbrlink: 6c31209c
date: 2021-08-17 05:45:30
cover: false
---

{% note warning flat %}
2022.8.1 由于腾讯云开发要开始收费了，故将`哔哔点啥`改成`Speak`。点击直达：{% btn '/archives/6c31209c/#部署Speak',部署 Speak,far fa-hand-point-right,blue larger %}
{% endnote %}

{% note warning flat %}
2022.8.28 Vercel崩了，要绑定个二级域名才能用。
{% endnote %}

## 服务部署

1.首先保证成功激活腾讯云开发.

2.[点击一键部署至云开发](https://console.cloud.tencent.com/tcb/env/index?action=CreateAndDeployCloudBaseProject&appUrl=https://github.com/lmm214/bber&branch=main)

> 推荐创建上海环境。如选择广州环境，需要在 twikoo.init() 时额外指定环境 region: “ap-guangzhou”

3.进入环境-登录授权，启用“匿名登录”

4.进入[环境-安全配置](https://console.cloud.tencent.com/tcb/env/safety)，将博客网址添加到“WEB安全域名”

5.进入[环境-HTTP访问服务](https://console.cloud.tencent.com/tcb/env/access)，复制链接备用。

进入[云函数](https://console.cloud.tencent.com/tcb/scf/index)，修改自定义serverkey `bber` 并保存备用。

6.进入云函数，修改自定义serverkey bber 并保存备用。

7.扫码进入公众号，输入命名绑定。

```bash
/bber 你刚刚设置的key,https://你的云函数HTTP访问地址/bber

比如: /bber mykey,https://balabala.ap-shanghai.app.tcloudbase.com/bber
```

**8. 手动添加一条哔哔 *必须要有***

进入腾讯云数据库->talks->文档列表->添加文档

```bash
字段: content
类型: string
值: 随便
```

点击确定

验证微信发送

9.微信发送一条文字，返回哔哔成功，talks文档列表里多出来一条，即为服务部署成功。

## 前端部署

1.打开Hugo的unsafe

```yaml
markup:
    tableOfContents:
        endLevel: 4
        ordered: true
        startLevel: 2
    highlight:
        noClasses: false
    goldmark:
        renderer:
            unsafe: true
```

2.新建一个*markdown*文件（此法不通，jsdelivr用不了，需要更换地址，见下文）

```markdown
<div id='speak'></speak>
<!-- 使用markdown渲染 -->
<!-- 使用markdown渲染 -->
<!-- <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/ispeak-bber/ispeak-bber-md.min.js" charset="utf-8" ></script> -->
<!-- 不使用markdown渲染 -->
<script type="text/javascript" src="https://cdn.jsdelivr.net/npm/ispeak-bber/ispeak-bber.min.js" charset="utf-8" ></script>
<!-- 解析微信表情（参考：https://github.com/buddys/qq-wechat-emotion-parser） -->
<!-- <script src="https://cdn.jsdelivr.net/gh/buddys/qq-wechat-emotion-parser@master/dist/qq-wechat-emotion-parser.min.js"></script> -->
<script>
ispeakBber
    .init({
      el: '#speak', // 容器选择器
      name: 'bore', // 显示的昵称
      envId: '腾讯云开发环境id', // 环境id
      region: 'ap-shanghai', // 腾讯云地址，默认为上海
      limit: 10, // 每次加载的条数，默认为5
      avatar: 'https://cdn.jsdelivr.net/gh/iwyang/pic/avatar.jpg',
      fromColor:'rgb(245, 150, 170)', // 下方标签背景颜色 默认 rgb(245, 150, 170)
      loadingImg: 'https://7.dusays.com/2021/03/04/d2d5e983e2961.gif', // 自定义loading的图片，示例值为默认值
      dbName:'talks' // 数据的名称，默认talks，避免有人的命名不是这个，所以加入此配置字段。
    })
    .then(function() {
      // 哔哔加载完成后的回调函数，你可以写你自己的功能
      console.log('哔哔 加载完成')
    })
</script>
```
2022.5.18 `jsdelivr`用不了，需要修改地址（本地相对路径）：

```yaml
<style>
.page-title {
    display: none;
  }
</style>
<!--  自言自语  -->

<div id='speak'>
<script type="text/javascript" src="/img/js/ispeak-bber.min.js" charset="utf-8" ></script>
<script>
ispeakBber
    .init({
        el: '#speak', // 容器选择器
        name: 'Bore 🦄', // 显示的昵称
        envId: 'hello-cloudbase-0gc8y1np937491cb', // 环境id
        region: 'ap-shanghai', // 腾讯云地址，默认为上海
        limit: 10, // 每次加载的条数，默认为5
        avatar: '/img/avatar.jpg', // 头像地址
        fromColor:'rgb(245, 150, 170)', // 下方标签背景颜色 默认 rgb(245, 150, 170)
        loadingImg: '/img/loading.gif', // 自定义loading的图片，示例值为默认值
        dbName:'talks' // 数据的名称，默认talks，避免有人的命名不是这个，所以加入此配置字段。
    })
    .then(function() {
        // 哔哔加载完成后的回调函数，你可以写你自己的功能
        console.log('哔哔 加载完成')
    })
</script>
</div>
```



3.bber 说说美化(调整了说说出现图片时，顶部空白过大问题；更换一种 timeago 方法，解决 “两周前”、“三周前” 等部分情况下显示实际日期的 bug；修复头像尺寸异常的 bug等)

```html
<!--  自言自语  -->
<div id='speak'>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/aplayer/dist/APlayer.min.css">
<script type="text/javascript" src="/js/timeago.min.js" charset="utf-8" ></script>
<script type="text/javascript" src="https://cdn.jsdelivr.net/gh/kuole-o/bber-ispeak@main/dist/ispeak-bber.min.js" charset="utf-8" ></script>
<script>
ispeakBber
    .init({
        el: '#speak', // 容器选择器
        name: '夜的第八章 🦄', // 显示的昵称
        envId: 'blogpkly-13278c', // 环境id
        region: 'ap-shanghai', // 腾讯云地址，默认为上海
        limit: 7, // 每次加载的条数，默认为5
        avatar: 'https://cdn.guole.fun/img/gl.jpg', // 头像地址
        fromColor:'rgb(245, 150, 170)', // 下方标签背景颜色 默认 rgb(245, 150, 170)
        loadingImg: 'https://7.dusays.com/2021/03/04/d2d5e983e2961.gif', // 自定义loading的图片，示例值为默认值
        dbName:'talks' // 数据的名称，默认talks，避免有人的命名不是这个，所以加入此配置字段。
    })
    .then(function() {
        // 哔哔加载完成后的回调函数，你可以写你自己的功能
        console.log('哔哔 加载完成')
    })
</script>
</div>
```

## 部署BBer-weixin公众号

点击[部署到云开发](https://console.cloud.tencent.com/tcb/env/index?action=CreateAndDeployCloudBaseProject&appUrl=https%3A%2F%2Fgithub.com%2Flmm214%2Fbber-weixin&branch=main)将 BBer-weixin 微信公众号后端，一键部署到云开发。

对接的微信公众号简要流程：

1.点击 [bber-weixin](https://console.cloud.tencent.com/tcb/scf/index) 云函数，右上角**【编辑】**，开启**【固定IP】**，留存**公网固定IP**。

> 我将from `微信公众号`改成了`💎 WeChat`

2.进入[环境-HTTP访问服务](https://console.cloud.tencent.com/tcb/env/access)，获取`触发路径链接`并留存，如以下格式：

```bash
https://bb-f5c0f-222222.ap-shanghai.app.tcloudbase.com/bber-weixin
```

3.打开 [微信公众平台](https://mp.weixin.qq.com/)，进入开发-基本配置，获取`AppID`和`AppSecret`留存，修改`IP白名单`为上一步的公网固定IP。继续服务器配置：

> 消息加密方式选择`兼容模式`

一个`URL`，即第2步留存的触发链接；

一个`Token`，预设为 `weixin`

**!!!先不点，不点，不点，不点提交！！！**

4.回 [bber-weixin](https://console.cloud.tencent.com/tcb/scf/index) 云函数，填入`微信公众号appid`、`微信公众号appsecret` 保存。

```bash
const token = 'weixin' // 微信公众号的服务器验证用的令牌 token
//填入自己的微信公众号appid和appsecret
var wxappid = '微信公众号appid',
    wxappsecret = '微信公众号appsecret',
```

5.回 [微信公众平台](https://mp.weixin.qq.com/)，提交，验证成功！

6.回 [bber-weixin](https://console.cloud.tencent.com/tcb/scf/index) 云函数，注释第44行代码，保存。

```bash
   if(tmpStr == signature){
        //请求来源鉴权
        //成功后注释下行代码
        //return event.queryStringParameters.echostr //成功后注释本行代码
        //成功后注释上行代码
```

7.手动配置或更新代码： https://github.com/lmm214/bber-weixin/tree/main/bber-weixin

## 公众号发布说说

~~接上面，部署好自己的公众号就可以用公众号发布了。这里注意利用公众号发图片。~~

1.先在公众号发一张图片

2.接着输入`/a <br>文字说明`

(输入`<br>`是为了使图片和文字不处于同一行)

注意：用公众号发图片会一连发几张，不知道是什么原因，以后就用浏览器插件发图片，注意**比例 16:9，长度568px**

## Chrome + Edge 发布说说

### 安装本地插件

[点此下载我提取并修改的浏览器插件包](https://cdn.guole.fun/others/bber%E6%B5%8F%E8%A7%88%E5%99%A8%E5%8F%91%E5%B8%83%E6%8F%92%E4%BB%B6.zip)

Chrome 安装本地插件：

访问 Chrome——更多工具——扩展程序——左上角“加载已解压的扩展程序”，选择我提供的附件，解压缩后的文件夹 1.0.0_0_Chrome，然后回到 Chrome，点开右上角`扩展程序`来固定插件。

注意：插件文件移动或丢失后，浏览器扩展失效，因为不是云端的，所以要保存在可靠路径。

### 应用商店安装插件

下载地址：[iSpeak-bber时光机](https://chrome.google.com/webstore/detail/ispeak-bber%E6%97%B6%E5%85%89%E6%9C%BA/mmehomnjakoijcfmmofbmkaigcdkkbke/related)

本地插件`from`默认为`🌈 Chrome`

## Android 捷径发布说说

从 Github 下载安装这款 “HTTP 快捷方式” apk，安装后继续下文操作。

下载地址：[HTTP-Shortcuts](https://github.com/Waboodoo/HTTP-Shortcuts/releases)

打开 HTTP 快捷方式 App，选择新建快捷方式，自定义名称、描述，在 “基本设置” 中，设置方法为 “POST” 或 “GET”，URL 为

```bash
https://你后台显示的.ap-shanghai.app.tcloudbase.com/bber?key=
```

至于 key、from，我们设置为常量，text 则设置为变量 content，每次发布的时候填写说说内容。

点击 URL 右侧的 {}，选择添加变量。常量 key 为你云函数里的 key，如果没有特别设置就是 bber。from 我们设置一个好玩的如`📱 Android 11`。添加一个变量 content。（个人觉得from直接设置为`Android`就行，不然免得以后安卓升级版本，还要跟着修改。）

接着回到 URL 页面，补充完刚才添加的常量和变量，如以下格式：

```bash
https://你后台显示的.ap-shanghai.app.tcloudbase.com/bber?key={key}&from={from}&text={content}
```

右上角，保存这个快捷方式，然后长按发送到桌面，搞定！

## 修改`ispeak-bber`样式

### 隐藏页面标题

将以下代码放在文章正文最上方。

[hugo-stack](https://github.com/CaiJimmy/hugo-theme-stack)主题：

```css
<style>
.article-header {
    display: none;
  }
</style>
```

[hexo-butterfly](https://github.com/jerryc127/hexo-theme-butterfly)主题：

```css
<style>
.page-title {
    display: none;
  }
</style>
```

### 修改顶部文字

自己胡乱改的，居然起了作用。不管了先用再说。

1.首先下载：[ispeak-bber-md.min.js](https://cdn.jsdelivr.net/npm/ispeak-bber/ispeak-bber-md.min.js)

2.用`Notepad++`打开，搜索`My BiBi`改成`我的说说`。

3.按F12，打开浏览器控制台，定位标题。可以发现`color: #49b1f5`前面就是标题字体大小，搜索`color: #49b1f5`，将前面的字体改成22px：`font-size: 22px`

4.接着改图标大小，一样方法定位图标，可以发现`color: black`后面就是图标大小，搜索`color: black`，将后面图标大小改成22px：`font-size: 22px`

### 修复说说出现图片时，顶部空白过大问题

搜索`white-space`作如下修改

```diff
- {\n  padding: 10px 0;\n  white-space: pre-wrap;\n}
+ {\n  padding: 0.8rem 0;\n}
```

~~注意：利用微信公众号发图片后追加文字说明，前面要加个换行符，要不然图片和文字处在同一行。~~

注意：用公众号发图片会一连发几张，不知道是什么原因，以后就用浏览器插件发图片，注意**比例 16:9，长度568px**

### 解决公众号连续发多张图片

云函数代码问题，改成下面这样即可（**还未测试**）：

```bash
104行
let res = await cloudRequest(cloudHttpUrl,cloudKey,createTime,content)

124行
let res = await cloudRequest(cloudHttpUrl,cloudKey,createTime,content)

160行
function cloudRequest(cloudHttpUrl,cloudKey,createTime,content){
```

中，删掉 “createTime,”，接着

```bash
162行
var param1 = {'key': cloudKey,'time': createTime,'text': content,'from':'微信公众号'}
```

删掉 “’time’: createTime,” 就解决了。

### 取消显示'一周前','一小时前'

去掉“周前”，”月前“这些时间点：

+ 1. 找到`ispeak-bber-md.min.js` or `ispeak-bber.min.js`

+ 2.复制下面这段代码，查找，然后删掉它们 (未测试)

```js
if(l>=1&&l<=3)n=" "+parseInt(l)+" 月前";else if(f>=1&&f<=3)n=" "+parseInt(f)+" 周前";else if(c>=1&&c<=6)n=" "+parseInt(c)+" 天前";else if(u>=1&&u<=23)n=" "+parseInt(u)+" 小时前";else if(a>=1&&a<=59)n=" "+parseInt(a)+" 分钟前";else if(s>=0&&s<=r)n="刚刚";else
```

## butterfly 主题添加首页轮播

添加首页轮播借助了 [butterfly 主题自定义组件](https://butterfly.js.org/posts/ea33ab97/)的功能实现，通过在自定义组件处加载 JavaScript 生成首页的轮播展示。

### 创建 widget.yml

在Hexo博客目录中的`source/_data`（如果没有 _data 文件夹，请自行创建），创建一个文件 widget.yml，代码如下：

```yaml
top:
  - class_name: latestBB
    id_name:
    name: 最新说说
    icon: fas fa-bolt
    order: 2
    html: |
      <div class="swiper-container swiper-container-aside">
        <div class="swiper-wrapper swiper-weapper-aside"></div>
      </div>
      <a class="bb-btn button--animated" href="/say/" title="查看全部"><i class="far fa-hand-point-right fa-fw"></i> 查看更多 </a>
      <script>
        window.kkBBConfig = {
          limit: 10,
          blog:'/say/',
          api_url:
            'https://xxx/json/bber.json'//你的json url
        }
      </script>
      <script src="https://cdn.jsdelivr.net/npm/butterfly-bber-swiper/dist/index.min.js"></script>
```

2022.5.18 `jsdelivr`用不了，需要修改地址（本地相对路径）：

```yaml
top:
  - class_name: latestBB
    id_name:
    name: 最新说说
    icon: fas fa-bolt
    order: 2
    html: |
      <div class="swiper-container swiper-container-aside">
        <div class="swiper-wrapper swiper-weapper-aside"></div>
      </div>
      <a class="bb-btn button--animated" href="/say/" title="查看全部"><i class="far fa-hand-point-right fa-fw"></i> 查看更多 </a>
      <script>
        window.kkBBConfig = {
          limit: 10,
          blog:'/say/',
          api_url:
            'https://xxx/json/bber.json'//你的json url
        }
      </script>
      <script src="/img/js/butterfly-bber-swiper.min.js"></script>
```

### 去掉侧边栏最新说说

在 `blog/source/css/custom.css` 文件中，加入以下代码即可。

```css
/* 去掉侧边栏最新吐槽 */
.latestBB {
display: none;
}
```

### 解决移动端二级菜单缩进问题

设置完首页轮播后，移动端二级菜单会出现缩进问题，浏览器F12发现问题：

![](../img/hexo%E9%85%8D%E7%BD%AE%E5%93%94%E5%93%94%E7%82%B9%E5%95%A5&&Speak/QQ%E6%88%AA%E5%9B%BE20220521125739.jpg)

解决方法：

`butterfly-bber-swiper.min.js`(轮播js文件)，~~搜索`bbTimeList`删除前面的`padding: 0;\n`~~；直接搜索`padding: 0;\n`将其删除，注意后面就是`bbTimeList`，搜索`bbTimeList`会出现多个结果，故搜索后者较好。

## 部署Speak

2022.8.1 由于腾讯云开发要开始收费了，故将`哔哔点啥`改成`Speak`。官方文档：



+ [小康Speak](https://www.antmoe.com/speak/)

+ [kkAPI-Doc](https://kkapi-doc.vercel.app/)

  + [kkapi-open](https://github.com/kkfive/kkapi-open)
  + [kkadmin-open](https://github.com/kkfive/kkadmin-open)

  + [iSpeak](http://github.com/kkfive/iSpeak/)

> 首先要参考上面官方文档搭建好API、后台管理等内容。然后再弄前端。Vercel搭建见官方文档，**下面主要记录服务器部署。**

### Docker 安装 MongoDB

1.先安装docker，参考：[Debian 10 安装 Docker & Docker Compose](/archives/9755dbc8/)

2.取最新版的 MongoDB 镜像

```bash
docker pull mongo:latest
```

3.查看本地镜像，使用以下命令来查看是否已安装了 mongo：

```
docker images
```

4.运行容器

```bash
docker run -d --name mongodb \
	-p 27017:27017 \
	-v /my/own/datadir:/data/db \
	-e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
	-e MONGO_INITDB_ROOT_PASSWORD=secret \
	mongo
```

之后可以使用工具测试一下连接。如`navicat`

5.使容器开机启动

```
docker update --restart=always mongodb
```

### kkapi 部署

1.首先克隆项目源码 `git clone https://ghproxy.com/https://github.com/kkfive/kkapi-open.git`

2.接下来j进入项目目录，安装项目需要安装的工具 `yarn` 和 `pm2`，分别是 :

```
cd kkapi-open
apt install npm -y
npm i yarn -g
npm i pm2 -g
```

3.**升级node版本**，仓库给的构建版本是16+的，node版本过低，下一步会出错，最后一步项目无法启动。(上面安装npm时默认会安装低版本node，所以要更新node版本)

```
node --version
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo apt install nodejs -y
node --version
```

上面操作会安装最新版的node，安装nodeV16：`curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -`

4.然后安装项目所需依赖 `yarn install`

5.之后再执行 `yarn build` 编译项目。~~这里我的小鸡顶不住编译所以自己在本地编译传上去了。~~

6.在项目文件夹创建环境变量文件，格式如

```
vi local.env
```

```bash
PORT=3000
DATABASE_URL=mongodb://127.0.0.1:27017/kkpaiopen?authSource=admin
DATABASE_USER=mongoadmin
DATABASE_PASSWORD=secret
# 加密密钥 测试
SECRETKEY=xxxxxxxxxxxxxxx
```

7.使用 `pm2` 使用守护线程启动项目 `pm2 start pm2.json`

我启动项目遇到了 `[PM2][WARN] Expect “restart_delay” to be a typeof [object Number], but now is [object String]` 错误，这个错误原因是作者的 pm2.json 中的 `restart_delay` 值是字符串类型 `60s` 改成数值 `60` 就可以了。

8.测试项目是否成功启动 可以使用 `lsof -i:端口` 查看端口是否被监听判断项目是否成功启动。没成功的原因大概率是因为数据库连接地址、数据库账号密码不正确。

9.创建初始化用户 `curl http://127.0.0.1:3000/api/user/init?userName=bore` 创建的默认用户名和密码是 `bore` 和 `123456`，这个用户名密码用来登陆可视化的管理后台，并且用户似乎**只能拥有一个**。

10.更新项目

进入项目并执行一下命令：

```bash
git pull
yarn build
pm2 restart pm2.json
```

11.备份

`/my/own/datadir` 这一段就是数据库的文件，把这个打包搞走就行，然后换到新地方以后，部署mongodb数据库还要对应上。

定时备份数据库，参考：[halo 定时备份的方法](https://bore.vip/archives/3a4bd17/)

### 配置域名访问

参考：

[配置域名访问](/archives/d5e37958/#配置域名访问)

[申请 SSL 证书](/archives/d5e37958/#申请SSL证书)

[SSL证书自动续期](/archives/58fed3fc/#使用-webroot-自动生成证书-1)

**注意修改反代端口号，如果SSL443端口不能用，将`listen 443`改成`listen 1314`**

### kkapiadmin（可视化管理后台）

见官方文档：[kkapi后台配置](https://kkapi.js.org/guide/admin/setup.html)

之后登录就是用前面初始化的用户名密码，进入后台以后可以修改密码。登陆后台以后需要设置：

- ISpeak 标签。因为发布说说是需要选择标签的，标签中的背景颜色值是**十六进制的颜色**代码
- 添加用户token。**需要注意！！！**，添加的token的**标题**只能是 `speak` 不能是其他的，否则发布说说时会提示token不存在，发布时验证的就是字段为 `speak` 的token的值。

## 前端

参考：[博客前端方案](https://kkapi-doc.vercel.app/posts/ispeak/front.html#%E5%8D%9A%E5%AE%A2%E5%89%8D%E7%AB%AF%E6%96%B9%E6%A1%88)，新建一个`Markdown`文件：

###  v4.4.0以前

**官方：**

```html
<div id="tip" style="text-align:center;">ipseak加载中</div>
<div id="ispeak"></div>
<link
  rel="stylesheet"
  href="https://cdn.staticfile.org/highlight.js/10.6.0/styles/atom-one-dark.min.css"
/>
<link
  rel="stylesheet"
  href="https://cdn.jsdelivr.net/npm/ispeak@4.2.0/style.css"
/>

<style>
  #article-container .D-avatar {
    margin: 0 10px 0 0;
  }
  .D-footer {
    display: none;
  }
</style>
<script src="https://cdn.staticfile.org/highlight.js/10.6.0/highlight.min.js"></script>
<script src="https://cdn.staticfile.org/marked/2.0.0/marked.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/discuss/dist/Discuss.js"></script>
<script src="https://cdn.jsdelivr.net/npm/ispeak@4.2.0/ispeak.umd.js"></script>
<script>
  var head = document.getElementsByTagName('head')[0]
  var meta = document.createElement('meta')
  meta.name = 'referrer'
  meta.content = 'no-referrer'
  head.appendChild(meta)
  if (ispeak) {
    ispeak
      .init({
        el: '#ispeak',
        api: 'https://kkapi-dev.vercel.app/',
        author: '61fe93508fd621d39a155725',
        pageSize: 10,
        loading_img: 'https://bu.dusays.com/2022/05/01/626e88f349943.gif',
        initCommentName: 'Discuss',
        initCommentOptions: {
          serverURLs: 'https://kkdiscuss.vercel.app/'
        }
      })
      .then(function () {
        console.log('ispeak 加载完成')
        document.getElementById('tip').style.display = 'none'
      })
  } else {
    document.getElementById('tip').innerHTML = 'ipseak依赖加载失败！'
  }
</script>
```

**自用：**

```html
<div class="js-pjax" id="tip" style="text-align:center;">ipseak加载中</div>
<div class="js-pjax" id="ispeak"></div>
<link
  rel="stylesheet"
  href="https://cdn.staticfile.org/highlight.js/10.6.0/styles/atom-one-dark.min.css"
/>
<link
  rel="stylesheet"
  href="https://cdn1.tianli0.top/npm/ispeak@4.3.3/style.css"
/>

<style>
  #article-container .D-avatar {
    margin: 0 10px 0 0;
  }
  .D-footer {
    display: none;
  }
</style>
<script src="https://cdn.staticfile.org/highlight.js/10.6.0/highlight.min.js"></script>
<script src="https://cdn.staticfile.org/marked/2.0.0/marked.min.js"></script>
<script src="https://cdn1.tianli0.top/npm/ispeak@4.3.3/ispeak.umd.js"></script>
<script>
  var head = document.getElementsByTagName('head')[0]
  var meta = document.createElement('meta')
  meta.name = 'referrer'
  meta.content = 'no-referrer'
  head.appendChild(meta)
  if (ispeak) {
    ispeak
      .init({
        el: '#ispeak',
        api: 'https://kkapi-open-six.vercel.app/',
        author: '这里填个人ID',
        pageSize: 10,
        loading_img: 'https://bu.dusays.com/2022/05/01/626e88f349943.gif',
        speakPage: '/say',
        githubClientId: '这里填githubClientId',
        hideComment: true,
      })
      .then(function () {
        console.log('ispeak 加载完成')
        document.getElementById('tip').style.display = 'none'
      })
  } else {
    document.getElementById('tip').innerHTML = 'ipseak依赖加载失败！'
  }
</script>
```

> + 如若CDN用不了，上面的`CSS`、`JS`、`图像`等可以用本地路径，如：`/img/loading.gif`  `/img/js/speak/style.css`，不用使用：~~../img/loading.gif~~，使用上面的相对路径即可。
> + hugo loveit主题要把 KaTeX 在这个页面单独关闭，因为和说说冲突了。`math: false`

###  v4.4.0以后

**官方：** （以[Artalk](https://artalk.js.org/)评论为例）

```html
<div id="tip" style="text-align:center;">ipseak加载中</div>
<div id="ispeak"></div>
<link
  rel="stylesheet"
  href="https://cdn.staticfile.org/highlight.js/10.6.0/styles/atom-one-dark.min.css"
/>
<link
  rel="stylesheet"
  href="https://cdn.jsdelivr.net/npm/ispeak@4.4.0/style.css"
/>

<script src="https://cdn.staticfile.org/highlight.js/10.6.0/highlight.min.js"></script>
<script src="https://cdn.staticfile.org/marked/2.0.0/marked.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/ispeak@4.4.0/ispeak.umd.js"></script>
<!-- CSS -->
<link href="https://unpkg.com/artalk@2.3.4/dist/Artalk.css" rel="stylesheet" />
<!-- JS -->
<script src="https://unpkg.com/artalk@2.3.4/dist/Artalk.js"></script>
<script>
  var head = document.getElementsByTagName('head')[0]
  var meta = document.createElement('meta')
  meta.name = 'referrer'
  meta.content = 'no-referrer'
  head.appendChild(meta)
  if (ispeak) {
    ispeak
      .init({
        el: '#ispeak',
        api: 'https://kkapi-dev.vercel.app/',
        author: '61fe93508fd621d39a155725',
        pageSize: 10,
        loading_img: 'https://bu.dusays.com/2021/03/04/d2d5e983e2961.gif',
        comment: function (speak) {
          // 4.4.0 之后在此回调函数中初始化评论
          const { _id, title, content } = speak
          const contentSub = content.substring(0, 30)
          new Artalk({
            el: '.ispeak-comment', // 默认情况下 ipseak 生成class为 ispeak-comment 的div
            pageKey: '/speak/info.html?q=' + _id, // 手动传入当前speak的唯一id
            pageTitle: title || contentSub, // 手动传入当前speak的标题(由于content可能过长，因此截取前30个字符)
            server: 'https://api.antmoe.com/artalk/',
            site: 'speak' // 你的站点名
          })
        }
      })
      .then(function () {
        console.log('ispeak 加载完成')
        document.getElementById('tip').style.display = 'none'
      })
  } else {
    document.getElementById('tip').innerHTML = 'ipseak依赖加载失败！'
  }
</script>
```

[官方设置评论](https://kkapi.js.org/posts/ispeak/comment.html#%E8%AF%B4%E6%98%8E)：

`info.md`页面内容：

```markdown
---
title: Speak
date: 2022-08-21 14:11:00
update: 2022-08-21 14:11:00
top_img: https://tva1.sinaimg.cn/large/005B3XPgly1ghkxqgvmy0j30zk0irn2q.jpg
aside: false
comments: false
description: 欢迎来到小康的Speak页面，快来看看小康分享了什么speak！
---

<!-- CSS -->
<link href="https://unpkg.com/artalk@2.3.4/dist/Artalk.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.staticfile.org/highlight.js/10.6.0/styles/atom-one-dark.min.css" />
<div class='content'>
  <img src='https://bu.dusays.com/2022/05/01/626e88f349943.gif'>
</div>
{% btn 'https://www.antmoe.com/speak/',查看全部,far fa-hand-point-right,block center blue larger %}
<hr />
<div class='ispeak-comment'></div>
<!-- JS -->
<script src="https://unpkg.com/artalk@2.3.4/dist/Artalk.js"></script>
<script src="https://unpkg.com/marked@4.0.18/marked.min.js"></script>
<script src="https://cdn.staticfile.org/highlight.js/10.6.0/highlight.min.js"></script>
<script>
  const searchParams = new URLSearchParams(window.location.search);
  const speakId = searchParams.get('q');
  const path = window.location.pathname;
  const apiURL = 'https://kkapi.vercel.app/api/ispeak';
  const markedRender = (body, loading_img='https://bu.dusays.com/2022/05/01/626e88f349943.gif') => {
    const renderer = {
      image(href, title, text) {
        return `<a href="${href}" target="_blank" data-fancybox="group" class="fancybox">
            <img speak-src="${href}" src=${loading_img} alt='${text}'>
            </a>`
      }
    }
    marked.setOptions({
      renderer: new marked.Renderer(),
      highlight: function (code) {
        if (hljs) {
          return hljs.highlightAuto(code).value
        } else {
          return code
        }
      },
      pedantic: false,
      gfm: true,
      tables: true,
      breaks: true,
      sanitize: false,
      smartLists: true,
      smartypants: false,
      xhtml: false
    })
    marked.use({ renderer })
    return marked.parse(body)
  }
  fetch(`${apiURL}/get/${speakId}`)
  .then(response => response.json())
  .then(res => {
    const data = res.data;
    if(data){
      const {title,content} = data;
      const contentSub = content.substring(0, 30);
      document.querySelector('.content').innerHTML = markedRender(content);
      if(title){
        document.title = title;
      }
      new Artalk({
        el: '.ispeak-comment',
        pageKey: path + '?q=' + speakId,
        pageTitle: title || contentSub,
        server: 'https://api.antmoe.com/artalk/',
        site: 'speak', // 你的站点名
        useBackendConf: true,
      })
    }
  });
  
</script>
```

**自用：**

```html
<div class="js-pjax" id="tip" style="text-align:center;">ipseak加载中</div>
<div class="js-pjax" id="ispeak"></div>
<link
  rel="stylesheet"
  href="https://cdn.staticfile.org/highlight.js/10.6.0/styles/atom-one-dark.min.css"
/>
<link
  rel="stylesheet"
  href="https://cdn1.tianli0.top/npm/ispeak@4.4.0/style.css"
/>

<style>
  #article-container .D-avatar {
    margin: 0 10px 0 0;
  }
  .D-footer {
    display: none;
  }
</style>
<script src="https://cdn.staticfile.org/highlight.js/10.6.0/highlight.min.js"></script>
<script src="https://cdn.staticfile.org/marked/2.0.0/marked.min.js"></script>
<script src="https://cdn1.tianli0.top/npm/ispeak@4.4.0/ispeak.umd.js"></script>
<script>
  var head = document.getElementsByTagName('head')[0]
  var meta = document.createElement('meta')
  meta.name = 'referrer'
  meta.content = 'no-referrer'
  head.appendChild(meta)
  if (ispeak) {
    ispeak
      .init({
        el: '#ispeak',
        api: 'https://kkapi-open-six.vercel.app/',
        author: '你的个人ID',
        pageSize: 10,
        loading_img: 'https://bu.dusays.com/2022/05/01/626e88f349943.gif',
        speakPage: '/say',
        githubClientId: '你的githubClientId',
        hideComment: true,
      })
      .then(function () {
        console.log('ispeak 加载完成')
        document.getElementById('tip').style.display = 'none'
      })
  } else {
    document.getElementById('tip').innerHTML = 'ipseak依赖加载失败！'
  }
</script>
```

> 注意：
>
> 1. 从v4.4.0的上一个版本v4.3.3就可以添加`hideComment: true,`隐藏评论
> 2. ~~Artalk还未搭建好，故没有加入相关字段。~~评论搞不定，算了。感觉说说没必要弄评论。只能用V4.3.3了，或者新版本关闭评论。

## 首页轮播

参考上面，在Hexo博客目录中的`source/_data`（如果没有 _data 文件夹，请自行创建），创建一个文件 widget.yml，代码如下：

```yaml
top:
  - class_name: latestBB
    id_name:
    name: Ispeak
    icon: fas fa-bolt
    order: 2
    html: |
      <div class="swiper-container swiper-container-aside">
        <div class="swiper-wrapper swiper-weapper-aside"></div>
      </div>
      <a class="bb-btn button--animated" href="/say/" title="查看全部"><i class="far fa-hand-point-right fa-fw"></i> 查看更多 </a>
      <script>
        window.kkBBConfig = {
          limit: 10,
          blog:'/say/',
          api_url: '你的api地址（末尾不要/）',
          author: '你的个人ID'            
        }
      </script>
      <script src="https://cdn1.tianli0.top/npm/iwyang@1.0.8/speak/butterfly-speak-swiper@1.1.0.min.js"></script>
```

> 如若轮播j`js`CDN用不了，上面轮播`js`可改成本地：`/img/js/speak/butterfly-speak-swiper@1.1.0.min.js`



上面是自己瞎改的，不过能用。最后可以看上面`解决移动端二级菜单缩进问题`，解决缩进问题。**下面是官方解答：[怎样使ispeak实现首页轮播](https://github.com/kkfive/kkapi-open/issues/2)**



>我个人的方法是通过挂载在侧边栏，然后侧边栏引用js动态插入顶部轮播位置。
>
>
>
>参考代码：

```yaml
bottom:
  - class_name: latestBB
    id_name:
    name: Ispeak
    icon: fas fa-bolt
    order: 2
    html: |
      <div class="swiper-container swiper-container-aside">
        <div class="swiper-wrapper swiper-weapper-aside"></div>
      </div>
      <a class="bb-btn button--animated" href="/speak/" title="查看全部"><i class="far fa-hand-point-right fa-fw"></i> 查看更多 </a>
      <script>
        window.kkBBConfig = {
          limit: 9,
          blog:'/speak',
          api_url: 'api地址',
          author: '你的用户token'
        }
      </script>
      <script src="https://cdn1.tianli0.top/npm/butterfly-speak-swiper@1.1.0/dist/index.min.js"></script>
```

### 去掉侧边栏最新说说

在 `blog/source/css/custom.css` 文件中，加入以下代码即可。

```css
/* 去掉侧边栏最新吐槽 */
.latestBB {
display: none;
}
```

## 发送speak方式

参考：[发送方式](https://kkapi-doc.vercel.app/posts/ispeak/send-mode.html)



### 安卓手机上快捷方式发送

> 此部分转自：https://blog.leonus.cn/2022/talkInAndroid.html

#### 获取api的url

这个很好弄，只需要在你部署的API地址后面加上`/api/ispeak/addByToken`即可
如：`https://xxx.vercel.app/api/ispeak/addByToken`（不是后台的地址，而是api的地址，也就是你部署的时候第一个部署的那个）

#### 获取标签id

> 用谷歌浏览器简单些，如果开发者工具是英语，可点击右上角小齿轮切换成中文。

1.先登录到`Ispeak管理后台`，并切换到`Ispeak标签管理`。



2.然后按F12打开`开发者工具`，依次点击`Network(网络)`—`Fetch/XHR`—刷新网页—找到`getByPage...`(总共就两个，鼠标**选择下面一个**。)— 选中`响应`然后点击左下角的一个`{}`进行格式化（美观输出），我们分别复制id(name上面的id，不是user厘米俺的id，别弄混了)发送到手机即可(**记清楚对应的标签**，别到时候弄混了)
详细请看下图：

![](../img/hexo%E9%85%8D%E7%BD%AE%E5%93%94%E5%93%94%E7%82%B9%E5%95%A5&&Speak/kzt.png)

#### 获取token网页端发送

在后台的设置里，找到 设置 > 个人设置 > Tokens > 添加token
标题填写`speak`，值随便填。将填写的值发送到手机。

#### 下载软件

下载`HTTP Shortcuts`，可以直接使用谷歌搜索下载(推荐)
也可以通过Github下载：https://github.com/Waboodoo/HTTP-Shortcuts/releases
不确定手机什么内核的可以下载`app-universal-release.apk`



#### **添加变量**

1.点击右上角三个点 > 变量，点击加号，选择`输入文本`，名称填`content`，标题可以填：说说内容，下面的对话框可填可不填，这都不是必须的。



输入选项选中`多行`,高级设置选中`JSON编码`，然后点右上角对号进行保存。

![](../img/hexo%E9%85%8D%E7%BD%AE%E5%93%94%E5%93%94%E7%82%B9%E5%95%A5&&Speak/content.jpg)

2.再点击加号，选择`选项`，名称填`tag`，对话框标题可填：标签，然后添加选项。标签填写你的标签的名字，值填写你的标签对应的ID，然后点确定。
如果有多个标签可以继续添加，高级设置选中`JSON编码`，都添加完之后点右上角对号进行保存。

![](../img/hexo%E9%85%8D%E7%BD%AE%E5%93%94%E5%93%94%E7%82%B9%E5%95%A5&&Speak/tags.jpg)

3.再点击加号，选择`选项`，名称填`type`，对话框标题可填：`可视范围`，然后添加以下3个选项。标签填写你的标签的名字，值填写`0`、`1`、`2`。

```
1.标签：公开         值：0
2.标签：登录可见      值：1
3.标签：仅自己        值：2
```

填完后记得高级设置选中`JSON编码`，都添加完之后点右上角对号进行保存。

![](../img/hexo%E9%85%8D%E7%BD%AE%E5%93%94%E5%93%94%E7%82%B9%E5%95%A5&&Speak/type.jpg)

#### 添加快捷方式

返回主页面，点击加号，选择最上面的`新建快捷方式`，名称随便，描述随便。

1.点击`基本设置`，方法选择`POST`，URL填写上面获取的`API的URL`，然后返回

![](../img/hexo%E9%85%8D%E7%BD%AE%E5%93%94%E5%93%94%E7%82%B9%E5%95%A5&&Speak/kj.jpg)

2.点击`请求头`，点击加号，头部填写`Content-Type`，值填写`application/json`，确定然后返回

3.再点击`响应体/响应参数`，选择`自定义类型`，Content-Type填写`application/json`，请求体填写：(最好不要直接点复制按钮复制代码，直接拖动选择所有行代码，这样张贴就会保留空格)

```json
{
    "token": "你的token值",
    "tag": "{tag}",
    "content": "{content}",
    "type": "{type}",
    "showComment": "1"
}
```

{% note warning flat %}
注意：上面的`{tag}`和`{content}`以及`{type}`需要先删除，然后点击旁边的`{}`插入变量（插入的变量颜色是蓝色）。不能直接填写！！！
tag和content还有type顺序决定你发布时弹窗的先后，tag在上就是先选择标签再输入内容，content在上就是先输入内容再选择标签。
{% endnote %}

![](../img/hexo%E9%85%8D%E7%BD%AE%E5%93%94%E5%93%94%E7%82%B9%E5%95%A5&&Speak/url.jpg)

全部填写完之后保存即可，点击快捷方式就可以实现发送说说了。
长按快捷方式可以将此快捷方式添加到桌面，想发说说时直接点击即可，方便至极。

### 网页端发送

进入[ispeak-biubiu](https://ispeak-biubiu.vercel.app/)页面，首先配置基础配置。

> + API地址：URL后面要加`/api`
> + Token：token的名称必须为`speak`



![](../img/hexo%E9%85%8D%E7%BD%AE%E5%93%94%E5%93%94%E7%82%B9%E5%95%A5&&Speak/speak.jpg)



#### 自己部署`ispeak-biubiu`



仓库地址：[speak-biubiu](https://github.com/kkfive/speak-biubiu)，（直接部署到Vercel不会，所以采用了一种笨方法）



1.首先fork一份备份，然后下载一份源码到本地，进入项目目录，执行以下命令（过程会很慢）：

```bash
npm install
npm run build
npm run preview
```
2.然后将`dist` 这个文件夹里面的网页上传到GitHub，最后再部署到Vercel。



> ispeak-biubiu为Vite项目，更多使用说明查看：https://cn.vitejs.dev/
>
> **默认情况下，执行`npm run build`构建会输出到 `dist` 文件夹中。你可以部署这个 `dist` 文件夹到任何你喜欢的平台。**



>PS：可以直接fork此仓库：[iwyang/say](https://github.com/iwyang/say)，然后部署到`Vercel`

### 后台发送

进入后台新增即可。**更多发送方式查看：[发送方式](https://kkapi-doc.vercel.app/posts/ispeak/send-mode.html)**

## 参考链接

[「哔哔点啥」微信公众号 2.0](https://immmmm.com/bb-by-wechat-pro/)

[手把手教你配置哔哔点啥](https://www.fanziqi.site/posts/af935eab.html)

[Android “捷径”・木木 bber 踩坑记录 + 电脑 or 手机 4 种方式直发说说](https://guole.fun/posts/bber-caikeng/)

[给 bber 换个皮肤](https://www.antmoe.com/posts/7ec820ee/)

[bber说说首页轮播](https://guole.fun/posts/butterfly-custom/#bber%E8%AF%B4%E8%AF%B4%E9%A6%96%E9%A1%B5%E8%BD%AE%E6%92%AD)

[bber的style导致'child menu items'缩进问题](https://gitlab.com/DreamyTZK/ispeak-bber/-/issues/2)

[Hexo博客哔哔更换记录](https://blog.leonus.cn/2022/bb.html)

[短文 | CC的部落格](https://blog.ccknbc.cc/essay)

[申请免费的 MongoDB 数据库 | Discuss 开源免费评论系统](https://discuss.js.org/guide/Get-MongoDB-DataBase.html)

[在安卓手机上快捷发送说说(哔哔)](https://blog.leonus.cn/2022/talkInAndroid.html)

[KKapi+ISpeak说说页面部署](https://braindance.top/posts/kkapi+ispeak%E8%AF%B4%E8%AF%B4%E9%A1%B5%E9%9D%A2%E9%83%A8%E7%BD%B2/)
