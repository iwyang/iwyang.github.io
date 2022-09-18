---
title: Hugo Stack主题配置与使用
categories:
  - 技术
tags:
  - hugo
abbrlink: 3bf3725e
date: 2021-07-24 01:15:26
cover: false
---



又换主题了，这回使用的是[hugo-theme-stack](https://github.com/CaiJimmy/hugo-theme-stack)，无意发现这款主题，正合我意，够简单，最重要的是支持本地搜索，再不用弄哪个`Alogia`了。

## 下载主题&更新主题

1. 下载主题

```bash
git init
git submodule add https://github.com/CaiJimmy/hugo-theme-stack/ themes/hugo-theme-stack
```

2. 更新主题

```bash
git submodule update --remote
```

## 查看主题版本号

```bash
git show 查看当前版本
----------------------------------------------------------------
git tag　列出所有版本号
git checkout　+某版本号　(你当前文件夹下的源码会变成这个版本号的源码)
```

## `config.yaml`配置文件

```yaml
baseurl: /
languageCode: zh-CN
theme: hugo-theme-stack
paginate: 10
title: Bore's Notes

# Change it to your Disqus shortname before using
# disqusShortname: 

# GA Tracking ID
googleAnalytics:

# Theme i18n support
# Available values: en, fr, id, ja, ko, pt-br, zh-cn, zh-tw, es, de, nl, it, th, el, uk
DefaultContentLanguage: zh-cn

# Set hasCJKLanguage to true if DefaultContentLanguage is in [zh-cn ja ko]
# This will make .Summary and .WordCount behave correctly for CJK languages.
hasCJKLanguage: true

permalinks:
    post: /archives/:slug/
    page: /:slug/
    
# whether to use emoji code
enableEmoji: true

params:
    mainSections:
        - post
    featuredImageField: image
    rssFullContent: true
    favicon: /img/favicon.png

    footer:
        since: 2020
        customText:

    dateFormat:
        published: 2006-01-02
        lastUpdated: 2006-01-02

    sidebar:
        emoji: 🍥
        subtitle: 博观而约取，厚积而薄发
        avatar:
            enabled: false
            local: true
            src: img/avatar.jpg

    article:
        math: false
        toc: true
        readingTime: false 
        license:
            enabled: false
            default: Licensed under CC BY-NC-SA 4.0
        edit:
            enabled: true

    comments:
        enabled: true
        provider: waline
        
        disqusjs:
            shortname:
            apiUrl:
            apiKey:
            admin:
            adminLabel:

        utterances:
            repo: 
            issueTerm: title
            label: utterances
            theme: dark-orange

        remark42:
            host:
            site:
            locale:

        vssue:
            platform:
            owner:
            repo:
            clientId:
            clientSecret:
            autoCreateIssue: false

        # Waline client configuration see: https://waline.js.org/en/reference/client.html
        waline:
            serverURL: https://your-domain.vercel.app
            lang: zh-CN
            visitor: false
            avatar: mp
            emoji:
                - https://cdn.jsdelivr.net/gh/walinejs/emojis/weibo
            requiredMeta:
                - nick
                - mail
            placeholder: 欢迎评论
            locale:
                admin: 博主
   
        twikoo:
            envId: https://twikoo-lake.vercel.app
            region:
            path:
            lang:
            
        giscus:
            repo:
            repoID:
            category:
            categoryID:
            mapping:
            lightTheme:
            darkTheme:
            reactionsEnabled: 1
            emitMetadata: 0
            
        gitalk:
            owner: 
            admin:  
            repo: 
            clientID: 
            clientSecret: 
            
        cusdis:
            host: 
            id: 

    widgets:
        enabled:
            - search
            - categories
            - tag-cloud
            - archives
           
        archives:
            limit: 10000

        tagCloud:
            limit: 10000
            
        categoriesCloud:
            limit: 10000

    opengraph:
        twitter:
            # Your Twitter username
            site:

            # Available values: summary, summary_large_image
            card: summary_large_image

    defaultImage:
        opengraph:
            enabled: false
            local: false
            src:

    colorScheme:
        # Display toggle
        toggle: true

        # Available values: auto, light, dark
        default: auto

    imageProcessing:
        cover:
            enabled: true
        content:
            enabled: true

### Custom menu
### See https://docs.stack.jimmycai.com/configuration/custom-menu.html
### To remove about, archive and search page menu item, remove `menu` field from their FrontMatter
menu:
    main:
        - identifier: home
          name: 首页
          url: /
          weight: -100
          pre: home
          params:
              ### For demonstration purpose, the home link will be open in a new tab
              newTab: false
              icon: home
    # social:
        # - identifier: github
          # name: GitHub
          # url: https://github.com/iwyang
          # params:
            # icon: brand-github
            
        # - identifier: twitter
          # name: Twitter
          # url: https://twitter.com
          # params:
            # icon: brand-twitter

related:
    includeNewer: true
    threshold: 60
    toLower: false
    indices:
        - name: tags
          weight: 100

        - name: categories
          weight: 200

markup:
    goldmark:
        renderer:
            ## Set to true if you have HTML content inside Markdown
            unsafe: true
    tableOfContents:
        endLevel: 4
        ordered: true
        startLevel: 2
    highlight:
        noClasses: false
```

## `archetypes`默认模板

```yaml
title: "{{ replace .TranslationBaseName "-" " " | title }}"
slug: ""
description: ""
date: {{ .Date }}
lastmod: {{ .Date }}
draft: false
toc: true
weight: false
image: ""
categories: [""]
tags: [""]
```

## 显示右侧工具栏分类目录

参考 https://github.com/CaiJimmy/hugo-theme-stack/issues/169

1. Create `categories.html` in layouts/partials/widget

```html
<section class="widget tagCloud">
  <div class="widget-icon">
      {{ partial "helper/icon" "categories" }}
  </div>
  <h2 class="widget-title section-title">{{ T "widget.categoriesCloud.title" }}</h2>

  <div class="tagCloud-tags">
      {{ range first .Site.Params.widgets.categoriesCloud.limit .Site.Taxonomies.categories.ByCount }}
          <a href="{{ .Page.RelPermalink }}" class="font_size_{{ .Count }}">
              {{ .Page.Title }}
          </a>
      {{ end }}
  </div>
</section>
```

2. 修改 `config.yaml`

```yaml
widgets:
        enabled:
            - categories
        
        categoriesCloud:
            limit: 20
```

3. 网站根目录新建`\i18n\zh-CN.yaml`

```yaml
widget:
    categoriesCloud:
        title: 
            other: 分类
```

5. Download categories.svg paste to `assets/icons`, from [here](https://github.com/rmdhnreza/rmdhnreza.my.id/tree/main/assets/icons)

> **注意**：可以按需删除图标。

## 文章底部添加`在 GitHub 上编辑此页`

1. 拷贝主题目录`/layouts/partials/article/components/footer.html`到网站根目录，修改为：

```html
<footer class="article-footer">
    {{ partial "article/components/tags" . }}

    {{ if and (.Site.Params.article.license.enabled) (not (eq .Params.license false)) }}
    <section class="article-copyright">
        {{ partial "helper/icon" "copyright" }}
        <span>{{ default .Site.Params.article.license.default .Params.license | markdownify }}</span>
    </section>
    {{ end }}
	
	{{ if and (.Site.Params.article.edit.enabled) (not (eq .Params.edit false)) }}
    <section class="article-edit">
        {{ partial "helper/icon" "external-link" }}
        <span><a style="color: inherit;" href="https://github.com/iwyang/iwyang.github.io/edit/develop/content/{{ replace .File.Path "\\" "/" }}" target="_blank" rel="noopener noreferrer">在 GitHub 上编辑此页</a></span>
    </section>
    {{ end }}

    {{- if ne .Lastmod .Date -}}
    <section class="article-lastmod">
        {{ partial "helper/icon" "clock" }}
        <span>
            {{ T "article.lastUpdatedOn" }} {{ .Lastmod.Format ( or .Site.Params.dateFormat.lastUpdated "Jan 02, 2006 15:04 MST" ) }}
        </span>
    </section>
    {{- end -}}
</footer>
```

2. 编辑`config.yaml`：

```yaml
    article:
        math: false
        toc: true
        readingTime: true 
        license:
            enabled: false
            default: Licensed under CC BY-NC-SA 4.0
        edit:
            enabled: true
```

以后只要在Frontmatter添加`edit: false`来关闭。

3. 拷贝`external-link.svg`图标到网站根目录`/assets/icons`下。图标地址：[点击直达](https://github.com/iwyang/iwyang.github.io/tree/develop/assets/icons)

## 自动更新文章最后修改时间

1.在`config.yaml`里写:

```yaml
frontmatter:
  lastmod: [":git", "lastmod", ":fileModTime", ":defalut"]    
  
enableGitInfo: true
gitRepo: "https://github.com/iwyang/hugo"
```

- `:git`：git 文件提交修改时间
- `:fileModTime`：文件修改时间
- `lastmod`：文章里 lastmod 字段
- `:defalut`：默认时间

> `config.toml`里写：
>
> 
>
> [frontmatter]
>   lastmod = [":git", "lastmod", ":fileModTime", ":defalut"]
>
> 
>
> enableGitInfo = true
>
> 
>
> gitRepo = "https://github.com/iwyang/hugo"



2.`.github/workflows/xx.yml`：

yml 文件中添加 2 行设置当前环境时区

```yaml
name: Hugo build and deploy
on:
  push:

env:
  TZ: Asia/Shanghai # 设置当前环境时区
```

3.gihutb action 里 yaml 上配置

**建构前**新增以下配置，主要是 quotePath，默认情况下，文件名包含中文时，git 会使用引号吧文件名括起来，这会导致 action 中无法读取`:GitInfo` 变量，所以要设置 `Disable quotePath`

```yaml
- name: Git Configuration
        run: |
          git config --global core.quotePath false
          git config --global core.autocrlf false
          git config --global core.safecrlf true
          git config --global core.ignorecase false
```

使用 `checkout` 的话 `fetch-depth` 需要设为 0，depth 默认是为 1，默认只拉取分支最近一次 commit，可能会导致一些文章的 `GitInfo` 变量无法获取，设为 0 代表拉去所有分支所有提交。

```yaml
	uses: actions/checkout@v2
		  fetch-depth: 0   #设为0
```

以下是我最终的 yml 配置文件：

```yaml
name: GitHub Page Deploy

on:
  push:
    branches:
      - develop
      
env:
  TZ: Asia/Shanghai # 设置当前环境时区
  
jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout master
        uses: actions/checkout@v2.3.4
        with:
          submodules: true  # Fetch Hugo themes (true OR recursive)
          fetch-depth: 0    # Fetch all history for .GitInfo and .Lastmod
          
      - name: Git Configuration
        run: |
          git config --global core.quotePath false
          git config --global core.autocrlf false
          git config --global core.safecrlf true
          git config --global core.ignorecase false 
          
      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2.5.0
        with:
          hugo-version: 'latest'
          extended: true
          
      - name: Cache resources # 缓存 resource 文件加快生成速度
        uses: actions/cache@v2
        with:
          path: resources
         # 检查照片文件变化
          key: ${{ runner.os }}-hugocache-${{ hashFiles('content/**/*') }}
          restore-keys: ${{ runner.os }}-hugocache-             

      - name: Build Hugo
        run: hugo -v --gc --minify

      - name: Deploy Hugo to gh-pages
        uses: peaceiris/actions-gh-pages@v3.8.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          PUBLISH_BRANCH: master
          PUBLISH_DIR: ./public
        # cname:
        
      - name: Deploy Hugo to Server
        uses: SamKirkland/FTP-Deploy-Action@4.3.0
        with:
          server: 104.224.191.88
          username: admin
          password: ${{ secrets.FTP_MIRROR_PASSWORD }}
          local-dir: ./public/
          server-dir: /var/www/speak/
```

别人：

```yaml

name: Hugo build and deploy
on:
  push:

env:
  TZ: Asia/Shanghai # 设置当前环境时区

jobs:
  Actions-Hugo-Deploy:
    runs-on: ubuntu-latest
    steps:

      - name: Check out repository code
        uses: actions/checkout@v2
        with:
          submodules: recursive  # Fetch Hugo themes (true OR recursive)
          fetch-depth: 0         # Fetch all history for .GitInfo and .Lastmod

      - name: Git Configuration
        run: |
          git config --global core.quotePath false
          git config --global core.autocrlf false
          git config --global core.safecrlf true
          git config --global core.ignorecase false          
      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: latest
          extended: true
      - name: Build Hugo static files
        run: hugo -v --gc --minify
      - name: Deploy to Github Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
          external_repository: Charlie-king/Charlie-king.github.io
          publish_branch: main
          publish_dir: ./public

  
      - name: NPM install
        run: npm install
      - name: Update Algolia index
        env:
          ALGOLIA_APP_ID: B6R922P6DD
          ALGOLIA_ADMIN_KEY: ${{ secrets.ALGOLIA_ADMIN_KEY }}
          ALGOLIA_INDEX_NAME: 'dev_hugo'
          ALGOLIA_INDEX_FILE: './public/index.json'
        run: npm run algolia
  
```

### 删除文章底部更新于

```html
<style>
.article-footer {
    display: none;
  }
</style>
```

## 删除相关文章、分类图片，修改相关文章数目

### 删除相关文章图片

根目录`assets/scss/partials/layout/article.scss`

```scss
.related-contents {
    overflow-x: auto;
    padding-bottom: 15px;

    & > .flex {
        float: left;
    }

    article {
        margin-right: 15px;
        flex-shrink: 0;
        overflow: hidden;
        width: 250px;
        height: 80px; //改为80
        box-shadow: var(--shadow-l2); //加个卡片阴影

        .article-title {
            font-size: 1.4rem; //改为1.4
            margin: auto;
            justify-content: center; //居中
        }
```

### 删除分类图片

根目录`assets/scss/partials/layout/list.scss`

```scss
.subsection-list {
    margin-bottom: var(--section-separation);
    overflow-x: auto;

    .article-list--tile {
        display: flex;
        padding-bottom: 15px;

        article {
            width: 200px; //改爲200px
            height: 50px; //改爲50px
            margin-right: 5px; //改爲5px
            flex-shrink: 0;
            box-shadow: var(--shadow-l2); //改个卡片阴影

            .article-title {
                margin: 0;
                font-size: 1.5rem; //改爲1.5rem，調整字體尺寸
            }

            .article-details {
                padding: 20px;
                justify-content: center; //添加justify-content設定，保持字體居中
            }

        }
    }
}
```

### 修改相关文章数目

根目录`layouts/partials/article/components/related-contents.html`

```html
 {{ $related := (where (.Site.RegularPages.Related .) "Params.hidden" "!=" true) | first 3 }}  //修改数字即可
```

数字设为0，即关闭`相关文章`。

## 加入字数统计、站点总字数统计

### 加入字数统计

1.直接用阅读时间改的，图标路径为根目录`assets\icons`

根目录`layouts\partials\article\components\details.html`

```html
        {{ if .Site.Params.article.readingTime }}
            <div>
                {{ partial "helper/icon" "pencil" }}
                <time class="article-words">
                    {{ .WordCount }} 字
                </time>
            </div>
        {{ end }}
    </footer>
```

2.然后在`config.yaml`中加入一行，以正确显示中文字符数量

```yaml
hasCJKLanguage: true
```

3.`config.yaml`中确保`readingTime: true`

### 站点总字数统计

1.根目录`layouts\partials\footer\footer.html`里写上总字数参数

```html
{{$scratch := newScratch}}
{{ range (where .Site.Pages "Kind" "page" )}}
    {{$scratch.Add "total" .WordCount}}
{{ end }}
```

2.根目录`layouts\partials\footer\footer.html`

```html
<section class="copyright">
        &copy; 
        {{ if and (.Site.Params.footer.since) (ne .Site.Params.footer.since (int (now.Format "2006"))) }}
            {{ .Site.Params.footer.since }} - 
        {{ end }}
        {{ now.Format "2006" }} Bore's Blog<br>共 {{ div ($scratch.Get "total") 1000.0 | lang.FormatNumber 2 }}k 字 · 共 {{ len (where .Site.RegularPages "Section" "post") }}篇文章</br><span><p>
    </section>
```

**PS：如果加入`站点总字数统计`，`Github Action`部署到服务器就会变慢。**

## 添加友情链接 shortcodes

1. 网站根目录新建文件`layouts\page\links.html`：

   ```html
   {{ define "body-class" }}article-page keep-sidebar{{ end }}
   {{ define "main" }}
       {{ partial "article/article.html" . }}
       
       <div class="article-list--compact links">
           {{ $siteResources := resources }}
           {{ range $i, $link :=  $.Site.Data.links }}
               <article>
                   <a href="{{ $link.website }}" target="_blank" rel="noopener">
                       <div class="article-details">
                           <h2 class="article-title">
                               {{- $link.title -}}
                           </h2>
                           <footer class="article-time">
                               {{ with $link.description }}
                                   {{ . }}
                               {{ else }}
                                   {{ $link.website }}
                               {{ end }}
                           </footer>
                       </div>
               
                       {{ if $link.image }}
                           {{ $image := $siteResources.Get (delimit (slice "link-img/" $link.image) "") | resources.Fingerprint "md5" }}
                           {{ $imageResized := $image.Resize "120x120" }}
                           <div class="article-image">
                               <img src="{{ $imageResized.RelPermalink }}" width="{{ $imageResized.Width }}" height="{{ $imageResized.Height }}"
                                   loading="lazy" data-key="links-{{ $link.website }}" data-hash="{{ $image.Data.Integrity }}">
                           </div>
                       {{ end }}
                   </a>
               </article>
           {{ end }}
       </div>
   
       {{ if or (not (isset .Params "comments")) (eq .Params.comments "true")}} 
           {{ partial "comments/include" . }}
       {{ end }}
   
       {{ partialCached "footer/footer" . }}
   
       {{ partialCached "article/components/photoswipe" . }}
   {{ end }}
   ```
   
2. 网站根目录新建文件`\layouts\shortcodes\link.html`：

   ```html
   {{$URL := .Get 0}}
   {{ with .Site.GetPage $URL }}
   <div class="post-preview">
     <div class="post-preview--meta" style="width:100%;">
       <div class="post-preview--middle">
         <h4 class="post-preview--title">
           <a target="_blank" href="{{ .Permalink }}">{{ .Title }}</a>
         </h4>
         <time class="post-preview--date">{{ .Date.Format ( default "2006-01-02") }}</time>
         {{ if .Params.tags }}
         <small>{{ range .Params.tags }}#{{ . }}&nbsp;{{ end }}</small>
         {{ end }}
         <section style="max-height:105px;overflow:hidden;" class="post-preview--excerpt">
           {{ .Summary | plainify}}
         </section>
       </div>
     </div>
   </div>
   {{ end }}
   ```
   
   3. `网站图像`放在网站根目录`\assets\link-img\`文件夹下。
   4. 网站根目录新建文件`\data\links.json`：
   
   ```json
   [
       {
           "title": "Upptime",
           "website": "https://iwyang.github.io/check",
           "image": "upptime.jpg",
   		"description": "利用Github Actions查看网站运行状态。"
       },
   	{
           "title": "ConstOwn",
           "website": "https://blog.juanertu.com",
           "image": "constown.jpg",
   		"description": "能与你一起成长，我荣幸之至。"
       },
       {
           "title": "小丁的个人博客",
           "website": "https://tding.top",
           "image": "ding.jpg",
   		"description": "世间所有的相遇，都是久别重逢。"
       },
       {
           "title": "Xu's Blog",
           "website": "https://hasaik.com",
           "image": "xu.jpg",
   		"description": "简单不先于复杂，而是在复杂之后。"
       },
       {
           "title": "知行志",
           "website": "https://baozi.fun",
           "image": "zhi.jpg",
   		"description": "Halo Theme Xue作者。"
       },
       {
           "title": "Takagi",
           "website": "https://lixingyong.com",
           "image": "takagi.jpg",
   		"description": "Takagi是啥呀？？当然是最喜欢的Takagi了吖ヾ(≧∇≦*)ゝ"
       },
       {
           "title": "千与千寻",
           "website": "https://www.chihiro.org.cn",
           "image": "qian.jpg",
   		"description": "所以，看不到光，算是不幸吗？需要光才是真正的不幸吧。"
       },
       {
           "title": "Bill Yang's Blog",
           "website": "https://blog.bill.moe",
           "image": "bill.jpg",
   		"description": "这辈子都不可能更新的 。"
       },
       {
           "title": "Sanarous's Blog",
           "website": "https://bestzuo.cn",
           "image": "sanarous.jpg",
   		"description": "Dream it possible, make it possible"
       },
   	    {
           "title": "JACK小桔子的小屋",
           "website": "https://jackxjz.top/",
           "image": "jack.jpg",
   		"description": "一个分享科技/日常的网站。"
       },
   	{
           "title": "若只如初见",
           "website": "https://joyli.net.cn/",
           "image": "ruo.jpg",
   		"description": "世间所有的相遇，都是久别重逢。"
       },
   		{
           "title": "大大的小蜗牛",
           "website": "https://eallion.com/",
           "image": "eallion.jpg",
   		"description": "机会总是垂青于有准备的人。"
       }
   ]
   ```

5.调整布局，设置友情链接为双栏：

修改根目录`/assets/scss/custom.scss`

```scss
//友情链接双栏
@media (min-width: 1024px) {
    .article-list--compact.links {
        display: grid;
        grid-template-columns: 1fr 1fr;
        background: none;
        box-shadow: none;
        
        article {
            background: var(--card-background);
            border: none;
            box-shadow: var(--shadow-l2);
            margin-bottom: 8px;
            border-radius: 10px;
            &:nth-child(odd) {
                margin-right: 8px;
            }
        }
    }
}
```

## 添加音乐短代码

1.网站根目录新建文件`layouts\shortcodes\music.html`

```html
{{- $scratch := .Page.Scratch.Get "scratch" -}}
<!-- require APlayer -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/aplayer/dist/APlayer.min.css">
<style type="text/css">.dark-theme .aplayer{background:#212121}.dark-theme .aplayer.aplayer-withlist .aplayer-info{border-bottom-color:#5c5c5c}.dark-theme .aplayer.aplayer-fixed .aplayer-list{border-color:#5c5c5c}.dark-theme .aplayer .aplayer-body{background-color:#212121}.dark-theme .aplayer .aplayer-info{border-top-color:#212121}.dark-theme .aplayer .aplayer-info .aplayer-music .aplayer-title{color:#fff}.dark-theme .aplayer .aplayer-info .aplayer-music .aplayer-author{color:#fff}.dark-theme .aplayer .aplayer-info .aplayer-controller .aplayer-time{color:#eee}.dark-theme .aplayer .aplayer-info .aplayer-controller .aplayer-time .aplayer-icon path{fill:#eee}.dark-theme .aplayer .aplayer-list{background-color:#212121}.dark-theme .aplayer .aplayer-list::-webkit-scrollbar-thumb{background-color:#999}.dark-theme .aplayer .aplayer-list::-webkit-scrollbar-thumb:hover{background-color:#bbb}.dark-theme .aplayer .aplayer-list li{color:#fff;border-top-color:#666}.dark-theme .aplayer .aplayer-list li:hover{background:#4e4e4e}.dark-theme .aplayer .aplayer-list li.aplayer-list-light{background:#6c6c6c}.dark-theme .aplayer .aplayer-list li .aplayer-list-index{color:#ddd}.dark-theme .aplayer .aplayer-list li .aplayer-list-author{color:#ddd}.dark-theme .aplayer .aplayer-lrc{text-shadow:-1px -1px 0 #666}.dark-theme .aplayer .aplayer-lrc:before{background:-moz-linear-gradient(top, #212121 0%, rgba(33,33,33,0) 100%);background:-webkit-linear-gradient(top, #212121 0%, rgba(33,33,33,0) 100%);background:linear-gradient(to bottom, #212121 0%, rgba(33,33,33,0) 100%);filter:progid:DXImageTransform.Microsoft.gradient( startColorstr='#212121', endColorstr='#00212121',GradientType=0 )}.dark-theme .aplayer .aplayer-lrc:after{background:-moz-linear-gradient(top, rgba(33,33,33,0) 0%, rgba(33,33,33,0.8) 100%);background:-webkit-linear-gradient(top, rgba(33,33,33,0) 0%, rgba(33,33,33,0.8) 100%);background:linear-gradient(to bottom, rgba(33,33,33,0) 0%, rgba(33,33,33,0.8) 100%);filter:progid:DXImageTransform.Microsoft.gradient( startColorstr='#00212121', endColorstr='#cc212121',GradientType=0 )}.dark-theme .aplayer .aplayer-lrc p{color:#fff}.dark-theme .aplayer .aplayer-miniswitcher{background:#484848}.dark-theme .aplayer .aplayer-miniswitcher .aplayer-icon path{fill:#eee}</style>
<script src="https://cdn.jsdelivr.net/npm/aplayer/dist/APlayer.min.js"></script>
<!-- require MetingJS -->
<script src="https://cdn.jsdelivr.net/npm/meting@2.0.1/dist/Meting.min.js"></script>

{{- if .IsNamedParams -}}
    {{- if .Get "url" -}}
        <meting-js url="{{ .Get `url` }}" name="{{ .Get `name` }}" artist="{{ .Get `artist` }}" cover="{{ .Get `cover` }}" theme="{{ .Get `theme` | default `#2980b9` }}"
        {{- with .Get "fixed" }} fixed="{{ . }}"{{ end -}}
        {{- with .Get "mini" }} mini="{{ . }}"{{ end -}}
        {{- with .Get "autoplay" }} autoplay="{{ . }}"{{ end -}}
        {{- with .Get "volume" }} volume="{{ . }}"{{ end -}}
        {{- with .Get "mutex" }} mutex="{{ . }}"{{ end -}}
        ></meting-js>
    {{- else if .Get "auto" -}}
        <meting-js auto="{{ .Get `auto` }}" theme="{{ .Get `theme` | default `#2980b9` }}"
        {{- with .Get "fixed" }} fixed="{{ . }}"{{ end -}}
        {{- with .Get "mini" }} mini="{{ . }}"{{ end -}}
        {{- with .Get "autoplay" }} autoplay="{{ . }}"{{ end -}}
        {{- with .Get "loop" }} loop="{{ . }}"{{ end -}}
        {{- with .Get "order" }} order="{{ . }}"{{ end -}}
        {{- with .Get "volume" }} volume="{{ . }}"{{ end -}}
        {{- with .Get "mutex" }} mutex="{{ . }}"{{ end -}}
        {{- with .Get "list-folded" }} list-folded="{{ . }}"{{ end -}}
        {{- with .Get "list-max-height" }} list-max-height="{{ . }}"{{ end -}}
        ></meting-js>
    {{- else -}}
        <meting-js server="{{ .Get `server` }}" type="{{ .Get `type` }}" id="{{ .Get `id` }}" theme="{{ .Get `theme` | default `#2980b9` }}"
        {{- with .Get "fixed" }} fixed="{{ . }}"{{ end -}}
        {{- with .Get "mini" }} mini="{{ . }}"{{ end -}}
        {{- with .Get "autoplay" }} autoplay="{{ . }}"{{ end -}}
        {{- with .Get "loop" }} loop="{{ . }}"{{ end -}}
        {{- with .Get "order" }} order="{{ . }}"{{ end -}}
        {{- with .Get "volume" }} volume="{{ . }}"{{ end -}}
        {{- with .Get "mutex" }} mutex="{{ . }}"{{ end -}}
        {{- with .Get "list-folded" }} list-folded="{{ . }}"{{ end -}}
        {{- with .Get "list-max-height" }} list-max-height="{{ . }}"{{ end -}}
        ></meting-js>
    {{- end -}}
{{- else if strings.HasSuffix (.Get 0) "http" -}}
    <meting-js auto="{{ .Get 0 }}" theme="#2980b9"></meting-js>
{{- else -}}
    <meting-js server="{{ .Get 0 }}" type="{{ .Get 1 }}" id="{{ .Get 2 }}" theme="#2980b9"></meting-js>
{{- end -}}
{{- $scratch.Set "music" true -}}
```

2.添加歌曲列表（注意：去掉注释/*  */）

```markdown
{{/* < music auto="https://music.163.com/#/playlist?id=60198"> */}}
```

3.添加单曲（注意：去掉注释/*  */）

```
{{/* < music server="netease" type="song" id="1868553" > */}}
或者
{{/* < music netease song 1868553 > */}}
```

4.其它参数

`music` shortcode 有一些可以应用于以上三种方式的其它命名参数:

- **autoplay** *[可选]*

  是否自动播放音乐, 默认值是 `false`.

## 更改分类、标签、页面显示中文

1. `content`目录下新建`categories\_index.md`:

```yaml
---
title: "分类"
---
```

2. `content`目录下新建`tags\_index.md`:

```yaml
---
title: "标签"
---
```

3. 根目录`\i18n\zh-CN.yaml`输入：

```yaml
list:
    page:
        one: "{{ .Count }} 页面"
        other: "{{ .Count }} 页面"
```

最终根目录`\i18n\zh-CN.yaml`

```yaml
list:
    page:
        one: "{{ .Count }} 页面"
        other: "{{ .Count }} 页面"

widget:
    categoriesCloud:
        title: 
            other: 分类
```

## 附：使用Git Submodule管理Hugo主题

+ 如果克隆库的时候要初始化子模块，请加上 `--recursive` 参数，如：

```bash
git clone -b develop git@github.com:iwyang/iwyang.github.io.git blog --recursive
```

+ 如果已经克隆了主库但没初始化子模块，则用：

```bash
git submodule update --init --recursive
```

+ 如果已经克隆并初始化子模块，而需要从子模块的源更新这个子模块，则：

```bash
git submodule update --recursive --remote
```

更新之后主库的 git 差异中会显示新的 SHA 码，把这个差异选中提交即可。

---

+ 其他命令：在主仓库更新所有子模块：`git submodule foreach git pull origin master`

## 附：hugo注释

```yaml
{{/* comment */}}
```

## 参考链接

+ [Hugo 主题 Stack文档](https://docs.stack.jimmycai.com/zh/)
+ [Adding the widget tag-cloud for "categories", on the right content region on Homepage](https://github.com/CaiJimmy/hugo-theme-stack/issues/169)
+ [vinceying/Vince-blog-https://i.vince.pub/](https://github.com/vinceying/Vince-blog)
+ [hugo音乐短代码](https://immmmm.com/hugo-shortcodes-music/)
+ [主题文档 - 扩展 Shortcodes-music](https://hugodoit.pages.dev/zh-cn/theme-documentation-extended-shortcodes/#8-music)
+ [Hugo模板的基本语法-注释](https://hugo.aiaide.com/post/hugo%E6%A8%A1%E6%9D%BF%E7%9A%84%E5%9F%BA%E6%9C%AC%E8%AF%AD%E6%B3%95/#%E6%B3%A8%E9%87%8A)
+ [Hugo | 第三篇 Stack 主题装修记录，堂堂再临！](https://mantyke.icu/2022/stack-theme-furnish03/)
+ [自动添加博客页面更新日期](https://blog.yfei.page/cn/2021/03/lastmod-hugo/)

+ [Hugo | 看中 Stack 主题的归档功能，搬家并做修改](https://mantyke.icu/2021/f9f0ec87/)

+ [hugo github action|vecel 部署后文章更新时间异常修复](https://kingpo.vercel.app/posts/202208/hugo-github-action%E5%92%8Cvecel%E9%83%A8%E7%BD%B2%E5%90%8E%E6%96%87%E7%AB%A0%E6%9B%B4%E6%96%B0%E6%97%B6%E9%97%B4%E5%BC%82%E5%B8%B8%E4%BF%AE%E5%A4%8D/#)