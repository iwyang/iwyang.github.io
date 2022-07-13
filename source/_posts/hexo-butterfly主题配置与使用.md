---
title: hexo butterfly主题配置与使用
categories:
  - 技术
tags:
  - hexo
comments: true
abbrlink: 5b629e16
date: 2022-02-04 09:20:42
sticky:
keywords:
description:
top_img:
cover: false
---

开始使用hexo butterfly主题，简单记录一下。主题安装文档网站：{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,blue larger %}

在你的 Hexo 根目录里：

```powershell
npm i hexo-theme-butterfly
```

升级方法：在 Hexo 根目录下，运行：

```powershell
npm update hexo-theme-butterfly
```

如果无法升级，先修改`package.json`，然后执行以上命令。

## Front-matter

### Post Front-matter

```markdown
---
title:        # 【必需】文章标题
date:         # 【必需】文章创建日期
updated:      # 【可选】文章更新日期
tags:         # 【可选】文章标籤
categories:    # 【可选】文章分类
keywords:      # 【可选】文章关键字
description:   # 【可选】文章描述
top_img:       # 【可选】文章顶部图片
comments:      # 【可选】显示文章评论模块(默认 true)
cover:         # 【可选】文章缩略图(如果没有设置top_img,文章页顶部将显示缩略图，可设为false/图片地址/留空)       
toc:           # 【可选】显示文章TOC(默认为设置中toc的enable配置)
toc_number:    # 【可选】显示toc_number(默认为设置中toc的number配置)
toc_style_simple:    # 【可选】显示 toc 简洁模式
copyright:           # 【可选】显示文章版权模块(默认为设置中post_copyright的enable配置)
copyright_author:    # 【可选】文章版权模块的文章作者
copyright_author_href:    # 【可选】文章版权模块的文章作者链接
copyright_url:            # 【可选】文章版权模块的文章连结链接
copyright_info:           # 【可选】文章版权模块的版权声明文字
mathjax:                  # 【可选】显示mathjax(当设置mathjax的per_page: false时，才需要配置，默认 false)
katex:                    # 【可选】显示katex(当设置katex的per_page: false时，才需要配置，默认 false)
aplayer:                  # 【可选】在需要的页面加载aplayer的js和css,请参考文章下面的音乐 配置
highlight_shrink:         # 【可选】配置代码框是否展开(true/false)(默认为设置中highlight_shrink的配置)
aside:                    # 【可选】显示侧边栏 (默认 true)
--- 
```

### Page Front-matter

```markdown
---
title:       # 【必需】页面标题
date:        # 【必需】页面创建日期
updated:     # 【可选】页面更新日期
type:        # 【必需】标籤、分类和友情链接三个页面需要配置
comments:    # 【可选】显示页面评论模块(默认 true)
description:  # 【可选】页面描述
keywords:     # 【可选】页面关键字
top_img:      # 【可选】页面顶部图片
mathjax:      # 【可选】显示mathjax(当设置mathjax的per_page: false时，才需要配置，默认 false)
katex:        # 【可选】显示katex(当设置katex的per_page: false时，才需要配置，默认 false)
aside:        # 【可选】显示侧边栏 (默认 true)
aplayer:      # 【可选】在需要的页面加载aplayer的js和css,请参考文章下面的音乐 配置
highlight_shrink:  【可选】配置代码框是否展开(true/false)(默认为设置中highlight_shrink的配置)
---
```

## 标签外挂

### Note

修改 主题配置文件：

```yaml
note:
  # Note tag style values:
  #  - simple    bs-callout old alert style. Default.
  #  - modern    bs-callout new (v2-v3) alert style.
  #  - flat      flat callout style with background, like on Mozilla or StackOverflow.
  #  - disabled  disable all CSS styles import of note tag.
  style: flat
  icons: false
  border_radius: 3
  # Offset lighter of background in % for modern and flat styles (modern: -12 | 12; flat: -18 | 6).
  # Offset also applied to label tag variables. This option can work with disabled note tag.
  light_bg_offset: 0
```

