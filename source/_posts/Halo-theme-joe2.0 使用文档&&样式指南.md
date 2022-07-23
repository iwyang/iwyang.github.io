---
title: Halo-theme-joe2.0 使用文档&&样式指南
categories:
  - 技术
tags:
  - halo
abbrlink: 2df9228b
date: 2022-05-25 21:27:46
cover: ../img/cover/joe.jpg
---

本文参考： 
+ [Halo-theme-joe2.0 食用文档](https://bbchin.com/archives/halo-theme-joe20)
+ [Joe2.0 样式指南](https://bbchin.com/archives/style-guideline)

## 安装 & 更新
>安装前请确保 Halo版本 和主题的兼容性，V1.0.10 及以上版本仅支持 Halo 1.5+，以下版本兼容到 Halo 1.4.11，请知悉。

1. 复制主题仓库地址 https://github.com/qinhua/halo-theme-joe2.0.git

2. 进入博客后台管理 外观-主题-安装-远程下载，贴入仓库地址进行安装（建议直接使用最新版本 ）。
如果在线安装失败（大概率失败 😆 ），那就选择 本地上传，到主题 Release 页面下载指定版本主题压缩包，并上传上去（务必在 Release 页面下载压缩包，否则可能出现资源加载出错的问题）；

3. 等待提示安装完成即可；

4. 更新主题时，建议直接通过 外观-主题-Joe2.0-更多-从主题包更新 把下载好的 zip 包上传上去，然后 先切换到其他主题，再切回本主题，并进入主题设置执行一次保存，最后强刷前端页面即可（这里切主题主要是为了避免有时候主题状态未激活和缓存的问题）。

## 注意事项
1. 安装主题后请务必到 后台管理 - 博客设置 - 高级选项 中开启 API服务 并配置 Access key 为 joe2.0（切记要和主题设置中的 AccessKey 一致），不然部分用到 Content API 的页面会请求失败并报错。（请参考以下报错）

```bash 
“API has been disabled by blogger currently” —— 后台管理中未开启API服务
“API access key is mismatch” —— 主题中的 AccessKey 和后台管理中的不一致
```
2. 如果后台管理中之前已经配置了其它的 Access Key（内容不是 joe2.0），那么需要你到本主题设置中的 基本设置-AccessKey<必填> 同步一下这个 Access key，保证两部一致即可（切记一致才行，且不要填写中文或特殊字符）。

3. 有时，主题升级后配置项变化较大，直接访问博客可能会报错，导致页面渲染不出来。此时，只需要进入当前主题的设置界面执行一下保存操作来更新旧的配置，然后再访问页面即可；

4. 有时，明明已经提示主题更新成功了，但访问博客时页面还是加载的旧版本的文件，可能是由于 主题激活状态不正常 或 主题缓存的问题 导致的。此时，只需要先启用其他主题再启用本主题即可，建议每次更新主题之后都做一下这个操作（目前后台管理系统还不太完善）。还有就是如果你配置了 CDN 服务，记得清理相应节点的缓存，让它回源取最新资源。

5. 强烈建议 每次更新主题后，务必先清空一下浏览器缓存，保证加载的资源都是最新版本的，并到主题设置中执行一次保存，保证配置项是最新的，不然可能有各种报错（你可以通过 Ctrl + F5 强制刷新或者 Ctrl + Shift + DEL 清空浏览器所有缓存）。

6. 最后，建议大家在 后台管理-系统-博客设置-高级选项-其他设置 中开启 全局绝对路径。

## 插入多媒体
### 插入音乐
怎样在文章中插入网易云播放器？

>id：网易云歌单 ID 或 歌曲 ID（可从歌曲网址中获取）

+ 歌单
```
<joe-mlist id="6800335663"></joe-mlist>

```
+ 单曲
```
<joe-music id="1303046498"></joe-music>
```

+ 本地音乐
```
<joe-mp3
  name="天生狂野-柴古唐斯主题曲"
  url="https://bbchin.com/upload/2022/04/%E5%A4%A9%E7%94%9F%E7%8B%82%E9%87%8E-%E6%9F%B4%E5%8F%A4%E5%94%90%E6%96%AF%E4%B8%BB%E9%A2%98%E6%9B%B2.mp3"
  theme="red"
  cover="https://bbchin.com/upload/2022/04/cgts.png"
  autoplay
></joe-mp3>
```
### 插入视频
文章中如何插入视频？
>主题已集成 dplayer，只需要在编辑文章时使用 joe-dplayer 标签插入视频地址即可（建议 MP4 格式，其它格式未必支持，切记前后要空一行），它接受如下属性：

+ src：视频地址（必传）
+ width：阅读器宽度，默认为 100%
+ height：阅读器高度，默认 500px
```bash
<joe-dplayer src="https://xxx.mp4"></joe-dplyer>
```
如果你想嵌入 **B站视频**，可以使用 joe-bilibili 标签（切记前后要空一行），它接受如下属性（相关参数可以从视频地址中获取）。
+ bvid：视频的 id（必传）
+ page：视频的 page，即分页
+ width：阅读器宽度，默认为 100%
+ height：阅读器高度，默认 500px

```
<joe-bilibili bvid="BV12h411k7vr"></joe-bilibili>
```
## 文本元素
### 段落缩进
```html
<p class="indent">
  有些男人就像烤面筋，外表黄黄的，身体圆圆的，说话柔柔的，无害，看上去还非常好吃。可当你吃下去，才知道他绵绵的，并无特别的味道，甚至到你吃完，你都不知道他是用什么做的。
  ---- 李七毛《我们都不擅长告别》
</p>
```
### 居中标题
```html
<joe-mtitle title="牛鞭牛鞭"></joe-mtitle>
````
## 按钮元素
### 多彩按钮
```
<joe-abtn color="#409eff" content="多彩按钮"></joe-abtn>
```
<joe-abtn color="#409eff" content="多彩按钮"></joe-abtn>

```
<joe-abtn icon="fa-bell" content="带图标按钮"></joe-abtn>
```
<joe-abtn icon="fa-bell" content="带图标按钮"></joe-abtn>
```
<joe-abtn radius="12px" content="圆角按钮"></joe-abtn>
```
<joe-abtn radius="12px" content="圆角按钮"></joe-abtn>

### 便条按钮
>便条按钮不能自定义色彩，必须使用一个图标，其他的的和上面的多彩按钮一样

```
<joe-anote href="#" type="secondary" content="便条按钮"></joe-anote>
<joe-anote icon="fa-bus" href="#" type="success" content="便条按钮"></joe-anote>
<joe-anote icon="fa-bus" href="#" type="warning" content="便条按钮"></joe-anote>
<joe-anote icon="fa-bus" href="#" type="error" content="便条按钮"></joe-anote>
<joe-anote icon="fa-bus" href="#" type="info" content="便条按钮"></joe-anote>
```
<joe-anote href="#" type="secondary" content="便条按钮"></joe-anote>
<joe-anote icon="fa-bus" href="#" type="success" content="便条按钮"></joe-anote>
<joe-anote icon="fa-bus" href="#" type="warning" content="便条按钮"></joe-anote>
<joe-anote icon="fa-bus" href="#" type="error" content="便条按钮"></joe-anote>
<joe-anote icon="fa-bus" href="#" type="info" content="便条按钮"></joe-anote>
### 网盘按钮
```
<joe-cloud type="default" url="" password=""></joe-cloud>
<joe-cloud type="360" url="" password=""></joe-cloud>
<joe-cloud type="bd" url="" password="bn6f"></joe-cloud>
<joe-cloud type="ty" url="" password=""></joe-cloud>
<joe-cloud type="ct" url="" password=""></joe-cloud>
<joe-cloud type="wy" url="" password=""></joe-cloud>
<joe-cloud type="github" url="" password=""></joe-cloud>
<joe-cloud type="gitee" url="" password=""></joe-cloud>
<joe-cloud type="lz" url="" password=""></joe-cloud>

```
<joe-cloud type="default" url="" password=""></joe-cloud>
<joe-cloud type="360" url="" password=""></joe-cloud>
<joe-cloud type="bd" url="" password="bn6f"></joe-cloud>
<joe-cloud type="ty" url="" password=""></joe-cloud>
<joe-cloud type="ct" url="" password=""></joe-cloud>
<joe-cloud type="wy" url="" password=""></joe-cloud>
<joe-cloud type="github" url="" password=""></joe-cloud>
<joe-cloud type="gitee" url="" password=""></joe-cloud>
<joe-cloud type="lz" url="" password=""></joe-cloud>

## 装饰元素
### 跑马灯
```html
<span class="joe_lamp"></span>
```
<span class="joe_lamp"></span>

### 进度条
```
<joe-progress percentage="50%" color="#6ce766"></joe-progress>
```
<joe-progress percentage="50%" color="#6ce766"></joe-progress>

### 彩色虚线
```
<joe-dotted></joe-dotted>
<joe-dotted startcolor="#1772e8" endcolor="#4cd327"></joe-dotted>
```
<joe-dotted></joe-dotted>
<joe-dotted startcolor="#1772e8" endcolor="#4cd327"></joe-dotted>

### Tabs
```
<joe-tabs>
  <div class="_tpl">
    {tabs-pane 第一个}单身狗的故事{/tabs-pane}
    {tabs-pane 第二个}小说家的故事{/tabs-pane}
  </div>
</joe-tabs>
```
<joe-tabs>
  <div class="_tpl">
    {tabs-pane 第一个}单身狗的故事{/tabs-pane}
    {tabs-pane 第二个}小说家的故事{/tabs-pane}
  </div>
</joe-tabs>

### 时间线
```
<joe-timeline>
 <div class="_tpl">
   {timeline-item 2020}10元{/timeline-item}
   {timeline-item 2021}20元{/timeline-item}
   {timeline-item 2022}100元{/timeline-item}
 </div>
</joe-timeline>
```
<joe-timeline>
 <div class="_tpl">
   {timeline-item 2020}10元{/timeline-item}
   {timeline-item 2021}20元{/timeline-item}
   {timeline-item 2022}100元{/timeline-item}
 </div>
</joe-timeline>

### 评论后可见
```
<joe-hide></joe-hide>
```
## 提示元素
```
<joe-message type="success" content="成功消息"></joe-message>
<joe-message type="info" content="普通消息"></joe-message>
<joe-message type="warning" content="警告消息"></joe-message>
<joe-message type="error" content="错误消息"></joe-message>

```
<joe-message type="success" content="成功消息"></joe-message>
<joe-message type="info" content="普通消息"></joe-message>
<joe-message type="warning" content="警告消息"></joe-message>
<joe-message type="error" content="错误消息"></joe-message>

## 常见问题
1.如何自定义导航条菜单图标？

>主题自身已经引入了部分 iconfont 图标，你可以直接用（全在这里），如果想在这个基础上增加图标，可联系我加入该项目的图标组，加入后即可获取最新的字体链接进行替换（template/module/link.ftl 中第 25 行）。iconfont 使用方式如下：
（目前主题菜单只支持字体图标，若要用图片请自行修改代码）

2.如何设置文章仅评论后可见？

>主题目前支持文章页的 评论后可见功能，只要在后台管理中发布文章时设置-元数据 enable_read_limit 为 true 即可。设置之后>文章页默认只展示一屏高度的内容，剩余内容需要评论后才可见（如果文章内容小于一屏高度，则此功能会被忽略）。

3.怎样开启防盗链

很简单，直接在 nginx 里配一下就可以，不过记得添加白名单（如 logo 和 avatar），配置如下：
```nginx
# 资源防盗链（指定目录or指定文件类型）
# location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$ {
location /upload/ {
  access_log off;
  # 域名白名单，去掉则阻止所有非本站请求
  valid_referers none blocked server_names *.bbchin.com 127.0.0.1 localhost ~\.google\. ~\.baidu\. ~\.qq\.;
  if ($invalid_referer) {
    rewrite ^/ https://cdn.jsdelivr.net/gh/qinhua/cdn_assets/img/robber.jpg;
  }
  proxy_pass http://127.0.0.1:8090;
}
```
4.怎样配置合适的缓存策略

合理利用浏览器的缓存同样可以优化页面性能，提高加载速度，我们可以通过 Nginx 对相关资源的响应头进行配置，大致如下：
```
location / {
    gzip_static on; # 静态压缩
    add_header Cache-Control public,max-age=60,s-maxage=60; # 配置缓存
    proxy_set_header HOST $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass http://127.0.0.1:8090;
}
```
## 主题修改
修改首页文章数、分类数、标签数顺序：
自行修改 template/module/blogger.ftl 文件
```html
    <#if settings.overview_type == 'A'>
	  <@postTag method="count">
        <div class="item" title="累计文章数 ${count!'0'}">
          <span class="num">${count!'0'}</span>
          <span>文章数</span>
        </div>
      </@postTag>
      <@categoryTag method="count">
        <div class="item" title="累计分类数 ${count!'0'}">
          <span class="num">${count!'0'}</span>
          <span>分类数</span>
        </div>
      </@categoryTag>
      <@tagTag method="count">
        <div class="item" title="累计标签数 ${count!'0'}">
          <span class="num">${count!'0'}</span>
          <span>标签数</span>
        </div>
      </@tagTag>
```

