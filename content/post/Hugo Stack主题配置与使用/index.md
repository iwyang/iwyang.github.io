---
title: Hugo Stack主题配置与使用
categories:
  - 技术
tags:
  - hugo
slug: 3bf3725e
date: 2021-07-24 01:15:26
cover: false
---

##   修改文件名

遍历当前目录下的所有 `.md` 文件，为每个文件创建一个同名文件夹，并将文件移动进去重命名为 `index.md`

您可以将以下代码保存为 `batch_convert.sh`

```bash
#!/bin/bash

# 遍历当前目录下所有的 .md 文件
for file in *.md; do
    # 检查文件是否存在（防止没有 md 文件时报错）
    [ -e "$file" ] || continue

    # 1. 获取文件名（不带扩展名），例如将 "A.md" 转换为 "A"
    dir_name="${file%.*}"

    # 排除 index.md 自身（防止递归处理或错误创建 index 文件夹）
    if [ "$dir_name" == "index" ]; then
        continue
    fi

    # 2. 创建同名文件夹（如果文件夹已存在也不会报错）
    mkdir -p "$dir_name"

    # 3. 将文件复制到文件夹中并重命名为 index.md
    # 这步操作等同于：先复制进去，再改名
    mv "$file" "$dir_name/index.md"

    echo "已处理: $file -> $dir_name/index.md"
done
```

