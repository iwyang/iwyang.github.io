---
title: hexo已使用插件备忘
categories:
  - 技术
tags:
  - hexo
abbrlink: 6b1d45d4
date: 2020-04-26 21:24:16
cover: false
---

## Hexo 一键部署插件

### 地址 

- [hexo-deployer-git](https://github.com/hexojs/hexo-deployer-git)

### 安装配置

安装插件：

```javascript
npm install hexo-deployer-git --save
```

然后修改站点配置文件_config.yml 中的配置：

```
deploy:
 type: git
 repo: git@blog.yizhilee.com:hexo.git
```

## Hexo 本地搜索功能

### 地址

+ [hexo-generator-searchdb](https://github.com/theme-next/hexo-generator-searchdb)

### 安装配置

```
npm install hexo-generator-search --save
```

然后我们修改站点配置`_config.yml` 文件，添加如下内容：

```yaml
search:
  path: search.xml
  field: all
  content: true
```

- path：索引文件的路径，相对于站点根目录
- field：搜索范围，默认是 post，还可以选择 page、all，设置成 all 表示搜索所有页面
- limit：限制搜索的条目数

然后修改主题配置文件`next.yml`：

```diff
local_search:
-  enable: false
+  enable: true
```

## Hexo 站点地图 sitemap 生成

### 地址

+ [hexo-generator-sitemap](https://github.com/hexojs/hexo-generator-sitemap)

### 安装配置

```
npm install hexo-generator-sitemap --save
```

然后我们需要在 Hexo 站点配置文件`_config.yml` 中加入 sitemap 插件：

```yaml
# 通用站点地图
sitemap:
  path: sitemap.xml
  rel: false
  tags: true
  categories: true
```

## hexo-abbrlink

可以把链接permalink转为数字的插件，配置容易，生成时自动转为数字。

地址：[hexo-abbrlink](https://github.com/rozbo/hexo-abbrlink)

安装：`npm install hexo-abbrlink --save`

配置 `config.yml`:

```yaml
url: https://bore.vip
permalink: archives/:abbrlink/

# abbrlink config
abbrlink:
  alg: crc32 #support crc16(default) and crc32
  rep: hex #support dec(default) and hex
  drafts: false #(true)Process draft,(false)Do not process draft. false(default)
  # Generate categories from directory-tree
  # depth: the max_depth of directory-tree you want to generate, should > 0
  auto_category:
    enable: false #true(default)
    depth: #3(default)
    over_write: false
  auto_title: false #enable auto title, it can auto fill the title by path
  auto_date: false #enable auto date, it can auto fill the date by time today
  force: false #enable force mode,in this mode, the plugin will ignore the cache, and calc the abbrlink for every post even it already had abbrlink.
     #进制： dec(default) and hex
```

## hexo-filter-nofollow

安装：`npm i hexo-filter-nofollow --save`

然后我们在站点的配置文件`_config.yml` 中添加配置，

```yaml
nofollow:
  enable: true
  field: site
  exclude:
```

## 文章置顶

地址：[hexo-generator-index](https://github.com/hexojs/hexo-generator-index)

安装：`npm install hexo-generator-index --save`

配置：然后我们修改站点配置`_config.yml` 文件

```diff
index_generator:
  path: ''
  per_page: 10
  order_by: -date
+ pagination_dir: page
```

使用：你可以直接在文章的front-matter区域里添加`sticky: 1`属性来把这篇文章置顶。数值越大，置顶的优先级越大。

## RSS订阅插件

地址：[hexo-generator-feed](https://github.com/hexojs/hexo-generator-feed)

安装：`npm install hexo-generator-feed --save`

配置：然后我们修改站点配置`_config.yml` 文件

```yaml
feed:
  enable: true
  type: rss2
  path: rss2.xml
  limit: 20
  hub:
  content:
  content_limit: 140
  content_limit_delim: ' '
  order_by: -date
  icon: icon.png
  autodiscovery: true
  template:
```

> 使用atom.xml会出现乱码，更多选项查看插件说明。

## 参考链接

[本博客当前使用的插件总结](https://tding.top/archives/567debe0.html)