{% tabs note %}
<!-- tab 用法1 -->

```markdown
{% note [class] [no-icon] [style] %}
Any content (support inline tags too.io).
{% endnote %}
```

| 名稱    | 用法                                                         |
| ------- | ------------------------------------------------------------ |
| class   | 【可選】標識，不同的標識有不同的配色<br>（ default / primary / success / info / warning / danger ） |
| no-icon | 【可選】不顯示 icon                                          |
| style   | 【可選】可以覆蓋配置中的 style <br>（simple/modern/flat/disabled） |

> no-icon

```markdown
{% note no-icon %}
默认 提示块标籤
{% endnote %}

{% note default no-icon %}
default 提示块标籤
{% endnote %}

{% note primary no-icon %}
primary 提示块标籤
{% endnote %}

{% note success no-icon %}
success 提示块标籤
{% endnote %}

{% note info no-icon %}
info 提示块标籤
{% endnote %}

{% note warning no-icon %}
warning 提示块标籤
{% endnote %}

{% note danger no-icon %}
danger 提示块标籤
{% endnote %}
```

{% note no-icon %}
默认 提示块标籤
{% endnote %}

{% note default no-icon %}
default 提示块标籤
{% endnote %}

{% note primary no-icon %}
primary 提示块标籤
{% endnote %}

{% note success no-icon %}
success 提示块标籤
{% endnote %}

{% note info no-icon %}
info 提示块标籤
{% endnote %}

{% note warning no-icon %}
warning 提示块标籤
{% endnote %}

{% note danger no-icon %}
danger 提示块标籤
{% endnote %}

> flat

```markdown
{% note flat %}
默认 提示块标籤
{% endnote %}

{% note default flat %}
default 提示块标籤
{% endnote %}

{% note primary flat %}
primary 提示块标籤
{% endnote %}

{% note success flat %}
success 提示块标籤
{% endnote %}

{% note info flat %}
info 提示块标籤
{% endnote %}

{% note warning flat %}
warning 提示块标籤
{% endnote %}

{% note danger flat %}
danger 提示块标籤
{% endnote %}
```

{% note flat %}
默认 提示块标籤
{% endnote %}

{% note default flat %}
default 提示块标籤
{% endnote %}

{% note primary flat %}
primary 提示块标籤
{% endnote %}

{% note success flat %}
success 提示块标籤
{% endnote %}

{% note info flat %}
info 提示块标籤
{% endnote %}

{% note warning flat %}
warning 提示块标籤
{% endnote %}

{% note danger flat %}
danger 提示块标籤
{% endnote %}

<!-- endtab -->

<!-- tab 用法 2（自定义 icon） -->

```markdown
{% note [color] [icon] [style] %}
Any content (support inline tags too.io).
{% endnote %}
```

| 名稱  | 用法                                                         |
| ----- | ------------------------------------------------------------ |
| color | 【可選】顔色 <br>(default / blue / pink / red / purple / orange / green) |
| icon  | 【可選】可配置自定義 icon (只支持 fontawesome 圖標, 也可以配置 no-icon ) |
| style | 【可選】可以覆蓋配置中的 style<br/>（simple/modern/flat/disabled） |

> no-icon

```markdown
{% note no-icon %}
你是刷 Visa 还是 UnionPay
{% endnote %}
{% note blue no-icon %}
2021年快到了....
{% endnote %}
{% note pink no-icon %}
小心开车 安全至上
{% endnote %}
{% note red no-icon %}
这是三片呢？还是四片？
{% endnote %}
{% note orange no-icon %}
你是刷 Visa 还是 UnionPay
{% endnote %}
{% note purple no-icon %}
剪刀石头布
{% endnote %}
{% note green no-icon %}
前端最讨厌的浏览器
{% endnote %}
```

