---
title: Hexo-NexT (v7.7.2) 主题配置
categories:
  - 技术
tags:
  - hexo
abbrlink: '35679e29'
date: 2020-04-26 12:03:16
cover: false
---
<div class="note info"><p>2020.8.1 Hexo 5.0后要将主题配置文件复制到站点根目录，然后重命名为 _config.next.yml</p></div>

##  获取 NexT 
### 下载[最新 release 版本](https://github.com/theme-next/hexo-theme-next/releases/latest)
通常情况下请选择 stable 版本。推荐不熟悉的用户按此方式进行。

这种方式将仅提供最新的 release 版本（其中不附带 `.git` 目录）。因此，你无法通过 git 更新这一方式安装的主题。

> **更新：推荐使用独立的配置文件（数据文件）而不在主题源代码进行更改，便于后续的更新（下载最新版本，替换掉旧版本）**。
>
> ##  站点配置
### 设置 hexo 的 next 主题
我们在站点的配置文件`_config.yml`中找到 theme 后修改：
`theme: next  # 配置成刚下载的next主题`
### 配置 hexo 网站相关信息
```yaml
# Site
title:          # 网站标题
subtitle:       # 网站副标题
description:    # 描述，介绍网站的
keywords:       # 网站的关键字
author:         # 博主姓名
language: zh-CN # 语言：zh-CN 是简体中文
timezone: ''    #时区，默认不填就好，如果要填，填Asia/Shanghai
```
### 设置 hexo 永久链接

本着简单原则，在站点配置文`_config.yml`件里将固定链接改成：

```yaml
url: https://bore.vip
root: /
permalink: archives/:title/
```

### nofollow 标签的使用
减少出站链接能够有效防止权重分散，hexo 有很方便的自动为出站链接添加 `nofollow` 标签的插件。
首先安装 `hexo-filter-nofollow` 插件：
`npm install hexo-filter-nofollow --save`
然后我们在站点的配置文件`_config.yml` 中添加配置，将 `nofollow` 设置为 `true`：
```yaml
# 外部链接优化
nofollow:
  enable: true
  field: site
  exclude:
    - 'exclude1.com'
    - 'exclude2.com'
```
其中 `exclude`（例外的链接，比如友链）将不会被加上 `nofollow` 属性。
### 站点地图 sitemap 生成
`npm install hexo-generator-sitemap --save`
然后我们需要在 Hexo 站点配置文件中加入 sitemap 插件：
```yaml
# 通用站点地图
sitemap:
  path: sitemap.xml
```
### 修改网站的图标 Favicon

把图标放在 /themes/next/source/images 里，并且修改 主题配置文件（next.yml）：

```yaml
favicon:
  small: /images/favicon-16x16-next.png
  medium: /images/favicon-32x32-next.png
  apple_touch_icon: /images/favicon-32x32-next.png
  safari_pinned_tab: /images/favicon-32x32-next.png
  #android_manifest: /images/manifest.json
  #ms_browserconfig: /images/browserconfig.xml
```

## 主题配置

