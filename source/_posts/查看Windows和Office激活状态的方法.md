---
title: 查看Windows和Office激活状态的方法
categories:
  - 技术
tags:
  - win10
comments: true
abbrlink: 23a66736
date: 2022-03-13 20:21:47
sticky:
keywords:
description:
top_img:
cover:
typora-root-url: ..
---

##  win10

使用命令查看Windows 10激活状态：

当然，对于系统管理员来说，最传统的方式就是使用命令行的方式来查看系统激活状态。管理员只需按下 Windows + R 快捷键 — 输入并执行 CMD 打开命令提示符。

输入并执行如下命令：

```
slmgr /xpr
```

## Office

命令行查看office激活期限：

 1、首先找到office安装目录，我的是C:\Program Files\Microsoft Office\Office16
 （咱也不知道为啥显示16，装的是19，其实感觉功能也差不多，先不管它）
 2、打开终端：win+R
 3、输入：cmd
 4、输入：cd C:\Program Files\Microsoft Office\Office16
 5、按回车
 6、输入：cscript ospp.vbs /dstatus
 7、显示

![](../img/%E6%9F%A5%E7%9C%8BWindows%E5%92%8COffice%E6%BF%80%E6%B4%BB%E7%8A%B6%E6%80%81%E7%9A%84%E6%96%B9%E6%B3%95/202203132026632.png)

可以看到还剩179天到期，到期可以再jh。

## 参考链接

+ [如何查看Windows 10激活状态的几种方式](https://www.office26.com/windows/check-windows-10-active-status.html)

+ [命令行查看office激活期限](https://blog.csdn.net/qq_36659185/article/details/105184356?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~aggregatepage~first_rank_ecpm_v1~rank_v31_ecpm-1-105184356.pc_agg_new_rank&utm_term=office%E6%BF%80%E6%B4%BB%E6%9F%A5%E7%9C%8B&spm=1000.2123.3001.4430)

  