{% note no-icon %}
你是刷 Visa 还是 UnionPay
{% endnote %}
{% note blue no-icon %}
2021年快到了....
{% endnote %}
{% note pink no-icon %}
小心开车 安全至上
{% endnote %}
{% note red no-icon %}
这是三片呢？还是四片？
{% endnote %}
{% note orange no-icon %}
你是刷 Visa 还是 UnionPay
{% endnote %}
{% note purple no-icon %}
剪刀石头布
{% endnote %}
{% note green no-icon %}
前端最讨厌的浏览器
{% endnote %}

> flat

```markdown
{% note 'fab fa-cc-visa' flat %}
你是刷 Visa 还是 UnionPay
{% endnote %}
{% note blue 'fas fa-bullhorn' flat %}
2021年快到了....
{% endnote %}
{% note pink 'fas fa-car-crash' flat %}
小心开车 安全至上
{% endnote %}
{% note red 'fas fa-fan' flat%}
这是三片呢？还是四片？
{% endnote %}
{% note orange 'fas fa-battery-half' flat %}
你是刷 Visa 还是 UnionPay
{% endnote %}
{% note purple 'far fa-hand-scissors' flat %}
剪刀石头布
{% endnote %}
{% note green 'fab fa-internet-explorer' flat %}
前端最讨厌的浏览器
{% endnote %}
```

{% note 'fab fa-cc-visa' flat %}
你是刷 Visa 还是 UnionPay
{% endnote %}
{% note blue 'fas fa-bullhorn' flat %}
2021年快到了....
{% endnote %}
{% note pink 'fas fa-car-crash' flat %}
小心开车 安全至上
{% endnote %}
{% note red 'fas fa-fan' flat%}
这是三片呢？还是四片？
{% endnote %}
{% note orange 'fas fa-battery-half' flat %}
你是刷 Visa 还是 UnionPay
{% endnote %}
{% note purple 'far fa-hand-scissors' flat %}
剪刀石头布
{% endnote %}
{% note green 'fab fa-internet-explorer' flat %}
前端最讨厌的浏览器
{% endnote %}

<!-- endtab -->
{% endtabs %}

### Tabs

使用方法：

```markdown
{% tabs Unique name, [index] %}
<!-- tab [Tab caption] [@icon] -->
Any content (support inline tags too).
<!-- endtab -->
{% endtabs %}

Unique name   : Unique name of tabs block tag without comma.
                Will be used in #id's as prefix for each tab with their index numbers.
                If there are whitespaces in name, for generate #id all whitespaces will replaced by dashes.
                Only for current url of post/page must be unique!
[index]       : Index number of active tab.
                If not specified, first tab (1) will be selected.
                If index is -1, no tab will be selected. It's will be something like spoiler.
                Optional parameter.
[Tab caption] : Caption of current tab.
                If not caption specified, unique name with tab index suffix will be used as caption of tab.
                If not caption specified, but specified icon, caption will empty.
                Optional parameter.
[@icon]       : FontAwesome icon name (full-name, look like 'fas fa-font')
                Can be specified with or without space; e.g. 'Tab caption @icon' similar to 'Tab caption@icon'.
                Optional parameter.
```

{% note primary no-icon %}
Demo 1 - 预设选择第一个【默认】
{% endnote %}

```markdown
{% tabs 方法 %}
<!-- tab 方法一 -->
**This is Tab 1.**
<!-- endtab -->

<!-- tab 方法二 -->
**This is Tab 2.**
<!-- endtab -->

<!-- tab 方法三 -->
**This is Tab 3.**
<!-- endtab -->
{% endtabs %}
```

{% tabs 方法 %}
<!-- tab 方法一 -->
**This is Tab 1.**
<!-- endtab -->

<!-- tab 方法二 -->
**This is Tab 2.**
<!-- endtab -->

<!-- tab 方法三 -->
**This is Tab 3.**
<!-- endtab -->
{% endtabs %}

{% note primary no-icon %}
Demo 4 - 自定义Tab名 + 只有icon + icon和Tab名
{% endnote %}

```markdown
{% tabs test4 %}
<!-- tab 第一个Tab -->
**tab名字为第一个Tab**
<!-- endtab -->

<!-- tab @fab fa-apple-pay -->
**只有图标 没有Tab名字**
<!-- endtab -->

<!-- tab 炸弹@fas fa-bomb -->
**名字+icon**
<!-- endtab -->
{% endtabs %}
```

