---
title: "Epub修改标题"
slug: "580dbb64"
description: ""
date: 2026-03-10T20:51:25+08:00
lastmod: 2026-03-10T20:51:25+08:00
draft: false
toc: true
weight: false
image: ""
categories: [""]
shuoshuotags: ["技术"]
---

  epub修改标题的方法。EPUB 本质上是一个 ZIP 压缩包：

1. 将 `.epub` 后缀改为 `.zip` 并解压。
2. 进入解压后的文件夹，找到 **`content.opf`** 文件（通常在 `OEBPS` 或 `EPUB` 目录下）。
3. 用文本编辑器打开它，找到 `<dc:title>` 标签。
   + 你会看到类似：`<dc:title>剑来（1-54册）完结精校版</dc:title>`
4. 直接改成：**`<dc:title>剑来</dc:title>`**，保存。
5. 全选所有文件，重新压缩回 `.zip` 格式，最后把后缀改回 `.epub`。