### 准备工作，配置文件分离
Next主题在7.3之后分离了配置文件与主题，详情请见[小丁的个人博客](https://tding.top/archives/2bd6d82.html)
* 新建文件夹`hexo/source/_data`
* 将`./themes/next/_config.yml`复制到`hexo/source/_data`路径下并重命名为`next.yml`
* 将`next.yml`中的`override`设置为`true`即可作为主题的配置文件使用
```
override: true
```

* 在`hexo/source/_data`中新建`body-end.swig`和`styles.styl`文件
* 然后在`next.yml`的`custom_file_path`中删除前面的`#`来启用`bodyEnd`和`style`
* `custom_file_path`中的其他选项根据需要创建相关文件并启用
### 指定next-Gemini模板
主题配置文件（next.yml），关键字：`Schemes`,修改
```yaml
#scheme: Muse
#scheme: Mist
#scheme: Pisces  #打开前面的注释
scheme: Gemini
```
* **Muse** - 默认 Scheme，这是 NexT 最初的版本，黑白主调，大量留白
* **Mist** - Muse 的紧凑版本，整洁有序的单栏外观
* **Pisces** - 双栏 Scheme，小家碧玉似的清新
* **Gemini** - 左侧网站信息及目录，块+片段结构布局
### 配置 hexo 中的 about、tag、categories、sitemap 菜单
默认的主题配置文件`_config.yml`（next.yml） 中，菜单只开启了首页和归档，我们根据需要，可以添加 about、tag、categories、sitemap 等菜单，所以把它们也取消注释。
```yaml
# 菜单设置为 菜单名: /菜单目录 || 菜单图标名字
menu:
  home: / || home
  about: /about/ || user
  tags: /tags/ || tags
  categories: /categories/ || th
  archives: /archives/ || archive
  #schedule: /schedule/ || calendar
  sitemap: /sitemap.xml || sitemap
  commonweal: /404/ || heartbeat

menu_settings:
  icons: true   # 显示图标
  badges: true  # 显示统计信息
```
注：hexo 所有图标均来自 fontawesome，其中 `||` 后面是你想要设置的图标的名字。
菜单项的中文文本翻译见[菜单中文翻译](http://bore.vip/archives/39662a01.html#%E8%8F%9C%E5%8D%95%E4%B8%AD%E6%96%87%E7%BF%BB%E8%AF%91)

### 手动生成 hexo 菜单对应文件
#### 新建 about 页面
我们可以在博客根目录下输入以下命令新建页面：
`hexo new page about`
然后你会发现多了一个 hexo/source/about 文件夹，里面有一个 index.md 文件，你可以根据自己的需要在这个 Markdown 文件中写一些内容（同文章一样，用 Markdown 语法）。
#### 新建一个 tags 页面
同样的，我们可以新建 `tags` 页面：
`hexo new page tags`
在 `tags` 页面文件 `hexo/source/tags/index.md` 的头部修改为：
```yaml
---
title: 标签
date: 2020-04-26 00:13:30   # 时间随意
type: "tags"                # 类型一定要为tags
comments: false             # 提示这个页面不需要加载评论
---
```
#### 新建一个 categories 页面
同样的，我们可以新建 categories 页面：
`hexo new page categories`
在 categories 页面文件 hexo/source/categories/index.md 的头部修改为：

```yaml
---
title: 文章分类
date: 2020-04-26 00:15:00
type: "categories"
comments: false
---
```
#### 新建一个 404 页面
这里我们将 404 替换成腾讯的公益页面。
首先我们在 `hexo/source` 目录下创建自己的 `404.html`：
```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>404</title>
    </head>
    <body>
        <script type="text/javascript" src="//qzonestyle.gtimg.cn/qzone/hybrid/app/404/search_children.js" charset="utf-8" homePageUrl="/" homePageName="返回"></script> 
    </body>
</html>
```
注意：Hexo 博客的基本内容是一些 Markdown 文件，放在 source/_post 文件夹下，每个文件对应一篇文章。除此之外，放在 source 文件夹下的所有开头不是下划线的文件，在 hexo generate 的时候，都会被拷贝到 public 文件夹下。但是，Hexo 默认会渲染所有的 HTML 和 Markdown 文件。

因此我们可以简单地在文件开头加上 layout: false 一行来避免渲染：
```html
layout: false
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>404</title>
    </head>
    <body>
        <script type="text/javascript" src="//qzonestyle.gtimg.cn/qzone/hybrid/app/404/search_children.js" charset="utf-8" homePageUrl="/" homePageName="返回"></script> 
    </body>
</html>
```
这样我们就完成了 404 页面的创建。注意：本地测试不出来，发布出来就### 配置 hexo 本地搜索可以了。
### 配置 hexo 本地搜索
#### 本地搜索的原理
对于动态网站来说，可以通过 php 实现。但是，Hexo 博客是静态网站，用不了 php。
NexT 主题已经实现这个功能，它用了 Hexo 的拓展包 hexo-generator-searchdb，预先生成了一个文本库 search.xml，然后传到了网站里面。在本地搜索的时候，NexT 直接用 javascript 调用了这个文件，从而实现了静态网站的本地搜索。
#### 设置过程
安装插件:
`npm install hexo-generator-searchdb --save`
然后我们修改站点配置_config.yml 文件，添加如下内容：
```yaml
# 本地搜索
search:
  path: search.xml
  field: all
  format: html
  limit: 100
```
path：索引文件的路径，相对于站点根目录
field：搜索范围，默认是 post，还可以选择 page、all，设置成 all 表示搜索所有页面
limit：限制搜索的条目数
然后修改主题配置文件`_config.yml`（next.yml）：

```yaml
# Local Search
# Dependencies: https://github.com/theme-next/hexo-generator-searchdb
local_search:
  enable: true
  # If auto, trigger search by changing input.
  # If manual, trigger search by pressing enter key or search button.
  trigger: auto
  # Show top n results per article, show all results by setting to -1
  top_n_per_article: 1
  # Unescape html strings to the readable one.
  unescape: false
  # Preload the search data when the page loads.
  preload: false
```
  ### utterances评论系统&&valine 评论

<div class="note danger">如果使用utterances评论系统，一定要先关闭Pjax插件，否则utterances评论无法登陆</div>

```yaml
pjax: false
```

#### utterances评论系统

<div class="note primary">注意NexT 8.1.0起没有用valine</div>

具体见：[Hide options of Valine](https://github.com/next-theme/hexo-theme-next/commit/a4a1cdcf2002276783406093a1653b021bdd043e)

##### 创建 Github 仓库 

utterance 使用 Github 保存评论，那我们就需要创建一个 `repository` 专门保存评论。你也可以将评论放在发布网页的仓库，注意要是公共仓库。

##### 授权

 用户在博客页面上输入评论，utterance 拿到这个评论后，自动的提交到上面刚创建仓库的 Issues 里。

所以我们需要授权 utterance 应用能访问仓库的 Issues。

点击链接： https://github.com/apps/utterances ，点击选择`Only select repositories`，选中相应的仓库。

##### 主题配置

```yaml
utterances:
  enable: true
  repo: iwyang/comments
  # Available values: pathname | url | title | og:title
  issue_term: title
  # Available values: github-light | github-dark | preferred-color-scheme | github-dark-orange | icy-dark | dark-blue | photon-dark | boxy-light
  theme: github-light
```

解释一下主要参数：

+ repo：存放评论的issues的仓库名
+ issue-term：指定issues的标题，`title`表示使用文章的标题作为issues的标题，推荐使用这个。（pathname：网址域名之外的文件名；url：博客网址，网址全路径；title：博客标题）

##### 回复评论方法

使用markdown语法引用，或者进issues里评论，或者直接在评论区`@用户名`然后再加上评论。

```yaml
>  这里引用别人的评论

这里是你要回复的评论，中间要空一行
```

#### valine评论

  ##### 获取 APP id 和 APP key

注意右上角选择**国际版**。

  * 你可以点击 LeanCloud ，注册登录，进入控制台后点击创建应用。
  * 进入刚刚创建的应用，选择设置 》应用Keys，就能看到你的 APP ID 和 APP Key

##### 修改主题配置文件

注意`guest_info`这一栏，删除link，评论框就没有网址选项。

 ```yaml
 # Valine
# You can get your appid and appkey from https://leancloud.cn
# For more information: https://valine.js.org, https://github.com/xCss/Valine
# 配置项详情请查阅官方文档。
valine:
  enable: true # 开启评论功能
  appid:  # 填入刚刚获取的APP ID
  appkey: # 填入刚刚获取的APP key
  notify: false # 邮件通知默认关闭
  verify: false # 验证码默认关闭
  placeholder: 在这里写下你的评论吧！ # 评论框默认文字
  avatar: mm # 头像风格
  guest_info: nick,mail #,link # Custom comment header
  pageSize: 10 # Pagination size
  language: # Language, available values: en, zh-cn
  visitor: false # leancloud-counter-security is not supported for now. When visitor is set to be true, appid and appkey are recommended to be the same as leancloud_visitors' for counter compatibility. Article reading statistic https://valine.js.org/visitor.html
  comment_count: false # If false, comment count will only be displayed in post page, not in home page
  recordIP: false # 是否记录IP
  serverURLs: # When the custom domain name is enabled, fill it in here (it will be detected automatically by default, no need to fill in)
  #post_meta_order: 0
 ```
##### valine评论标题改中文中文        

打开`themes -> next -> languages -> zh-CN.yml`

```
# 在post标签下添加如下代码
comments:
    valine: 评论数 # 这里的中文随便自己定义
```

  ### 设置 hexo 中的 rss 订阅

  没有用，不推荐
  ### 配置 hexo 主题next.yml的 footer 信息
底部 `footer` 可以开关显示 hexo 信息、theme 信息、建站时间等个性化配置：  
```yaml
footer:
  since: 2020        # 建站开始时间
  icon:
    name: user       # 设置 建站初始时间和至今时间中间的图标，默认是一个'小人像'，更改user为heart可以变成一个心
    animated: true
    color: "#808080" # 更改图标的颜色，红色为'#ff0000'
  powered:
    enable: true     # 开启hexo驱动
    version: true    # 开启hexo版本号
  theme:
    enable: true     # 开启主题驱动
    version: true    # 开启主题版本号
  custom_text: Hosted by <a target="_blank" rel="external nofollow" href="https://pages.coding.me"><b>Coding Pages</b></a> # 这里的底部标识是为了添加coding page服务时的版权声明 打开注释就可以看到底部有一个 hosted by coding pages
```
### 头像信息设置 next.yml
```yaml
avatar:
  url: /images/avatar.jpg  # 设置头像资源的位置
  rounded: true            # 开启圆形头像
  opacity: 1               # 不透明的比例：0就是完全透明
  rotated: false           # 不开启旋转
```
### 社交信息和友链配置
这里和菜单设置格式一样，社交名字: 社交url || 社交图标，图标信息来自 [fontawesome](https://fontawesome.com/v4.7.0/icons)：
```yaml
social: 
  GitHub: https://github.com/yourname || github
  E-Mail: mailto:yourname@gmail.com || envelope
  Google: https://plus.google.com/yourname || google

social_icons:
  enable: true      # 显示社交图标
  icons_only: false # 只显示图标，不显示文字
```
友链配置：
```yaml
# Blog rolls
links_icon: link          # 友链的图标 参考上文
links_title: Links        # 友链的title  比如你可以更改为 友情链接
links_layout: block       # 友链摆放的样式：按块（一行一个）
#links_layout: inline     # 友链摆放的样式：按线摆放（一行很多个），注意，同时只能一种样式
links:
  Title: http://example.com/  # 友链的地址
```
官方提供的友链放在侧边栏下面，视觉上比较臃肿。这里我新建了一个友链页面：友情链接，设置教程见：Hexo-NexT 新增友链。
### 首页文章不展示全文显示摘要
>官方公告：`auto_excerpt` 可以自动截断文章内容作为摘要。此功能不是一个 Hexo 主题应当负责的，这为主题的维护者带来了太大压力。自 7.6.0 版本开始，此功能被移除，请自行安装第三方插件，或阅读 Hexo 有关文档。当然，我们仍然建议通过 `` 来精确控制 Read More 的位置。

**因此，这个功能在新版的 NexT 已经被废弃了，大家可以直接在文章中添加 <!-- more --> 来精确控制摘要内容**。
### 首页文章属性next.yml
```yaml
post_meta:
  item_text: true    # 设为true 可以一行显示，文章的所有属性
  created_at: true    # 显示创建时间
  updated_at:
    enabled: true     # 显示修改的时间
    another_day: true # 设true时，如果创建时间和修改时间一样则显示一个时间
  categories: true    # 显示分类信息
```
### 页面阅读统计 不蒜子统计
```yaml
busuanzi_count:
  enable: false              # 设true 开启
  total_visitors: true       # 总阅读人数（uv数）
  total_visitors_icon: user  # 阅读总人数的图标
  total_views: true          # 总阅读次数（pv数）
  total_views_icon: eye      # 阅读总次数的图标
  post_views: true           # 开启内容阅读次数
  post_views_icon: eye       # 内容页阅读数的图标
```
### 字数统计、阅读时长
首先安装插件：
`npm install hexo-symbols-count-time --save`
主题配置文件_config.yml（next.yml） 修改如下：

```yaml
symbols_count_time:
  separated_meta: true  # false会显示一行
  item_text_post: true  # 显示属性名称,设为false后只显示图标和统计数字,不显示属性的文字
  item_text_total: true # 底部footer是否显示字数统计属性文字
  awl: 4                # 计算字数的一个设置,没设置过
  wpm: 275              # 一分钟阅读的字数
```
站点配置文件_config.yml 新增如下：
```yaml
symbols_count_time:
 #文章内是否显示
  symbols: true
  time: true
 # 网页底部是否显示
  total_symbols: true
  total_time: true
```
### 内容页里的代码块新增复制按钮
```yaml
codeblock:
  copy_button:
    enable: false      # 增加复制按钮的开关
    show_result: true # 点击复制完后是否显示 复制成功 结果提示
```
### Mac风格代码块样式
hexo\source\_data\next.yml里修改：
```yaml
codeblock:
  # Code Highlight theme
  # See: https://github.com/highlightjs/highlight.js/tree/master/src/styles
  theme:
    light: agate
    dark: dark
  # See: https://github.com/PrismJS/prism/tree/master/themes
  prism:
    light: prism
    dark: prism-dark
  # Add copy button on codeblock
  copy_button:
    enable: true
    # Available values: default | flat | mac
    style: mac
```
### 配置微信，支付宝打赏
```yaml
# Reward
reward_comment:                   # 打赏描述
wechatpay: /images/wechatpay.png  # 微信支付的二维码图片地址
alipay: /images/alipay.png        # 支付宝的地址
#bitcoin: /images/bitcoin.png     # 比特币地址
```
### 相关文章推荐
安装推荐文章的插件：
`npm install hexo-related-popular-posts --save`
主题配置信息（next.yml）如下:
```yaml
related_posts:
  enable: true
  title: 相关文章推荐      # 属性的命名
  display_in_home: false # false代表首页不显示
  params:
    maxCount: 5          # 最多5条
    #PPMixingRate: 0.0   # 相关度
    #isDate: true        # 是否显示日期
    #isImage: false      # 是否显示配图
    isExcerpt: false     # 是否显示摘要
```
### 文章原创申明
```yaml
creative_commons:
  license: by-nc-sa
  sidebar: false
  post: true       # 默认显示版权信息
  language:
```
### 修改文章底部标签的样式
```yaml
# Use icon instead of the symbol # to indicate the tag at the bottom of the post
# 标签代替#
tag_icon: true
```
### 显示当前浏览进度next.yml
```yaml
back2top: 
  enable: false # 默认关闭
  # Back to top in sidebar.
  sidebar: true
  # Scroll percent label in b2t button.
  scrollpercent: true
```
### 修改 back2top 标签

地址：[hexo-cake-moon-menu](https://github.com/jiangtj-lab/hexo-cake-moon-menu)

```
npm install hexo-cake-moon-menu --save
```

If you are using NexT theme version 7.8 or earlier, install version 2.1.2

```
npm i hexo-cake-moon-menu@2.1.2
```

然后在站点配置文件`_config.yml `中添加以下代码：

```yaml
moon_menu:
  back2top:
    enable: true
    icon: fa fa-chevron-up
    func: back2top
    order: -1
  back2bottom:
    enable: true
    icon: fa fa-chevron-down
    func: back2bottom
    order: -2
```
{% note info %}

2021.3.22 注意：如果在hexo升级5.4后，安装有此插件就会报错（当然也有可能是主题和这个插件不兼容，Next升级8.5后不会报错了，大概率是主题问题，只需升级到最新主题，即可避免这个问题），~~则需要卸载此插件。代码如下：~~

```
npm remove hexo-cake-moon-menu --save
```

---

2021.6.19 安装此插件，不报错了，目前版本hexo 5.4+Next 8.5

{% endnote %}

### 菜单栏显示分类 / 标签中的文章数目

scheme选择Gemini
```yaml
menu_settings:
  badges: true # 显示菜单分类的数目
```
## 进阶配置
### 修改文章默认模板

修改`hexo\scaffolds\post.md`

```
title: {{ title }}
date: {{ date }}
categories: []
tags: []
abbrlink: 
top: 
```

### 新增文章时自动打开Markdown编辑器

首先在 `hexo/scripts` 下新建一个 `newpost.js` 文件，如果没有 `scripts` 文件可以手动创建一个。

在这个文件写入如下代码：

```js
var spawn = require('child_process').exec;
hexo.on('new', function(data){
  spawn('start  "markdown编辑器绝对路径.exe" ' + data.path);
});
```

注意里面要修改的是 Markdown 编辑器的绝对路径，我使用的是 Typora ，所以我的绝对路径是 `D:\Program Files\Typora\Typora.exe` ，大家可以对应进行修改。

### Pjax插件

Pjax是基于Ajax的插件，能实现网页局部无刷新载入，听起来很香，然而存在一些小问题：

<div class="note danger">如果使用utterances评论系统，一定要先关闭Pjax插件，否则utterances评论无法登陆</div>

* 使用Mediumzoom时，从归档进入博文不会加载图片，需要刷新网页才能加载
* Echarts图表全部需要刷新才能显示，否则只有一片空白

安装Pjax，地址：[ next-theme /pjax ](https://github.com/next-theme/pjax)，运行以下代码安装：

```
git clone https://github.com/next-theme/pjax source/lib/pjax
```

然后在next.yml中搜索pjax并设置为`pjax: true`

如果部署是报错:

```
ERROR Process failed: lib/pjax/README.md
YAMLException: end of the stream or a document separator is expected at line 9, column 102:
     ... languages` and other directories:
```

解决方法：[安装完pjax插件后，部署时报错](https://github.com/next-theme/pjax/issues/2)

在 Hexo 的 _config.yml 中找到名为 skip_render 的选项，然后设置为这样:

```
skip_render:
  - lib/**/*
```

### 加载进度条

<div class="note primary">注意next8.0.1后改用NProgress进度条插件
</div>

在next.yml中搜索Progress bar in the top during page loading并设置为：

```yaml
nprogress:
  enable: true
  spinner: true
```

<div class="note primary">next8.0.1之前，先安装插件：</div>


```
git clone https://github.com/theme-next/theme-next-pace source/lib/pace
```

然后设置：

```yaml
pace:
  enable: true
```

### 阅读进度条

```yaml
# Reading progress bar
reading_progress:
  enable: true
  # Available values: top | bottom
  position: top
  color: "#37c6c0"
  height: 3px
```

### 背景图片

将背景图片放置在./hexo/themes/next/source/images中并命名为background.jpg
然后在./hexo/source/_data/styles.styl中添加

```js
body {
    background:url(/images/background.jpg);//图片路径
    background-repeat: no-repeat;//是否重复平铺
    background-attachment: fixed;//是否随着网页上下滚动而滚动，fixed为固定
    background-position: 50% 50%;//图片位置
    background-size: cover;//图片展示大小
    -webkit-background-size: cover;
    -o-background-size: cover;
    -moz-background-size: cover;
    -ms-background-size: cover;
    opacity: 0.95;
    footer > div > div {
        color:#000000;//底部文字颜色
    }
}
```
第二种代码：（未测试，目前使用的是上面的代码）

```js
body {
    background:url(/images/yourbackground.jpg);
    background-repeat: no-repeat;
    background-attachment:fixed; //不重复
    background-size: cover;      //填充
    background-position:50% 50%;
}
//博客内容透明化
//文章内容的透明度设置
.content-wrap {
  opacity: 0.95;
}

//侧边框的透明度设置
.sidebar {
  opacity: 0.9;
}

//菜单栏的透明度设置
.header-inner {
  background: rgba(255,255,255,0.9);
}

//搜索框（local-search）的透明度设置
.popup {
  opacity: 0.9;
}
```

### 首页文章阴影边框

找到三种方法，在next7.7.2中都不起效。
#### scheme选择Gemini
```yaml
# Schemes
#scheme: Muse
#scheme: Mist
#scheme: Pisces
scheme: Gemini
```
#### 在`styles.styl`里添加代码
方法一只有首页第一篇文章有阴影效果，其他两种方法都没有效果。（不折腾了）
```js
.content-wrap {
    background: initial;
}
.post-block {
  box-shadow: 0 2px 6px 0 rgb(0,0,0,0.6), 0 0 6px 0 rgb(0,0,0,0.6)
  background: #FFF
}
```
```js
// 主页文章添加阴影效果
 .post_block {
   opacity: 0;
   margin-top: 60px;
   margin-bottom: 60px;
   padding: 25px;
   -webkit-box-shadow: 0 0 5px rgba(202, 203, 203, .5);
   -moz-box-shadow: 0 0 5px rgba(202, 203, 204, .5);
  }
```
```js
// 主页文章添加阴影效果
.post {
   margin-top: 0px;
   margin-bottom: 60px;
   padding: 25px;
   -webkit-box-shadow: 0 0 5px rgba(202, 203, 203, .5);
   -moz-box-shadow: 0 0 5px rgba(202, 203, 204, .5);
}
```
### 自定义单行代码颜色 
在./hexo/source/_data/styles.styl中添加
```js
// 单行代码颜色
code {
    color: #ff511A;
    background: #fbf7f8;
    margin: 2px;
}
```
### 代码块高亮`diff`写法

Next主题其实是自带代码块高亮显示的，但是有另外一种好玩的代码块高亮写法，叫 `diff` 语言。只需要在 markdown 语法代码块的语言选择处写上 `diff` 即可，然后在相应代码前面加上 `-` 和 `+ `就行了。（**注意`+ -`前面不要加空格**）

![](https://cdn.jsdelivr.net/gh/iwyang/pic/20200721161157.jpg)

### 菜单中文翻译

我们原来是通过配置主题下的 languages 目录中的 zh-CN.yml 文件来对菜单等进行中文翻译的，现在我们可以通过在 hexo/source/_data/ 下新建数据文件 languages.yml，配置如下：
```yaml
zh-CN: 
  menu:
    home: 首页
    top: 热榜
    archives: 归档
    categories: 分类
    tags: 标签
    about: 关于
    links: 友情链接
    search: 搜索
    schedule: 日程表
    sitemap: 站点地图
    commonweal: 公益 404
    movies: 观影
    books: 阅读
    gallery: 画廊

  reward:
    donate: <i class="fa fa-qrcode fa-2x" style="line-height:35px;"></i>
    wechatpay: 微信支付
    alipay: 支付宝
    bitcoin: 比特币
```
### 文章末尾添加本文结束分割线
新建 source/_data/post-body-end.swig 文件，添加内容：
```html
<div>
    {% if not is_index %}
        <div style="text-align:center;color: #ccc;font-size:14px;">-------------本文结束<i class="fa fa-paw"></i>感谢您的阅读-------------</div>
    {% endif %}
</div>
```
在next.yml中，去掉注释
`postBodyEnd: source/_data/post-body-end.swig`

### 圆角设置、中文字体设置
#### 圆角设置
在自定义样式文件 `hexo\source\_data\variables.styl` 中添加：
```js
// 圆角设置
$border-radius-inner     = 20px 20px 20px 20px;
$border-radius           = 20px;
```
然后在 NexT 的配置文件 next.yml 中取消 variables.styl 的注释：
`variable: source/_data/variables.styl`
在这里会有一个bug，左下角始终会有个白块。解决方法:你只需要在 `source\_data\styles.styl` 文件中添加一行代码即可：

```js
// 修复圆角
:root{--body-bg-color: hsla(0,0%,100%,0)}
```

或者添加下列代码：

```js
// 修复圆角
.sidebar {
box-shadow: none
background: none
}
```
#### 中文字体设置
首先修改主题配置文件 next.yml：
```diff
font:
- enable: false
+ enable: true

  # Uri of fonts host. E.g. //fonts.googleapis.com (Default).
- host:
+ host: https://fonts.loli.net

  # Font options:
  # `external: true` will load this font family from `host` above.
  # `family: Times New Roman`. Without any quotes.
  # `size: xx`. Use `px` as unit.

  # Global font settings used for all elements in <body>.
  global:
    external: true
-   family:
+   family: Noto Serif SC
    size:
```
修改配置文件 \hexo\source\_data\variables.styl，增加如下代码：
```yaml
// 中文字体
$font-family-monospace    = consolas, Menlo, monospace, $font-family-base;
$font-family-monospace    = get_font_family('codes'), consolas, Menlo, monospace, $font-family-base if get_font_family('codes');
```
### 鼠标点击特效、打字特效、友链等
#### 打字特效、鼠标点击特效
之前版本：[Hexo-NexT 添加打字特效、鼠标点击特效](https://tding.top/archives/58cff12b.html)中，以下代码是放在 `hexo/next/_layout/_custom/custom.swig` 文件中的，现在这部分代码需要放到 `hexo/source/_data/body-end.swig` 文件中：
```js
{# 鼠标点击特效 #}
{% if theme.cursor_effect == "fireworks" %}
  <script async src="/js/cursor/fireworks.js"></script>
{% elseif theme.cursor_effect == "explosion" %}
  <canvas class="fireworks" style="position: fixed;left: 0;top: 0;z-index: 1; pointer-events: none;" ></canvas>
  <script src="//cdn.bootcss.com/animejs/2.2.0/anime.min.js"></script>
  <script async src="/js/cursor/explosion.min.js"></script>
{% elseif theme.cursor_effect == "love" %}
  <script async src="/js/cursor/love.min.js"></script>
{% elseif theme.cursor_effect == "text" %}
  <script async src="/js/cursor/text.js"></script>
{% endif %}

{# 打字特效 #}
{% if theme.typing_effect %}
  <script src="/js/activate-power-mode.min.js"></script>
  <script>
    POWERMODE.colorful = {{ theme.typing_effect.colorful }};
    POWERMODE.shake = {{ theme.typing_effect.shake }};
    document.body.addEventListener('input', POWERMODE);
  </script>
{% endif %}
```
然后在 NexT 的配置文件 `next.yml` 中取消 `body-end.swig` 的注释：
`bodyEnd: source/_data/body-end.swig`
然后我们在 `next.yml` 中增加如下配置项：
```yaml
# 鼠标点击特效
# mouse click effect: fireworks | explosion | love | text
cursor_effect: fireworks

# 打字特效
# typing effect
typing_effect:
  colorful: true  # 礼花特效
  shake: false    # 震动特效
```
注意：上面所有特效的 JS 代码文件都放在站点的 source 目录下（即 `hexo/source/js/`）而不是主题目录下，如果没有 js 目录，则新建一个。
#### 友链添加
详见：[Hexo-NexT 新增友链](https://tding.top/archives/73ce4e7.html)
从第一种友链方式改用第二种友链方式，因为第二种瀑布流友链样式是不用修改 NexT 主题源文件的。
#### 代码块折叠
参考：[代码块折叠](https://tding.top/archives/2bd6d82.html#%E4%BB%A3%E7%A0%81%E5%9D%97%E6%8A%98%E5%8F%A0)
### 近期文章、粒子时钟特效
#### 近期文章
现在我们把上面的代码放到 hexo/source/_data/sidebar.swig 文件中，并且做以下更改：
```js
{% if theme.recent_posts %}
    <div class="links-of-blogroll motion-element {{ "links-of-blogroll-" + theme.recent_posts_layout  }}">
      <div class="links-of-blogroll-title">
        <!-- modify icon to fire by szw -->
        <i class="fa fa-history fa-{{ theme.recent_posts_icon | lower }}" aria-hidden="true"></i>
        {{ theme.recent_posts_title }}
      </div>
      <ul class="links-of-blogroll-list">
-        {% set posts = site.posts.sort('-date') %}
+        {% set posts = site.posts.sort('-date').toArray() %}
        {% for post in posts.slice('0', '5') %}
          <li>
            <a href="{{ url_for(post.path) }}" title="{{ post.title }}" target="_blank">{{ post.title }}</a>
          </li>
        {% endfor %}
      </ul>
    </div>
{% endif %}
```
这是因为 NexT 已经更换 Nunjucks 作为模板引擎。

然后在 NexT 的配置文件 next.yml 中取消 sidebar.swig 的注释：
`sidebar: source/_data/sidebar.swig`
最后，为了配置方便，在主题的`next.yml` 中添加了几个变量，如下：
```yaml
recent_posts_title: 近期文章
recent_posts_layout: block
recent_posts: true
```
#### 粒子时钟特效
现在我们只需要把粒子时钟的 js 代码直接放入到 `hexo/source/_data/sidebar.swig` 文件即可。
详情见：[Hexo-NexT 增加 canvas 粒子时钟](http://bore.vip/archives/2764ed9c.html)
### 置顶文章标志
首先我们需要安装 hexo-generator-index-pin-top 这个插件，
```
npm uninstall hexo-generator-index --save
npm install hexo-generator-index-pin-top --save
```
{% note primary %}

2021.6.19：如果卸载`hexo-generator-index`，没有安装`hexo-generator-index-pin-top`，本地预览会提示`Cannot GET/`，原因在于缺少了`hexo-generator-index`组件。

{% endnote %}

然后将以下代码放入 hexo/source/_data/post-meta.swig 文件

```
{% if post.top %}
    <span class="post-meta-divider">|</span>
    <i class="fa fa-thumb-tack"></i>
    <font color=7D26CD>置顶</font>
    <span class="post-meta-divider">|</span>
{% endif %}
```
然后在 NexT 的配置文件 next.yml 中取消 post-meta.swig 的注释：
`post-meta: source/_data/post-meta.swig`
使用方法：在需要置顶的文章的 Front-matter 中加上 top: true 或者 top: 任意数字，比如：
```
---
title: TMDb电影数据分析
declare: true
toc: true
tags:
  - Python
  - 数据分析
categories:
  - 数据分析
  - 实战
abbrlink: 7e380af2
date: 2018-11-23 13:20:03
top: 100
---
```
注意：top 中数字越大，文章越靠前。
### 静态资源压缩插件
安装插件：
`npm install hexo-neat --save`
然后我们需要在**站点配置文件**中添加以下代码：
```yaml
# 博文压缩
neat_enable: true
# 压缩html
neat_html:
  enable: true
  exclude:
# 压缩css  
neat_css:
  enable: true
  exclude:
    - '**/*.min.css'
# 压缩js
neat_js:
  enable: false
  mangle: true
  output:
  compress:
  exclude:
    - '**/*.min.js'
    - '**/jquery.fancybox.pack.js'
    - '**/index.js'
    - '**/fireworks.js'
```
### 首页改归档页

把 `layout/archive.swig` 改为 `layout/index.swig` 就行了。不过注意此时首页的 `meta` 信息是 `archive` （归档）……要做个清爽合格的首页，可以把原 `index.swig` 的 `meta` 信息拷贝到新 `index.swig` 下。

```diff
// new index.swig (archive.swig)

- {% block title %}{{ __('title.archive') }} | {{ title }}{% endblock %}

+ {% block title %}{{ title }}{%- if theme.index_with_subtitle and subtitle %} - {{ subtitle }}{%- endif %}{% endblock %}
```

### 修改首页、归档页显示文章数量

站点配置文件`_config.yml`里修改：

```yaml
index_generator:
  path: ''
  per_page: 10
  order_by: -date
```

```yaml
# Pagination
## Set per_page to 0 to disable pagination
per_page: 10
pagination_dir: page
```

### 关闭文章目录自动数字编号

关闭文章目录自动数字编号后，可以自定义目录数字编号。

在hexo\source_data\next.yml里修改：

```yaml
toc:
  enable: true
  # Automatically add list number to toc.
  number: false
  # If true, all words will placed on next lines if header width longer then sidebar width.
  wrap: false
  # If true, all level of TOC in a post will be displayed, rather than the activated part of it.
  expand_all: false
  # Maximum heading depth of generated toc.
  max_depth: 6
```

### 自动部署脚本

在根目录新建`deploy.sh`，输入以下内容：

```js
#!/bin/bash
echo -e "\033[0;32mDeploying updates to gitee...\033[0m"
git add .	
git commit -m "site backup"
git push --force origin master
hexo clean
hexo g -d
```

有时候可能需要多次运行脚本才能提交成功，这时不妨手动输入命令。

### `styles.styl`自定义样式

自用自定义样式如下：

```yaml
// 背景图片
body {
    background:url(https://cdn.jsdelivr.net/gh/iwyang/pic/background.jpg);
    background-repeat: no-repeat;//是否重复平铺
    background-attachment: fixed;//是否随着网页上下滚动而滚动，fixed为固定
    background-position: 50% 50%;//图片位置
    background-size: cover;//图片展示大小
    -webkit-background-size: cover;
    -o-background-size: cover;
    -moz-background-size: cover;
    -ms-background-size: cover;
    opacity: 0.95;
    footer > div > div {
        color:#000000;//底部文字颜色
    }
}

// 单行代码颜色
code {
    color: #ff511A;
    background: #fbf7f8;
    margin: 2px;
}

// 修复圆角
:root{--body-bg-color: hsla(0,0%,100%,0)}

// 修改选中字符的颜色
/* webkit, opera, IE9 */
::selection {
    background: #00c4b6;
    color: #f7f7f7;
}
/* firefox */
::-moz-selection {
    background: #00c4b6;
    color: #f7f7f7;
}

// 删除线
del {
  color: #b35888;
  background: #fbf7f8;
  margin: 2px;
}

// 文章内链接文本样式 
.post-body p a{ 
    color: #0593d3; 
    border-bottom: none; 
    border-bottom: 1px solid #0593d3; 
    &:hover { 
        color: #fc6423; 
        border-bottom: none; 
        border-bottom: 1px solid #fc6423; 
    } 
}
```

### 二级菜单目录

NexT 主题支持多级目录，但是官网并没有直接给出配置的方法，因此很少见到有人使用，具体的样式可以参考官方网站的 Docs 页面，其上方的样式即为二级目录和三级目录。

![](../img/Hexo-NexT%20(v7.7.2)%20%E4%B8%BB%E9%A2%98%E9%85%8D%E7%BD%AE/20200821211714.png)

就以官方网站的 Docs 页面为例，其配置文件的目录设定内容为：

```yaml
menu:
    News: / || bullhorn

    Docs:
      default: /docs/ || book

      Getting Started:
        default: /getting-started/ || flag
        Installation: /installation.html || download
        Deployment: /deployment.html || upload
        Data Files: /data-files.html || wrench
        Update from 5.x: /update-from-v5.html || retweet

      Theme Settings:
        default: /theme-settings/ || star
        Footer: /footer.html || sun-o
        Sidebar: /sidebar.html || bars
        Posts: /posts.html || pencil-square-o
        Custom Pages: /custom-pages.html || file-o
        SEO: /seo.html || external-link-square
        Front Matter: /front-matter.html || header

      Third Party Services:
        default: /third-party-services/ || plug
        Math Equations: /math-equations.html || superscript
        Comment Systems: /comments.html || comments-o
        Statistics and Analytics: /statistics-and-analytics.html || bar-chart
        Post Widgets: /post-widgets.html || share-square
        Search Services: /search-services.html || search-plus
        Chat Services: /chat-services.html || comment
        External Libraries: /external-libraries.html || puzzle-piece

      Tag Plugins:
        default: /tag-plugins/ || rocket
        Note: /note.html || comment
        Tabs: /tabs.html || columns
        PDF: /pdf.html || file-pdf-o
        Mermaid: /mermaid.html || tasks
        Label: /label.html || font
        Video: /video.html || video-camera
        Button: /button.html || square
        Caniuse: /caniuse.html || signal
        Group Pictures: /group-pictures.html || file-image-o

      Advanced Settings: /advanced-settings.html || cogs
      FAQ's: /faqs.html || life-ring
      Troubleshooting: /troubleshooting.html || bug
    archives: /archives/ || archive

```

也就是说，在一级目录 `Docs` 下，我们想要创建 `Getting Started`、`Theme Settings` 等二级目录页面，那么需要作出如下修改：

```diff
menu:
-   Docs: /docs/ || book
+   Docs:
+         default: /docs/ || book
```

即将当前目录默认页面的名称改为 `default`。然后再在 `default` 同级下添加：

```diff
Docs:
      default: /docs/ || book
+     Getting Started: /getting-started/ || flag
+     Theme Settings: /theme-settings/ || star
```

我们需要在 `~/source/docs/` 文件夹下创建对应的文件夹 `Getting Started` 和 `Theme Settings`，文件夹中创建对应的 `index.md` 文件，该文件即为其二级目录对应页面内容的存放文件。

同样，创建三级目录的时候，需要将对应的二级目录默认页面改为 `default`，然后在同级下添加同样格式的内容，在此不再赘述。如果你还没有明白是怎么设定的，可以研究一下 NexT 官方网站的源码仓库文件的存放位置。

---

例子：将`友情链接`放在`关于`页面顶部导航栏。

先将`links文件夹`放在`about文件夹`里，然后设置目录菜单。

```yaml
  about:
        default: /about/ || fa fa-user
        links: /links/ || fa fa-link
```

### 开启`gitter`

<div class="note primary">首先前往 {% btn https://gitter.im, gitter官网, link fa-lg fa-fw %} 建立社区房间，然后在`_config.next.yml`配置如下:</div>


```diff
gitter:
- enable:
+ enable: true
- room:
+ room: iwyang/community
```

**最终效果：**

![](https://cdn.jsdelivr.net/gh/iwyang/pic/20210710120529.jpg)

<div class="note primary">由于觉得开启gitter会影响页面美观，所以我没有开启gitter。</div>

## V8.0 更新内容

### 重要更新

- 图标库升级为 Font-Awesome 5 ([theme-next/hexo-theme-next#1438](https://github.com/theme-next/hexo-theme-next/pull/1438))
- 模板格式从 `swig` 更改为 `njk`
- 菜单设置变更 ([a527bfd](https://github.com/next-theme/hexo-theme-next/commit/a527bfdf11d558ffd958cd0a0b05416fb1caaa33))

```diff
-override: false

menu:
-  home: / || fa fa-home
+  #home: / || fa fa-home
  #about: /about/ || fa fa-user
  #tags: /tags/ || fa fa-tags
  #categories: /categories/ || fa fa-th
-  archives: /archives/ || fa fa-archive
+  #archives: /archives/ || fa fa-archive
  #schedule: /schedule/ || fa fa-calendar
  #sitemap: /sitemap.xml || fa fa-sitemap
  #commonweal: /404/ || fa fa-heartbeat
```

Valine 选项更新 ([6e6fc74](https://github.com/next-theme/hexo-theme-next/commit/6e6fc74ae98a0ef7aa3aeaba3e330ef735698b7b))

```diff
valine:
-  appid: # Your leancloud application appid
-  appkey: # Your leancloud application appkey
+  appId: # Your leancloud application appid
+  appKey: # Your leancloud application appkey
  ...
-  guest_info: nick,mail,link # Custom comment header
+  meta: # Custom comment header
+    - nick
+    - mail
+    - link
```

- 支持 highlight.js ([9fdaba2](https://github.com/next-theme/hexo-theme-next/commit/9fdaba295a2c6c707a7d96d331762ab571b89c1a))
- 允许更多的代码高亮格式 ([03e50d0](https://github.com/next-theme/hexo-theme-next/commit/03e50d01ac59d136d8d9ccda187d898c0e424332))

```diff
codeblock:
  ...
-  # Available values: normal | night | night eighties | night blue | night bright | solarized | solarized dark | galactic
-  # See: https://github.com/chriskempson/tomorrow-theme
-  highlight_theme: normal
+  # See: https://github.com/highlightjs/highlight.js/tree/master/src/styles
+  theme:
+    light: default
+    dark: dark
```

### 配置

#### 代码高亮

```yaml
codeblock:
  theme:
    light: agate
    dark: dark
  # Add copy button on codeblock
  copy_button:
    enable: true
    # Show text copy result.
    show_result: true
    # Available values: default | flat | mac
    style: mac
```

你可以在这里预览代码高亮的效果：[highlightjs](https://highlightjs.org/) 选择你喜欢的 `style` 即可。

#### 更换模板

```yaml
custom_file_path:
  #head: source/_data/head.njk
  #header: source/_data/header.njk
  #sidebar: source/_data/sidebar.njk
  postMeta: source/_data/post-meta.njk
  postBodyEnd: source/_data/post-body-end.njk
  footer: source/_data/footer.njk
  bodyEnd: source/_data/body-end.njk
  variable: source/_data/variables.styl
  #mixin: source/_data/mixins.styl
  style: source/_data/styles.styl
```

同时将原 `_data` 目录下的 `swig` 文件后缀改为 `njk` 即可

## 参考链接

+ [1.Hexo-NexT (v7.0+) 主题配置](https://tding.top/archives/42c38b10.html)
+ [2.Next升级+Mac迁移](https://siriusq.top/Next%E5%8D%87%E7%BA%A7-Mac%E8%BF%81%E7%A7%BB.html)
+ [3.Hexo 框架 (三)：Next 主题配置及美化](https://blog.juanertu.com/archives/264a3045.html)
+ [4.Hexo博客+Next主题深度优化与定制](https://hasaik.com/posts/ab21860c.html)
+ [5.Hexo-NexT 主题个性优化](https://guanqr.com/tech/website/hexo-theme-next-customization/#)
+ [6.第三方评论系统之我见—云游君](https://www.yunyoujun.cn/share/third-party-comment-system/)
+ [7.尝试折腾了下用 Hexo-Next-Theme 搭建的博客](https://leay.net/2020/03/23/hexo-next/)