{% tabs test4 %}
<!-- tab 第一个Tab -->
**tab名字为第一个Tab**
<!-- endtab -->

<!-- tab @fab fa-apple-pay -->
**只有图标 没有Tab名字**
<!-- endtab -->

<!-- tab 炸弹@fas fa-bomb -->
**名字+icon**
<!-- endtab -->
{% endtabs %}

### Button

使用方法：

```markdown
{% btn [url],[text],[icon],[color] [style] [layout] [position] [size] %}

[url]         : 链接
[text]        : 按钮文字
[icon]        : [可选] 图标
[color]       : [可选] 按钮背景顔色(默认style时）
                      按钮字体和边框顔色(outline时)
                      default/blue/pink/red/purple/orange/green
[style]       : [可选] 按钮样式 默认实心
                      outline/留空
[layout]      : [可选] 按钮佈局 默认为line
                      block/留空
[position]    : [可选] 按钮位置 前提是设置了layout为block 默认为左边
                      center/right/留空
[size]        : [可选] 按钮大小
                      larger/留空
```

```markdown
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,blue larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,pink larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,red larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,purple larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,orange larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,green larger %}
```

{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,blue larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,pink larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,red larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,purple larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,orange larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,green larger %}

```markdown
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,block blue larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,block center pink larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,block right red larger %}
```

{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,block blue larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,block center pink larger %}
{% btn 'https://butterfly.js.org/',Butterfly,far fa-hand-point-right,block right red larger %}

### label

高亮所需的文字

```markdown
{% label text color %}
```

| text  | 文字                                                         |
| ----- | ------------------------------------------------------------ |
| 參數  | 解釋                                                         |
| color | 【可選】背景顏色，默認為 `default`<br />default/blue/pink/red/purple/orange/green |

```markdown
臣亮言：{% label 先帝 %}创业未半，而{% label 中道崩殂 blue %}。今天下三分，{% label 益州疲敝 pink %}，此诚{% label 危急存亡之秋 red %}也！然侍衞之臣，不懈于内；{% label 忠志之士 purple %}，忘身于外者，盖追先帝之殊遇，欲报之于陛下也。诚宜开张圣听，以光先帝遗德，恢弘志士之气；不宜妄自菲薄，引喻失义，以塞忠谏之路也。
宫中、府中，俱为一体；陟罚臧否，不宜异同。若有{% label 作奸 orange %}、{% label 犯科 green %}，及为忠善者，宜付有司，论其刑赏，以昭陛下平明之治；不宜偏私，使内外异法也。
```

臣亮言：{% label 先帝 %}创业未半，而{% label 中道崩殂 blue %}。今天下三分，{% label 益州疲敝 pink %}，此诚{% label 危急存亡之秋 red %}也！然侍衞之臣，不懈于内；{% label 忠志之士 purple %}，忘身于外者，盖追先帝之殊遇，欲报之于陛下也。诚宜开张圣听，以光先帝遗德，恢弘志士之气；不宜妄自菲薄，引喻失义，以塞忠谏之路也。
宫中、府中，俱为一体；陟罚臧否，不宜异同。若有{% label 作奸 orange %}、{% label 犯科 green %}，及为忠善者，宜付有司，论其刑赏，以昭陛下平明之治；不宜偏私，使内外异法也。

### timeline

```markdown
{% timeline title,color %}
<!-- timeline title -->
xxxxx
<!-- endtimeline -->
<!-- timeline title -->
xxxxx
<!-- endtimeline -->
{% endtimeline %}
```

| 參數  | 解釋                                                         |
| ----- | ------------------------------------------------------------ |
| title | 標題/時間線                                                  |
| color | timeline 顏色<br />default(留空) / blue / pink / red / purple / orange / green |

