---
title: "KOReader 2026 07 升级指令"
slug: "954bf940"
description: ""
date: 2026-07-28T18:33:44+08:00
lastmod: 2026-07-28T18:33:44+08:00
draft: false
toc: true
weight: false
image: ""
categories: [""]
shuoshuotags: ["技术"]
---

KOReader 2026.07 升级指令 
  ```bash
  # 1. 进入下载目录
  mkdir -p ~/Downloads
  cd ~/Downloads
  
  # 2. 下载最新的 2026.07 安装包
  wget https://github.com/iwyang/backup/releases/download/koreader-v2026.07/koreader_2026.07-1_amd64.deb
  
  # 3. 赋予读取权限 (习惯性动作，防止 sudo 模式下权限受阻)
  sudo chmod 644 ./koreader_2026.07-1_amd64.deb
  
  # 4. 执行升级安装
  # apt 会自动识别这是新版本并进行替换
  sudo dpkg -i /home/yang/Downloads/koreader_2026.07-1_amd64.deb
  
  # 5. (可选) 清理安装包以节省空间
  rm ./koreader_2026.07-1_amd64.deb
  ```

