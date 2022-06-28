---
title: hexo版本升级
categories:
  - 技术
tags:
  - hexo
abbrlink: d6da8e6c
date: 2020-07-12 11:05:00
cover: false
---

## 准备工作

### 备份源文件

<div class="note danger">版本升级以前一定要先备份源文件，防止后面一些插件升级出现bug</div>

### npm速度太慢

如果`npm install`速度过慢，可安装cnpm淘宝镜像替代：

```
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

安装好了就可以使用cnpm来替代npm进行依赖的下载了:

```
cnpm install
```

## 版本升级

 先查看hexo版本：

```
hexo version
```

升级命令如下：

```
npm i hexo-cli -g
npm update
hexo version
```

---

<div class="note primary">注意：如果升级后报错，大概率是因为安装的某个插件的问题（如hexo升级5.4后，hexo-cake-moon-menu插件导致报错，就需卸载此插件，当然也有可能是主题和这个插件不兼容），这时就需要排查是哪个插件的问题，最直接的方法就是重新初始化hexo，所以说升级前备份源文件是及其重要的。</div>

## 插件升级

上面升级命令不够正确（插件没有升级，不过插件升级可能会导致bug，要事先备份好源文件），继续往下操作：

### 检查插件是否有升级

```
npm install -g npm-check
npm-check
```

### 升级系统中的插件

```
npm install -g npm-upgrade
npm-upgrade
```

### 更新全局包

```
npm update -g
```

### 更新生产环境依赖包

```
npm update --save
```

### 再次查看版本号

```
hexo version
```

## 出现的问题

升级插件后报错：

```
hexo TypeError [ERR_INVALID_URL]: Invalid URL
```

主要是因为某些插件升级后有bug，需要退版本，解决方法如下：

+ 删除`node_modules`文件夹

+ 把稳定版本的`package.json`和`package-lock.json`复制到当前文件夹并覆盖

+ `npm install`

## hexo 5.0升级

### 升级方法

2020.7.29 To upgrade to Hexo v5, change the following line in your package.json,

```diff
package.json

-  "hexo": "^4.2.1",
+  "hexo": "^5.0.0",
```

然后

```yaml
npm i hexo-cli -g
npm update
hexo version
```

### 存在的问题

升级hexo 5.0后，`hexo s`后，提示：

```
INFO  Validating config
WARN  Deprecated config detected: "use_date_for_updated" is deprecated, please use "updated_option" instead. See https://hexo.io/docs/configuration for more details.
```

### 解决方法

站点配置文件`_config.yml`

```diff
- use_date_for_updated: false
+ updated_option: mtime
```

---

{% note primary %}

```yaml
Hexo 4.0.0 提供的 use_date_for_updated 配置项现已被 updated_option 替代。

    use_date_for_updated: true 现在等价于 updated_option: 'date'。
    use_date_for_updated: false 现在等价于 updated_option: 'mtime'。
    //如果从hexo 4.0升级到5.0，这里应当是updated_option: mtime（不要引号）
```

{% endnote %}

## hexo 6.2升级

出现问题：[Asset render failed: %s css/style.css #4970](https://github.com/hexojs/hexo/issues/4970#issuecomment-1126868358)

解决方法：

node16 npm8
修改 package.json：

https://github.com/volantis-x/demo/blob/5063cebe42975af229aea88fbcc0e25fa1cc3048/package.json#L14-L19

```diff
{
  "name": "hexo-site",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "build": "hexo generate",
    "clean": "hexo clean",
    "deploy": "hexo deploy",
    "server": "hexo server"
  },
  "hexo": {
    "version": "6.2.0"
  },
+  "overrides": {
+   "nib": {
+      "stylus": "0.54.8"
+   },
+   "glob": "7.2.0"
+  },
  "dependencies": {
    "hexo": "^6.0.0",
    "hexo-abbrlink": "^2.2.1",
    "hexo-deployer-git": "^3.0.0",
    "hexo-filter-nofollow": "^2.0.2",
    "hexo-generator-archive": "^1.0.0",
    "hexo-generator-category": "^1.0.0",
    "hexo-generator-index": "^2.0.0",
    "hexo-generator-searchdb": "^1.4.0",
    "hexo-generator-sitemap": "^2.2.0",
    "hexo-generator-tag": "^1.0.0",
    "hexo-renderer-ejs": "^2.0.0",
    "hexo-renderer-marked": "^5.0.0",
    "hexo-renderer-pug": "^2.0.0",
    "hexo-renderer-stylus": "^2.0.1",
    "hexo-server": "^3.0.0",
    "hexo-theme-butterfly": "^4.1.0",
    "hexo-theme-landscape": "^0.0.3",
    "hexo-wordcount": "^6.0.1"
  }
}
```

删除 package-lock.json node_modules
然后 执行安装命令:

```
npm i
```

（安装glob只是执行了npm i，并没有什么用，如果安装了建议马上卸载 npm un glob）

[#4968](https://github.com/hexojs/hexo/issues/4968)

[isaacs/node-glob#471](https://github.com/isaacs/node-glob/issues/471)

## 参考链接

+ [1.hexo版本升级](https://ifumei.cc/2019/10/26/hexo%E5%92%8Cthemes-Next%E7%89%88%E6%9C%AC%E5%8D%87%E7%BA%A7/)
+ [2.Hexo版本升级和Next主题升级之坑](https://blog.csdn.net/u014253173/article/details/81088518)
+ [3.hexo TypeError  ERR_INVALID_URL: Invalid URL](https://blog.csdn.net/he_han_san/article/details/103900365)
+ [4.npm太慢，安装cnpm淘宝镜像替代](https://www.jianshu.com/p/ad58bbcede05)
+ [5."use_date_for_updated" is deprecated](https://github.com/hexojs/hexo/issues/4450)
+ [6.Hexo 5.0.0 正式发布](https://blog.skk.moe/post/hexo-5/)
+ [7.Asset render failed: %s css/style.css #4970](https://github.com/hexojs/hexo/issues/4970#issuecomment-1126868358)