```markdown
{% timeline 2022 %}
<!-- timeline 01-02 -->
这是测试页面
<!-- endtimeline -->
{% endtimeline %}
```

{% timeline 2022 %}
<!-- timeline 01-02 -->
这是测试页面
<!-- endtimeline -->
{% endtimeline %}

```markdown
{% timeline 2022,blue %}
<!-- timeline 01-02 -->
这是测试页面
<!-- endtimeline -->
{% endtimeline %}
```

{% timeline 2022,blue %}
<!-- timeline 01-02 -->
这是测试页面
<!-- endtimeline -->
{% endtimeline %}

### tag-hide

{% note warning %}

2.2.0以上提供

請注意，tag-hide內的標簽外掛content內都不建議有h1 - h6 等標題。因為Toc會把隱藏內容標題也顯示出來，而且當滾動屏幕時，如果隱藏內容沒有顯示出來，會導致Toc的滾動出現異常。

{% endnote %}

如果你想把一些文字、內容隱藏起來，並提供按鈕讓用戶點擊顯示。可以使用這個標籤外掛。

{% tabs tag-hide %}

<!-- tab Toggle -->

> 2.3.0以上支持

如果你需要展示的內容太多，可以把它隱藏在收縮框裏，需要時再把它展開。

( display 不能包含英文逗號，可用`&sbquo;`)

```markdown
{% hideToggle display,bg,color %}
content
{% endhideToggle %}
```

> Demo

```markdown
{% hideToggle Butterfly安裝方法 %}
在你的博客根目錄裏

git clone -b master https://github.com/jerryc127/hexo-theme-butterfly.git themes/Butterfly

如果想要安裝比較新的dev分支，可以

git clone -b dev https://github.com/jerryc127/hexo-theme-butterfly.git themes/Butterfly

{% endhideToggle %}
```

{% hideToggle Butterfly安裝方法 %}
在你的博客根目錄裏

git clone -b master https://github.com/jerryc127/hexo-theme-butterfly.git themes/Butterfly

如果想要安裝比較新的dev分支，可以

git clone -b dev https://github.com/jerryc127/hexo-theme-butterfly.git themes/Butterfly

{% endhideToggle %}

<!-- endtab -->

<!-- tab Inline -->
`inline` 在文本里面添加按鈕隱藏內容，只限文字

( content不能包含英文逗號，可用`&sbquo;`)

```markdown
{% hideInline content,display,bg,color %}
```

- content: 文本內容

- display: 按鈕顯示的文字(可選)

- bg: 按鈕的背景顏色(可選)

- color: 按鈕文字的顏色(可選)

> Demo

```markdown
哪個英文字母最酷？ {% hideInline 因為西裝褲(C裝酷),查看答案,#FF7242,#fff %}

門裏站着一個人? {% hideInline 閃 %}
```

