---
title: GitHub+jsDelivr+PicGo+typecho打造免费高速图床
categories:
  - 技术
tags:
  - 图床
abbrlink: 407b2bc4
date: 2020-07-21 08:32:2
---

>2022.5.17 因为`jsdelivr`不再稳定，此法已失效。现在还是利用`typecho`将插入到文章的图片自动复制到`/source/img/`文件夹下，方法如下:
>
>1.在`typora`菜单栏点击 `格式->图像->设置图片根目录`，将`hexo/source`作为其根目录即可。
>
>2.首先在 hexo > source目录下建一个文件夹叫img，用来保存博客中的图片。然后打开Typora的 文件 > 偏好设置，进行如下设置。
>
>![](../img/GitHub+jsDelivr+PicGo+typecho%E6%89%93%E9%80%A0%E5%85%8D%E8%B4%B9%E9%AB%98%E9%80%9F%E5%9B%BE%E5%BA%8A/QQ%E6%88%AA%E5%9B%BE20220517225839.jpg)
>
>```
>复制到制定路径
>../img/${filename}
>勾选所有选项：
>对本地位置的图片应用上述规则
>对网络位置的图片应用上述规则
>优先使用相对路径
>允许根据YAML设置自动上传图片
>插入时自动转义图片URL
>```
>
>这样的话所有插入到md的图片都将会保存到 `/source/img/该博客md文件名/图片名称`。
>
>PS： [Butterfly](https://github.com/jerryc127/hexo-theme-butterfly)主题相册：
>
>```
>{% gallery %}
>
>![](../../img/2022春季趣味运动会/1.jpg)
>
>![](../../img/2022春季趣味运动会/2.jpg)
>
>![](../../img/2022春季趣味运动会/3.jpg)
>
>![](../../img/2022春季趣味运动会/4.jpg)
>
>![](../../img/2022春季趣味运动会/5.jpg)
>
>![](../../img/2022春季趣味运动会/6.jpg)
>
>{% endgallery %}
>```
>
>```
><style>
>.page-title {
>    display: none;
>  }
></style>
>## 骑行
>
><div class="gallery-group-main">
>{% galleryGroup '荆州行' '第一个100Km（2019.5）' '/gallery/jing-zhou-ride' ../img/荆州行/2.jpg %}
></div>
>
>
>## 太和小学2019级
>
><div class="gallery-group-main">
>{% galleryGroup '2022春季趣味运动会' '那些精彩的瞬间' '/gallery/sport2022spring' ../img/2022春季趣味运动会/1.jpg %}
>{% galleryGroup '2021秋季趣味运动会' '那些精彩的瞬间' '/gallery/sport2021autumn' ../img/2021秋季趣味运动会/1.jpg %}
>{% galleryGroup '2021春季趣味运动会' '那些精彩的瞬间' '/gallery/sport2021spring' ../img/2021春季趣味运动会/3.jpg %}
>{% galleryGroup '2019秋季趣味运动会' '那些精彩的瞬间' '/gallery/sport2019autumn' ../img/2019秋季趣味运动会/1.jpg %}
></div>
>
>
>## 湖大教技2010级
>
><div class="gallery-group-main">
>{% galleryGroup '那些花儿' '那些人，那些事' '/gallery/hubei-university' ../img/那些花儿/3.jpg %}
>{% galleryGroup '2012年木兰天池春游' '大学里的一次春游' '/gallery/mulan-great-lake' ../img/2012年木兰天池春游/4.jpg %}
></div>
>```
>
>手动将图片文件夹放到上述文件夹下，然后在源码模式，一个个输入图片相对路径。

## 配置github

### 新建公共仓库  

新建一个公共仓库，例如我建的仓库地址：`https://github.com/iwyang/pic`，注意一定要勾选**使用Readme文件初始化这个仓库**，否则后面会无法上传图片。

### 获取私人令牌

[前往设置](https://github.com/settings/tokens)，作用：授权仓库的操作权限，通过API实现自动化。然后填写 `Token` 描述，勾选 repo、write、read然后点击 `Generate token` 生成一个 `Token`。因为 Token 只会显示一次，所以先保存笔记本等。

## 安装&配置PicGo

### 安装PicGo

访问[PicGo Releases](https://github.com/Molunerfinn/PicGo/releases)直接下载你的操作系统对应的安装包并完成安装。

> 注：在安装的时候安装目录千万不能选C:\Program Files\下的任何地方，因为PicGo无法解析这一路径，如果你不知道安装在哪里的话，选择仅为我安装，否则在设置Typora时会出现错误。

### 配置PicGo

在PicGo设置里作如下修改：

```bash

设置日志文件：日志记录等级选择"错误-Error"和"提醒-Warn"
时间戳重命名：开
开启上传提示：开
上传后自动复制URL：开
选择显示的图床：只勾选Github图床
```

### 配置`GitHub`插件

安装好后开始配置`GitHub`图床

1. 设定仓库名：按照 用户名/仓库名 的格式填写（iwyang/pic）
2. 设定分支名：master
3. 设定 Token：粘贴之前叫你保存的Token。（在网盘里搜索`图床`会找到Token）
4. 设定自定义域名：它的的作用是，在图片上传后，PicGo 会按照自定义域名+上传的图片名的方式生成访问链接，放到粘贴板上。 `https://cdn.jsdelivr.net/gh/用户名/仓库名`（`https://cdn.jsdelivr.net/gh/iwyang/pic`）

![](../img/GitHub+jsDelivr+PicGo+typecho%E6%89%93%E9%80%A0%E5%85%8D%E8%B4%B9%E9%AB%98%E9%80%9F%E5%9B%BE%E5%BA%8A/8.jpg)

5. 点击`设为默认图床`

### 上传和管理图片

- 单击上传区，选择链接格式，使用点击上传或剪贴板图片上传，PicGo会自动上传图片并将符合链接格式的链接复制到剪贴板，你只要按下Ctrl+v即可粘贴图片的链接。
- 单击相册，你可以看到你上传的所有图片，你可以对所有图片进行复制链接，修改图片URL与删除操作，并可以批量复制或批量删除。

## 配置Typora

- 点击Typora左上角的文件->偏好设置
- 在弹出的界面中点击图像，选择插入图片时选项为`上传图片`，并勾选`对本地位置的图片应用上述规则`和`对网络位置的图片应用上述规则`。
- `上传服务`选项里选择`PicGo(app)`，`PicGo路径`选择`PicGo.exe`的绝对路径。

以后在Typora里插入本地图片时，它会利用PicGo自动帮你上传到github，并替换本地图片地址为github地址。

## 参考链接

+ [1.GitHub + jsDelivr + PicGo 打造稳定快速、高效免费图床](https://my.oschina.net/u/3990666/blog/4371252)
+ [2.手把手教你用Typora自动上传到picgo图床](https://blog.csdn.net/disILLL/article/details/104944710)
+ [3.typora + hexo博客中插入图片](https://yinyoupoet.github.io/2019/09/03/hexo%E5%8D%9A%E5%AE%A2%E4%B8%AD%E6%8F%92%E5%85%A5%E5%9B%BE%E7%89%87/)