又换主题了，这回使用的是[hugo-theme-stack](https://github.com/CaiJimmy/hugo-theme-stack)，无意发现这款主题，正合我意，够简单，最重要的是支持本地搜索，再不用弄哪个`Alogia`了。

## 下载主题&更新主题

1. 下载主题

```bash
git init
git submodule add https://github.com/iwyang/hugo-theme-stack/ themes/hugo-theme-stack
```

2. 更新主题

```bash
git submodule update --remote
```

3. Git 子模块（Submodule）更新冲突

如果更新主题，出现冲突。

#### 第一步：进入主题文件夹

在终端（或你那个脚本所在的目录）运行：

```bash
cd themes/hugo-theme-stack
```

#### 第二步：处理冲突

如果你想放弃本地修改（最简单）** 如果你觉得这些修改不重要，或者想重新开始：

```bash
# 强制重置所有已追踪的文件
git reset --hard HEAD

# 删除所有未追踪的文件和文件夹
git clean -fd
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

## ~~显示右侧工具栏分类目录~~

~~参考 https://github.com/CaiJimmy/hugo-theme-stack/issues/169~~

> 最新版主题已默认开启分类目录工具栏

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

请在你的 `article.scss` 文件中找到 `.related-content` 这一块（大约在文件中间偏下的位置），将它**完全替换**为以下代码：

```scss
.related-content {
    overflow-x: auto;
    padding-bottom: 15px;

    &>.flex {
        float: left;
    }

    article {
        margin-right: 15px;
        flex-shrink: 0;
        overflow: hidden;
        width: 250px;
        
        /* 1. 将原本的 height: 150px 改为自适应，消除大片空白 */
        height: auto;
        min-height: 80px; /* 设置一个舒适的最小高度 */

        /* 2. 彻底隐藏图片容器 */
        .article-image {
            display: none !important;
        }

        /* 3. 新增详情区域样式：让文字在卡片中垂直/水平居中 */
        .article-details {
            padding: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 80px;
            box-sizing: border-box;
        }

        .article-title {
            font-size: 1.6rem; /* 稍微缩小一点字号显得更精致 */
            margin: 0;
            text-align: center; /* 文字居中对齐 */
            color: var(--card-text-color-main) !important; /* 强制文字显示为主题的正常颜色 */
        }

        /* 4. 移除带图片时附带的黑色半透明渐变遮罩 */
        &.has-image {
            .article-details {
                background: transparent;
            }
        }
    }
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

### 网易音乐

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

### 本地音乐

1.新建layouts/_shortcodes/audio.html

```
{{- $name := .Get 0 -}}
{{- $title := .Get "title" | default $name -}}

{{/* 核心：尝试从当前文章资源中匹配该文件 */}}
{{- $audio := .Page.Resources.GetMatch $name -}}
{{- $src := "" -}}

{{- if $audio -}}
    {{- $src = $audio.RelPermalink -}}
{{- else -}}
    {{/* 如果找不到，则视为 static 目录下的绝对路径 */}}
    {{- $src = $name | safeURL -}}
{{- end -}}

<div class="local-audio-wrapper" style="margin: 20px 0; background: var(--card-background); padding: 15px; border-radius: var(--card-border-radius); box-shadow: var(--shadow-l2);">
    <div class="audio-title" style="font-size: 14px; color: var(--card-text-color-main); margin-bottom: 10px; font-weight: bold; display: flex; align-items: center; gap: 8px;">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13"></path><circle cx="6" cy="18" r="3"></circle><circle cx="18" cy="16" r="3"></circle></svg>
        <span>{{ $title }}</span>
    </div>
    <audio controls preload="metadata" style="width: 100%; height: 40px;">
        <source src="{{ $src }}" type="audio/mpeg">
        </audio>
</div>
```

2.使用方法

+ 基础用法（自动匹配文件名）：
  ```markdown
  {{< audio "hefeng.mp3" >}}
  ```

+ 进阶用法（自定义显示标题）：

  ```markdown
  {{< audio src="hefeng.mp3" title="我的收藏 - 和风物语" >}}
  ```

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

## hugo添加说说

添加说说：https://github.com/iwyang/iwyang.github.io/blob/develop/layouts/shuoshuo/list.html

首页轮播：https://github.com/iwyang/iwyang.github.io/blob/develop/layouts/home.html

CSS：https://github.com/iwyang/iwyang.github.io/blob/develop/assets/scss/custom.scss

这份“终极保姆级手册”已经非常完善了！结合我们最后确认的**“Token 常量化安全方案”**以及**“区分变量类型”**的细节，我为你对第二步和第三步进行了优化修改。

这样修改后，既保证了你以后操作不用每次都粘贴 Token，又防止了 `DIR_NAME` 错误弹出输入框，彻底实现了“一劳永逸”。

以下是为你修改和升级后的**“安卓发布说说终极版执行手册”**，你可以直接把这份文档存进你的博客或者备忘录里：

---

## 安卓一键发布 Hugo 说说 (HTTP Shortcuts 终极版)

经历了乱码、路径报错和 Token 安全问题，这份手册将所有经验融会贯通，制定了**“绝对避坑、零报错、完美中文显示、Token高安全”**的终极执行方案。

请清空之前的设置（或者新建一个快捷方式），我们从零开始，一步步拿下它！

---

### 🚨 第一步：获取全新的 GitHub Token（安全第一）

为了你的仓库安全，避免明文泄露，**请务必先做这一步**：

1. 登录 GitHub ➔ `Settings` ➔ `Developer settings` ➔ `Personal access tokens (classic)`。
2. 找到旧的 Token（如果有暴露过），点击 **Delete** 彻底删除。
3. 点击 **Generate new token (classic)**，勾选 **`repo`** 权限，生成一个新的。
4. **复制新 Token**，保存在手机备忘录里备用，千万不要在截图或视频中发出来。

---

### 🛠️ 第二步：建立 6 个变量（分类建立，杜绝乱码与泄露）

打开 HTTP Shortcuts App，点击底部中间的 **`{ }`** 图标。我们需要分三种类型建立 6 个变量。

#### 1. 创建5 个“输入文本 (Input Text)”变量

依次点击 `+` ➔ 选择 **输入文本**，创建以下三个：

* **变量 1** ➔ **名称**：`INPUT_FILENAME` | **对话框标题**：`1. 请输入文件名`
* ⚠️ **避坑关键**：在“高级设置”中，**绝对不要勾选“JSON 编码”**！


* **变量 2** ➔ **名称**：`INPUT_TAGS` | **对话框标题**：`2. 输入标签 (逗号隔开)`
* ⚠️ **避坑关键**：**不要勾选“JSON 编码”**！


* **变量 3** ➔ **名称**：`INPUT_CONTENT` | **对话框标题**：`3. 记录此刻的闪念...`
* ⚠️ **避坑关键**：**务必勾选“多行”**；**不要勾选“JSON 编码”**！

* **变量 4** ➔ **名称**：`DIR_NAME` 
* ⚠️ **避坑关键**：**不要勾选“JSON 编码”**！

* **变量 5** ➔ **名称**：`BASE64_CONTENT` 
* ⚠️ **避坑关键**：**务必勾选“多行”**；**不要勾选“JSON 编码”**！

#### 2. 创建 1 个“常量 (Constant)”（保护 Token 安全）

回到变量列表，点击 `+` ➔ 选择 **常量**：

* **变量 6** ➔ **名称**：`MY_GITHUB_TOKEN`
* **值 (Value)**：直接粘贴你刚才生成的 `ghp_` 开头的新 Token。(记得勾选`将值视为密文`)
* *（这样以后无论你怎么截图分享配置，Token 都被隐藏在这个变量里了，极度安全且不用每次手动输入）*

---

### 🚀 第三步：配置快捷方式（核心组装）

回到 App 首页，点击 `+` ➔ **新建快捷方式**。

#### 1. 植入终极查表法脚本

点击 **脚本编写** ➔ **在执行前运行 JavaScript**，**完整粘贴**这段“手动挡”无敌代码（完全不依赖系统内置函数，彻底告别中文乱码）：

```javascript
const nameInput = getVariable('INPUT_FILENAME');
const tagsInput = getVariable('INPUT_TAGS');
const contentInput = getVariable('INPUT_CONTENT');

let tagLine = '""';
if (tagsInput) {
    const tags = tagsInput.split(/[,，]/).map(t => `"${t.trim()}"`).filter(t => t !== '""');
    if (tags.length > 0) tagLine = tags.join(', ');
}

const now = new Date();
const isoTime = new Date(now.getTime() + 8*60*60000).toISOString().replace("Z", "+08:00");
const dir = nameInput ? nameInput.trim() : ("bb-" + now.getTime());
const slug = Math.random().toString(36).substring(2, 10);

const fm = [
    "---",
    `title: "${dir}"`,
    `slug: "${slug}"`,
    'description: ""',
    `date: ${isoTime}`,
    `lastmod: ${isoTime}`,
    "draft: false",
    "toc: true",
    "weight: false",
    'image: ""',
    'categories: [""]',
    `shuoshuotags: [${tagLine}]`,
    "---",
    contentInput
].join('\n');

// 完全手动实现 UTF-8 + Base64，不依赖任何内置函数
function encodeBase64UTF8(str) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    // 第一步：字符串转 UTF-8 字节数组
    const bytes = [];
    for (let i = 0; i < str.length; i++) {
        let code = str.charCodeAt(i);
        // 处理 emoji 等4字节字符（代理对）
        if (code >= 0xD800 && code <= 0xDBFF) {
            const hi = code;
            const lo = str.charCodeAt(++i);
            code = ((hi - 0xD800) << 10) + (lo - 0xDC00) + 0x10000;
        }
        if (code < 0x80) {
            bytes.push(code);
        } else if (code < 0x800) {
            bytes.push(0xC0 | (code >> 6));
            bytes.push(0x80 | (code & 0x3F));
        } else if (code < 0x10000) {
            bytes.push(0xE0 | (code >> 12));
            bytes.push(0x80 | ((code >> 6) & 0x3F));
            bytes.push(0x80 | (code & 0x3F));
        } else {
            bytes.push(0xF0 | (code >> 18));
            bytes.push(0x80 | ((code >> 12) & 0x3F));
            bytes.push(0x80 | ((code >> 6) & 0x3F));
            bytes.push(0x80 | (code & 0x3F));
        }
    }
    // 第二步：字节数组转 Base64
    let result = '';
    for (let i = 0; i < bytes.length; i += 3) {
        const b0 = bytes[i], b1 = bytes[i+1] || 0, b2 = bytes[i+2] || 0;
        result += chars[b0 >> 2];
        result += chars[((b0 & 3) << 4) | (b1 >> 4)];
        result += i+1 < bytes.length ? chars[((b1 & 15) << 2) | (b2 >> 6)] : '=';
        result += i+2 < bytes.length ? chars[b2 & 63] : '=';
    }
    return result;
}

setVariable('DIR_NAME', dir);
setVariable('BASE64_CONTENT', encodeBase64UTF8(fm));
```

#### 2. 配置无错 URL（基本设置）

点击 **基本设置**：

* **方法**：改成 **`PUT`**。
* **URL**：手动输入 `https://api.github.com/repos/iwyang/iwyang.github.io/contents/content/shuoshuo/`。
* ⚠️ **避坑关键**：输入到这里时，**点击键盘上方的 `{ }` 按钮**，从列表里选择 `DIR_NAME`，然后再接着输入 `/index.md`。
* 最终看起来应该是：`.../shuoshuo/{DIR_NAME}/index.md`（确保 `{DIR_NAME}` 是被识别的高亮变量块，绝不能是手动敲打的 `%7B...`）。

#### 3. 配置认证（请求头 - 安全升级版）

点击 **请求头** ➔ 点击 **+**：

* **第一行** ➔ 键：`Authorization` | 值：输入 `Bearer `（注意后面有一个空格），然后点击右侧的 **`{ }` 按钮**，选择你刚刚创建的常量变量 **`MY_GITHUB_TOKEN`**。
* *最终效果：`Bearer {MY_GITHUB_TOKEN}*`


* **第二行** ➔ 键：`Accept` | 值：`application/vnd.github.v3+json`。

#### 4. 配置防 422 报错（请求体）

点击 **请求体/请求参数**：

* **类型**：选择 **自定义类型**。
* **内容类型**：填入 `application/json`。
* **正文**：严格按照下面的格式敲。输入 `{BASE64_CONTENT}` 时，**务必点击右侧的 `{ }` 按钮插入**，不能手动打大括号！

```json
{
  "message": "feat: 新增说说 via Android",
  "content": "{BASE64_CONTENT}"
}

```

---

### 🎉 第四步：保存与终极测试

1. 点击右上角的 **✔** 确认保存。
2. 将这个快捷方式添加到桌面。
3. 点击运行测试：
* 框1填：`测试终极版`
* 框2填：`成功, 完结撒花`
* 框3填：`这段查表法 Base64 代码太牛了，彻底告别乱码！😎`


4. 如果你看到手机底部弹出执行成功（或状态码 `201`），恭喜你！去你的博客上刷新看看吧：完美的中文显示、完美的 Page Bundle 目录结构、极度安全的 Token 隔离，全部搞定！

## 说说加入系统搜索

### 修改`params.toml`

```toml
mainSections = ["post","shuoshuo"]
```

### 首页、归档隐藏说说

1.修改`blog/layouts/partials/helper/pages.html`

`search.json` 和 `home.html` 都调用了 `partial "helper/pages.html"`，这个 partial 才是真正控制页面列表的地方

```html
{{- $pages := .Pages -}}

{{- if .IsHome -}}
    {{- $pages = where .Site.RegularPages "Type" "in" .Site.Params.mainSections -}}
    {{- $pages = where $pages "Section" "!=" "shuoshuo" -}}
{{- else if or (eq .Kind "section") (eq .Kind "taxonomy") (eq .Kind "term") -}}
    {{- $subsections := .Sections -}}
    {{- $pages = .Pages | complement $subsections -}}

    {{- if eq (len $pages) 0 -}}
        {{- $pages = $subsections -}}
    {{- end -}}
{{- end -}}

{{- $pages := partial "helper/pages-sort.html" (dict "Pages" $pages "Context" .) -}}

{{- return $pages -}}
```

2.修改`\blog\layouts\page\search.json`，**不走 `helper/pages.html`，直接自己取 mainSections 的全量内容**：

```json
{{- $pages := where .Site.RegularPages "Type" "in" .Site.Params.mainSections -}}
{{- $result := slice -}}

{{- range $pages -}}
    {{- $title := .Title -}}
    {{- $permalink := .RelPermalink -}}
    {{- $type := "article" -}}

    {{- if eq .Section "shuoshuo" -}}
        {{- $type = "shuoshuo" -}}
        {{- if .Title -}}
            {{- $title = print "💬 " .Title -}}
        {{- else -}}
            {{- $title = print "💬 " (.Plain | truncate 15) -}}
        {{- end -}}
    {{- end -}}

    {{- $data := dict "title" $title "date" .Date "permalink" $permalink "content" (.Plain) "type" $type -}}

    {{- $image := partial "helper/image" (dict "Image" .Params.image "Resources" .Resources) -}}
    {{- if $image -}}
        {{- $data = merge $data (dict "image" $image.Permalink) -}}
    {{- end -}}

    {{- $result = $result | append $data -}}
{{- end -}}

{{ jsonify $result }}
```

### 搜索结果分类

1.修改`\blog\layouts\page\search.json`

```json
{{- $pages := where .Site.RegularPages "Type" "in" .Site.Params.mainSections -}}
{{- $result := slice -}}

{{- range $pages -}}
    {{- $title := .Title -}}
    {{- $permalink := .RelPermalink -}}
    {{- $type := "article" -}}

    {{- if eq .Section "shuoshuo" -}}
        {{- $type = "shuoshuo" -}}
        {{- if .Title -}}
            {{- $title = print "💬 " .Title -}}
        {{- else -}}
            {{- $title = print "💬 " (.Plain | truncate 15) -}}
        {{- end -}}
    {{- end -}}

    {{- $data := dict "title" $title "date" .Date "permalink" $permalink "content" (.Plain) "type" $type -}}

    {{- $image := partial "helper/image" (dict "Image" .Params.image "Resources" .Resources) -}}
    {{- if $image -}}
        {{- $data = merge $data (dict "image" $image.Permalink) -}}
    {{- end -}}

    {{- $result = $result | append $data -}}
{{- end -}}

{{ jsonify $result }}
```

2.修改`layouts/partials/footer/custom.html`

```html
{{- /* 使用变量包裹 JS 代码，彻底避免 Hugo 模板引擎报错 */ -}}
{{- $js := `
document.addEventListener("DOMContentLoaded", () => {
    const listSelector = ".search-result--list";
    const itemSelector = "article";
    const nativeTitleSelector = ".search-result--title"; 
    const searchInputSelector = ".search-form input"; 

    // 🌟 1. 注入样式
    const style = document.createElement("style");
    style.textContent = ".bore-custom-header { display: flex; align-items: center !important; flex-wrap: wrap !important; gap: 15px !important; margin-bottom: 24px !important; padding-bottom: 8px !important; border-bottom: 1px dashed rgba(128, 128, 128, 0.15); min-height: 42px; }" +
        ".bore-hidden { display: none !important; }" + 
        /* 🌟🌟🌟 修改点 1：彻底隐藏左侧纯文字统计 */
        ".bore-search-stats { display: none !important; }" + 
        /* 🌟🌟🌟 修改点 2：margin-left 改为 0，让选项卡靠左对齐 */
        ".search-filter-tabs { --tab-bg: #ffffff; --tab-border: #e2e8f0; --tab-text: #64748b; --tab-active-bg: #1e90ff; --tab-active-text: #ffffff; --count-bg: #f1f5f9; --count-text: #64748b; --count-active-bg: #ffffff; --count-active-text: #1e90ff; display: flex; align-items: center; gap: 10px; margin-left: 0; }" +
        '[data-scheme="dark"] .search-filter-tabs { --tab-bg: rgba(255, 255, 255, 0.04); --tab-border: rgba(255, 255, 255, 0.15); --tab-text: #a1a1aa; --tab-active-bg: #1e90ff; --tab-active-text: #ffffff; --count-bg: rgba(255, 255, 255, 0.12); --count-text: #e4e4e7; --count-active-bg: #ffffff; --count-active-text: #1e90ff; }' +
        ".filter-tab { cursor: pointer; padding: 5px 12px 5px 16px; border-radius: 50px; font-size: 1.35rem; font-weight: 500; color: var(--tab-text); background: var(--tab-bg); border: 1px solid var(--tab-border); transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1); display: inline-flex; align-items: center; gap: 8px; user-select: none; line-height: 1.2; }" +
        ".filter-tab:hover { border-color: #1e90ff; color: #1e90ff; background: rgba(30, 144, 255, 0.05); }" +
        ".filter-tab:active { transform: scale(0.96); opacity: 0.8; }" +
        ".filter-tab.active { background: var(--tab-active-bg); border-color: var(--tab-active-bg); color: var(--tab-active-text); font-weight: 600; box-shadow: 0 4px 12px rgba(30, 144, 255, 0.3); pointer-events: none; }" +
        ".filter-count { font-size: 1.15rem; padding: 3px 8px; border-radius: 50px; background: var(--count-bg); color: var(--count-text); font-weight: 600; min-width: 24px; text-align: center; }" +
        ".filter-tab.active .filter-count { background: var(--count-active-bg); color: var(--count-active-text); }" +
        ".bore-search-empty-state { grid-column: 1 / -1; width: 100%; min-height: 40vh; display: flex; flex-direction: column; align-items: center; justify-content: center; animation: fadeIn 0.4s ease; }" +
        ".bore-search-empty-icon-wrapper { color: var(--body-text-color); opacity: 0.4; transition: all 0.3s ease; margin-bottom: 24px; }" +
        '[data-scheme="dark"] .bore-search-empty-icon-wrapper { color: #ffffff !important; opacity: 0.75 !important; }' +
        ".bore-search-empty-icon { width: 80px; height: 80px; stroke-width: 1.2; }" +
        ".bore-search-empty-text { font-size: 1.6rem; font-weight: 500; color: var(--body-text-color); opacity: 0.8; letter-spacing: 0.5px; }" +
        "@keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }" +
        ".search-result--title { display: none !important; }"; // 彻底隐藏原版标题
    document.head.appendChild(style);

    let currentFilter = sessionStorage.getItem("bore-search-filter") || "all";
    let layoutTimer;
    let isObserving = false;
    
    // 防卡死监听器
    const observer = new MutationObserver(() => {
        clearTimeout(layoutTimer);
        layoutTimer = setTimeout(() => { safelyUpdateDOM(); }, 20); 
    });

    const startObserve = () => {
        if (isObserving) return;
        const wrapper = document.querySelector(".search-wrapper") || document.body;
        if (wrapper) {
            observer.observe(wrapper, { childList: true, subtree: true });
            isObserving = true;
        }
    };

    const stopObserve = () => {
        if (!isObserving) return;
        observer.disconnect();
        isObserving = false;
    };

    function safelyUpdateDOM() {
        stopObserve();
        updateDOM();
        startObserve();
    }

    // 监听打字/退格，实时重置分类
    const searchInput = document.querySelector(searchInputSelector);
    if (searchInput) {
        searchInput.addEventListener("input", () => {
            if (currentFilter !== "all") {
                currentFilter = "all";
                sessionStorage.setItem("bore-search-filter", "all");
                stopObserve();
                const tabs = document.querySelector(".search-filter-tabs");
                if (tabs) {
                    tabs.querySelectorAll(".filter-tab").forEach(t => t.classList.remove("active"));
                    const allTab = tabs.querySelector("[data-type='all']");
                    if (allTab) allTab.classList.add("active");
                }
                updateDisplayOnly();
                startObserve();
            }
        });
    }

    // 解决后退缓存卡死
    window.addEventListener("pageshow", (e) => {
        if (e.persisted) {
            currentFilter = sessionStorage.getItem("bore-search-filter") || "all";
            safelyUpdateDOM();
        }
    });

    startObserve();

    function updateDOM() {
        const nativeTitle = document.querySelector(nativeTitleSelector);
        const list = document.querySelector(".search-result--list");
        if (!nativeTitle || !searchInput || !list) return;

        const isInputEmpty = searchInput.value.trim() === "";
        let customHeader = document.querySelector(".bore-custom-header");

        if (!customHeader && !isInputEmpty) {
            customHeader = document.createElement("div");
            customHeader.className = "bore-custom-header bore-hidden"; 
            const stats = document.createElement("div");
            stats.className = "bore-search-stats";
            const tabs = document.createElement("div");
            tabs.className = "search-filter-tabs";
            
            const tabData = [
                { type: "all", label: "全部", id: "count-all" },
                { type: "article", label: "文章", id: "count-article" },
                { type: "shuoshuo", label: "说说", id: "count-shuoshuo" }
            ];
            
            tabs.innerHTML = tabData.map(t => {
                const isActive = t.type === currentFilter ? " active" : "";
                return '<div class="filter-tab' + isActive + '" data-type="' + t.type + '">' + t.label + ' <span class="filter-count" id="' + t.id + '">0</span></div>';
            }).join("");

            customHeader.appendChild(stats);
            customHeader.appendChild(tabs);
            list.parentNode.insertBefore(customHeader, list);

            tabs.querySelectorAll(".filter-tab").forEach(tab => {
                tab.addEventListener("click", (e) => {
                    e.stopPropagation();
                    if (currentFilter === e.currentTarget.dataset.type) return; 
                    stopObserve();
                    tabs.querySelectorAll(".filter-tab").forEach(t => t.classList.remove("active"));
                    e.currentTarget.classList.add("active");
                    currentFilter = e.currentTarget.dataset.type;
                    sessionStorage.setItem("bore-search-filter", currentFilter);
                    updateDisplayOnly(list);
                    startObserve();
                });
            });
        }

        if (customHeader) {
            const stats = customHeader.querySelector(".bore-search-stats");
            if (stats && nativeTitle.textContent) {
                const cleanTitle = nativeTitle.innerHTML.split("（")[0].split("(")[0].trim();
                if (stats.innerHTML !== cleanTitle) {
                    stats.innerHTML = cleanTitle;
                }
            }
            
            const articleCount = list.querySelectorAll(itemSelector).length;
            const shouldHide = isInputEmpty || articleCount === 0;
            
            if (shouldHide) {
                customHeader.classList.add("bore-hidden");
            } else {
                customHeader.classList.remove("bore-hidden");
            }
        }
        updateDisplayOnly(list);
    }

    function updateDisplayOnly(listElement) {
        const list = listElement || document.querySelector(".search-result--list");
        if (!list) return;

        const items = list.querySelectorAll("article");
        let cAll = 0, cArt = 0, cShuo = 0;

        items.forEach(item => {
            const artTitle = item.querySelector(".article-title");
            if (!artTitle) return;
            const isShuo = artTitle.textContent.includes("💬");
            cAll++;
            if (isShuo) cShuo++; else cArt++;
            let targetDisp = "";
            if (currentFilter === "article") targetDisp = isShuo ? "none" : "";
            else if (currentFilter === "shuoshuo") targetDisp = isShuo ? "" : "none";
            if (item.style.display !== targetDisp) item.style.display = targetDisp;
        });

        const setTxt = (id, num) => { 
            const el = document.getElementById(id); 
            if (el && el.textContent !== String(num)) el.textContent = String(num); 
        };
        setTxt("count-all", cAll); setTxt("count-article", cArt); setTxt("count-shuoshuo", cShuo);

        let emptyDiv = document.querySelector(".bore-search-empty-state");
        const isInputEmpty = document.querySelector(searchInputSelector)?.value.trim() === "";
        
        let shouldShowEmpty = false;
        if (!isInputEmpty && cAll > 0) {
            if (currentFilter === "article" && cArt === 0) shouldShowEmpty = true;
            if (currentFilter === "shuoshuo" && cShuo === 0) shouldShowEmpty = true;
        }

        if (shouldShowEmpty) {
            if (!emptyDiv) {
                emptyDiv = document.createElement("div");
                emptyDiv.className = "bore-search-empty-state";
                emptyDiv.innerHTML = '<div class="bore-search-empty-icon-wrapper"><svg class="bore-search-empty-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line><line x1="8" y1="11" x2="14" y2="11"></line></svg></div><div class="bore-search-empty-text">该分类下暂无匹配内容</div>';
                list.appendChild(emptyDiv);
            }
        } else if (emptyDiv) {
            emptyDiv.remove();
        }
    }
});
` -}}

<script>
    {{ $js | safeJS }}
</script>
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