哪個英文字母最酷？ {% hideInline 因為西裝褲(C裝酷),查看答案,#FF7242,#fff %}

門裏站着一個人? {% hideInline 閃 %}

<!-- endtab -->

<!-- tab Block -->
`block`獨立的block隱藏內容，可以隱藏很多內容，包括圖片，代碼塊等等

( display 不能包含英文逗號，可用`&sbquo;`)

```markdown
{% hideBlock display,bg,color %}
content
{% endhideBlock %}
```

- content: 文本內容
- display: 按鈕顯示的文字(可選)
- bg: 按鈕的背景顏色(可選)
- color: 按鈕文字的顏色(可選)

> Demo

```mark
查看答案
{% hideBlock 查看答案 %}
傻子，怎麼可能有答案
{% endhideBlock %}
```

查看答案
{% hideBlock 查看答案 %}
傻子，怎麼可能有答案
{% endhideBlock %}

<!-- endtab -->


{% endtabs %}

### flink

可在任何界面插入類似友情鏈接列表效果

內容格式與友情鏈接界面一樣，支持 yml 格式

```markdown
{% flink %}
xxxxxx
{% endflink %}
```

```markdown
{% flink %}
- class_name: 友情鏈接
  class_desc: 那些人，那些事
  link_list:
    - name: JerryC
      link: https://jerryc.me/
      avatar: https://jerryc.me/img/avatar.png
      descr: 今日事,今日畢
    - name: Hexo
      link: https://hexo.io/zh-tw/
      avatar: https://d33wubrfki0l68.cloudfront.net/6657ba50e702d84afb32fe846bed54fba1a77add/827ae/logo.svg
      descr: 快速、簡單且強大的網誌框架

- class_name: 網站
  class_desc: 值得推薦的網站
  link_list:
    - name: Youtube
      link: https://www.youtube.com/
      avatar: https://i.loli.net/2020/05/14/9ZkGg8v3azHJfM1.png
      descr: 視頻網站
    - name: Weibo
      link: https://www.weibo.com/
      avatar: https://i.loli.net/2020/05/14/TLJBum386vcnI1P.png
      descr: 中國最大社交分享平臺
    - name: Twitter
      link: https://twitter.com/
      avatar: https://i.loli.net/2020/05/14/5VyHPQqR6LWF39a.png
      descr: 社交分享平臺
{% endflink %}
```

## 引入Aplayer播放音乐

**PS：未测试**

1. 在博客根目录[Blogroot]下打开终端，运行以下指令安装hexo-tag-aplayer插件：

   ```bash
   npm install hexo-tag-aplayer --save
   ```

2. 在站点配置文件`[Blogroot]\_config.yml`中新增配置项，建议直接加在最底下：

   ```yaml
   # APlayer
   # https://github.com/MoePlayer/hexo-tag-aplayer/blob/master/docs/README-zh_cn.md
   aplayer:
     meting: true
     asset_inject: false
   ```

3. 修改主题配置文件`[Blogroot]\_config.butterfly.yml`中关于Aplayer的配置内容

   ```yaml
   # Inject the css and script (aplayer/meting)
   aplayerInject:
     enable: true
     per_page: true
   ```

4. 在主题配置文件`[Blogroot]\_config.butterfly.yml`的inject配置项中添加Aplayer的容器。

   ```yaml
   inject:
     head:
     bottom:
       - <div class="aplayer no-destroy" data-id="5183531430" data-server="netease" data-type="playlist" data-fixed="true" data-mini="true" data-listFolded="false" data-order="random" data-preload="none" data-autoplay="false" muted></div>
   ```

5. 在博客根目录`[Blogroot]`下打开终端，运行以下指令

   ```bash
   hexo clean
   hexo generate
   hexo server
   ```

6. 关于更换歌单的问题，大部分同学都因为只更改了data-id的值，所以出现歌单加载不出的情况，此处需要注意，data-id、data-server、data-type分别对应了`歌单的id，歌单的服务商、歌单的类型`~~（感觉自己说了废话）~~，所以需要确认这三项是一一对应的。

   

   如图中所示，找到网易云歌单的url，`https://music.163.com/#/playlist?id=4907060762`,此处的palylist对应的就是data-type的值，id就是data-id的值，而网易云的data-server为netease，这个可以通过Aplayer的插件文档查阅到。**只有三个参数对应正确才能正常加载歌单。**

7. Aplayer的网易云歌单接口时不时的会挂掉，所以如果你确定你配置正确，但是歌单还是没有出现。不妨去看看其他人的站点是不是也没有Aplayer标签了来判断是Aplayer本身接口的问题还是自己配置出错的问题。

8. 配置成功后会发现Aplayer的吸底标签一直占据着左下角的一片空间，对手机端阅读不太友好，可以添加一下CSS样式使其自动缩进隐藏。在 `[Blogroot]\themes\butterfly\source\css\custom.css`中(没有这个文件就按照路径自己新建)添加如下内容：

   ```css
   .aplayer.aplayer-fixed.aplayer-narrow .aplayer-body {
     left: -66px !important;
     /* 默认情况下缩进左侧66px，只留一点箭头部分 */
   }
   
   .aplayer.aplayer-fixed.aplayer-narrow .aplayer-body:hover {
     left: 0 !important;
     /* 鼠标悬停是左侧缩进归零，完全显示按钮 */
   }
   ```

   9.不要忘了到主题配置文件引入自定义样式，修改`[Blogroot]_config.butterfly.yml`的`inject`配置项：

   ```diff
     inject:
       head:
   +     - <link rel="stylesheet" href="/css/custom.css"  media="defer" onload="this.media='all'">
       bottom:
         - <div class="aplayer no-destroy" data-id="5183531430" data-server="netease" data-type="playlist" data-fixed="true" data-mini="true" data-listFolded="false" data-order="random" data-preload="none" data-autoplay="false" muted></div>
   ```

   10.更多自定义样式魔改内容详见站内教程：[Custom Beautify](https://akilar.top/posts/ebf20e02/)

## 引入自定义 css

在站点配置文件 blog/_config.blog.yml 中，搜索定位到 inject，插入以下内容：

```yaml
inject:
  head:
    # - <link rel="stylesheet" href="/xxx.css">
    - <link rel="stylesheet" href="/css/custom.css">
```

这样，后续所有样式的自定义，就可以在 blog/source/css/custom.css 文件中进行，能不动主题源码，就不要改源码，以免后续更新变得复杂。

### H1~H6 小风车样式修改

1.主题目录：

```diff
beautify:
  enable: true
  field: post # site/post
  # title-prefix-icon: '\f0c1' 
+  title-prefix-icon: '\f863'
  title-prefix-icon-color: '#F47466'
```

2.让小风车转起来,在上文的 `blog/source/css/custom.css` 文件中，加入以下代码即可。

```css
/* 文章页H1-H6图标样式效果 */
h1::before, h2::before, h3::before, h4::before, h5::before, h6::before {
    -webkit-animation: ccc 1.6s linear infinite ;
    animation: ccc 1.6s linear infinite ;
}
@-webkit-keyframes ccc {
    0% {
        -webkit-transform: rotate(0deg);
        transform: rotate(0deg)
    }
    to {
        -webkit-transform: rotate(-1turn);
        transform: rotate(-1turn)
    }
}
@keyframes ccc {
    0% {
        -webkit-transform: rotate(0deg);
        transform: rotate(0deg)
    }
    to {
        -webkit-transform: rotate(-1turn);
        transform: rotate(-1turn)
    }
}
```

3.小风车颜色 css 代码

```css
#content-inner.layout h1::before {
    color: #ef50a8 ;
    margin-left: -1.55rem;
    font-size: 1.3rem;
    margin-top: -0.23rem;
}
#content-inner.layout h2::before {
    color: #fb7061 ;
    margin-left: -1.35rem;
    font-size: 1.1rem;
    margin-top: -0.12rem;
}
#content-inner.layout h3::before {
    color: #ffbf00 ;
    margin-left: -1.22rem;
    font-size: 0.95rem;
    margin-top: -0.09rem;
}
#content-inner.layout h4::before {
    color: #a9e000 ;
    margin-left: -1.05rem;
    font-size: 0.8rem;
    margin-top: -0.09rem;
}
#content-inner.layout h5::before {
    color: #57c850 ;
    margin-left: -0.9rem;
    font-size: 0.7rem;
    margin-top: 0.0rem;
}
#content-inner.layout h6::before {
    color: #5ec1e0 ;
    margin-left: -0.9rem;
    font-size: 0.66rem;
    margin-top: 0.0rem;
}
```

**修改风车图标大小：**

```css
#content-inner.layout h1::before {
    color: #ef50a8 ;
    margin-left: -31px;
    font-size: 26px;
    margin-top: -5px;
}
#content-inner.layout h2::before {
    color: #fb7061 ;
    margin-left: -27px;
    font-size: 22px;
    margin-top: -3px;
}
#content-inner.layout h3::before {
    color: #ffbf00 ;
    margin-left: -25px;
    font-size: 20px;
    margin-top: -2px;
}
#content-inner.layout h4::before {
    color: #a9e000 ;
    font-size: 16px;
    margin-top: -2px;
}
#content-inner.layout h5::before {
    color: #57c850 ;
    margin-left: -18px;
    font-size: 14px;
    margin-top: 0;
}
#content-inner.layout h6::before {
    color: #5ec1e0 ;
    margin-left: -18px;
    font-size: 13px;
    margin-top: 0;
}
```

4.小风车 hover 效果

```css
#content-inner.layout h1:hover, #content-inner.layout h2:hover, #content-inner.layout h3:hover, #content-inner.layout h4:hover, #content-inner.layout h5:hover, #content-inner.layout h6:hover {
    color: #49b1f5 ;
}
#content-inner.layout h1:hover::before, #content-inner.layout h2:hover::before, #content-inner.layout h3:hover::before, #content-inner.layout h4:hover::before, #content-inner.layout h5:hover::before, #content-inner.layout h6:hover::before {
    color: #49b1f5 ;
    -webkit-animation: ccc 3.2s linear infinite ;
    animation: ccc 3.2s linear infinite ;
}
```

### 修改标题前图标为闪电

修改标题前图标为闪电：`title-prefix-icon:'\f0e7'`，颜色为黄色： `title-prefix-icon-color: "#ffb821"`

### 页面设置图标转速

`blog/source/css/custom.css` 文件中，加入以下代码：

```css
/* 页面设置icon转动速度调整 */
#rightside_config i.fas.fa-cog.fa-spin {
    animation: fa-spin 5s linear infinite ;
}
```

### 页面插入 B 站视频 / Bilibili

直接复制插入你的 md 文章就行，修改里面的 aid 为你的视频 id：

```html
<div align=center class="aspect-ratio">
    <iframe src="https://player.bilibili.com/player.html?aid=9926758&&page=1&as_wide=1&high_quality=1&danmaku=0" 
    scrolling="no" 
    border="0" 
    frameborder="no" 
    framespacing="0" 
    high_quality=1
    danmaku=1 
    allowfullscreen="true"> 
    </iframe>
</div>
```

修改 css 样式，记得去 `blog/source/css/custom.css` 里，添加上述的样式：

```css
/*哔哩哔哩视频适配*/
.aspect-ratio {position: relative;width: 100%;height: 0;padding-bottom: 75%;margin: 3% auto;text-align: center;}      
.aspect-ratio iframe {
    position: absolute;
    width: 100%;
    height: 100%;
    left: 0;
    top: 0;
}
```

### 图片下的说明文字居中

在 `blog/source/css/custom.css` 中添加如下代码：

```css
.jg-caption{
    text-align: center !important;
}
```

## 隐藏指定页面`title`

在页面md源码输入：

```html
<style>
.page-title {
    display: none;
  }
</style>
```

## 隐藏二级目录

默认子目录是展开的，如果你想要隐藏，在子目录里添加 hide 。

```yaml
List||fas fa-list||hide:
  Music: /music/ || fas fa-music
  Movie: /movies/ || fas fa-video
```

## Tag Plugins Plus

地址：[Tag Plugins Plus](https://akilar.top/posts/615e2dec)

## hexo设置skip_render

hexo设置skip_render, 指定不进行渲染的文件或文件夹

1.单个文件夹下全部文件：

```
skip_render: demo/*
```

2.单个文件夹下指定类型文件：

```
skip_render: demo/*.html
```

3.单个文件夹下全部文件以及子目录:

```
skip_render: demo/**
```

4.多个文件夹以及各种复杂情况：

```
skip_render:
    - 'demo/*.html'
    - 'demo/**'
```

## 参考链接

+ [Butterfly 安装文档(一) 快速开始](https://butterfly.js.org/posts/21cfbf15/)
+ [我的 Blog 美化日记 ——Hexo+Butterfly](https://guole.fun/posts/butterfly-custom/)
+ [hexo设置skip_render, 指定不进行渲染的文件或文件夹](https://www.jianshu.com/p/76220131c7e9)
+ [引入Aplayer播放音乐](https://akilar.top/posts/3afa069a/)

