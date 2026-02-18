---
title: 解决网页视频播放器进度条禁止拖动
categories:
  - 技术
tags:
  - tips
comments: true
cover: /img/cover/potplayer.jpg
slug: 82f1bd2
date: 2022-08-08 13:09:22
sticky:
keywords:
description:
top_img:
---

> 本文转自：https://blog.csdn.net/weixin_46435234/article/details/114437203

1.点击键盘F12键，进入开发者模式

2.发现标志,html5播放器，属于原生支持最方便实现加速的

3.在开发者模式中找到Console 调式窗口，输入以下代码 可以设置视频播放速度

```bash
/* play video twice as fast */
document.

querySelector('video').defaultPlaybackRate = 1.0;//默认一倍速播放
document.querySele

ctor('video').play();

/* now play three times as fast just for the heck of it */

document.querySelector('video').playbackRate = 10.0;  //修改此值设置当前的播放倍数
```

4.直接跳过视频：

```bash
function skip() {
    
    let video = document.getElementsByTagName('video')
    for (let i=0; i<video.length; i++) {
    
        video[i].currentTime = video[i].duration
    }
}
setInterval(skip,200)
```

