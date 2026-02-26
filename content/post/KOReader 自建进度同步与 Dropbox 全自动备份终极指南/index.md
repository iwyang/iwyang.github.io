---
title: "KOReader 自建进度同步与 Dropbox 全自动备份终极指南"
slug: "f2d557e4"
description: ""
date: 2026-02-26T22:57:28+08:00
lastmod: 2026-02-26T22:57:28+08:00
draft: false
toc: true
weight: false
image: ""
categories: ["技术"]
tags: ["linux"]
---
对于多设备（手机、平板）阅读的硬核书友而言，将阅读进度掌握在自己手里是最安心的。本教程将带你在 VPS（如 RackNerd）上使用 Docker 部署私有进度同步服务，并利用 Rclone 实现每天全自动备份到 Dropbox（且云端永远只保留最新的一份压缩包，不占空间）。

---

## 第一部分：服务端部署 (Docker 同步中心)

为了避免端口冲突，我们为同步服务分配 `3002` 端口。

### 1. 创建目录与配置文件

在服务器终端依次运行以下命令，建立工作区：

```bash
mkdir -p ~/docker/book && cd ~/docker/book
vi docker-compose.yml

```

将以下完整配置粘贴进去（按 `Ctrl+O` 保存，`Ctrl+X` 退出）：

```yaml
services:
  # KOReader 进度同步服务器
  kosync:
    image: ghcr.io/nperez0111/koreader-sync:latest
    container_name: kosync
    ports:
      - "3002:3000"
    volumes:
      - ./kosync_data:/app/data
    restart: unless-stopped 

  # Watchtower 自动更新工具 (保持镜像永远最新)
  watchtower:
    image: containrrr/watchtower
    container_name: book-watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 86400
    restart: unless-stopped

```

### 2. 修复数据库权限并启动（关键避坑）

因为 KOReader 同步服务器内部使用 SQLite 数据库，Docker 默认创建的目录权限会导致数据库无法写入。必须手动放开权限：

```bash
# 手动创建数据文件夹
mkdir -p ~/docker/book/kosync_data
# 赋予最高读写权限，解决 SQLite 报错
sudo chmod -R 777 ~/docker/book/kosync_data

# 后台启动服务
docker-compose up -d

```

---

## 第二部分：客户端配置 (KOReader 连通)

**⚠️ 核心注意点：** 很多新手找不到“进度同步”的设置入口，是因为在 KOReader 的“文件浏览器”界面是隐藏该菜单的。**你必须先随便打开一本小说（如 EPUB 或 TXT）进入阅读界面！**

1. **打开小说并激活插件**：
* 随便打开一本书。
* 点击屏幕上方呼出菜单，点击最右侧的 **“扳手/螺丝刀”图标 (工具)** -> **“插件管理”**。
* 勾选并激活 **“进度同步 (Progress sync)”**。


2. **进入同步设置**：
* 保持在阅读界面，点击顶部菜单的 **“扳手”图标 (设置)**。
* 在弹出的列表中向下翻，找到并点击 **“进度同步”**。


3. **对接自建服务器**：
* 点击 **“自定义同步服务器 (Custom sync server)”**。
* 输入你的服务器地址：`http://你的服务器IP:3002`。


4. **注册与登录**：
* 点击 **“账户”** -> **“注册/登录”**，输入你自定义的账号密码。
* **重点**：你的手机和平板必须填**完全一样**的账号密码！


5. **开启同步**：
* 确保菜单中的 **“自动同步进度”** 处于勾选状态。

---

## 第三部分：云端备份配置 (Dropbox 仅保留最新一份)

VPS 可能会宕机，但存在 Dropbox 里的数据丢不了。由于我们的 VPS 是没有图形界面的（Headless），这一步的授权接力需要用到你的本地电脑。

### 1. 在 VPS 上安装 Rclone 并开始配置

```bash
sudo curl https://rclone.org/install.sh | sudo bash
rclone config

```

### 2. 详细配置步骤 (无头服务器接力法)

在 `rclone config` 界面中按以下顺序操作：

1. 输入 `n` (新建远程)。
2. 命名为：`dropbox_backup`。
3. 在列表中找到 `Dropbox` 并输入其对应的数字序号。
4. `client_id` 和 `client_secret` 连续按两下回车跳过。
5. `Edit advanced config?` 输入 `n`。
6. **`Use auto config?`** **必须输入 `n**`（因为服务器没浏览器）。

### 3. 本地电脑获取 Token

此时 VPS 会给出一行提示：`rclone authorize "dropbox"`。请按以下步骤借用本地电脑：

1. 在你的 Windows/Mac 电脑上下载 Rclone 压缩包并解压。
2. 打开解压后的文件夹，**点击顶部的地址栏，清空内容并输入 `cmd` 按回车**，直接在这个文件夹下打开黑色命令行窗口。
3. 在黑窗口输入 `rclone authorize "dropbox"` 并回车。
4. 浏览器会自动弹出，登录 Dropbox 并点击“允许”。
5. 回到黑窗口，复制那一长串以 `{"access_token":...}` 开头的代码。

### 4. 完成 VPS 配置

1. 回到 VPS 终端，将刚才复制的长代码粘贴进去，按回车。
2. 确认提示输入 `y`，最后输入 `q` 退出。
3. 测试连接：输入 `rclone lsd dropbox_backup:`，如果不报错说明授权成功！

---

## 第四部分：编写终极自动化脚本 (Cron)

这个脚本的作用是：每天打包数据库 -> 上传到 Dropbox 指定深层目录 -> **自动删除旧备份，永远只保留最新的一份**。

### 1. 创建脚本

```bash
vi ~/docker/book/backup_to_dropbox.sh

```

粘贴以下完整代码：

```bash
#!/bin/bash

# ================= 配置区 =================
REMOTE_NAME="dropbox_backup"
REMOTE_DIR="资料/文档/个人" # Dropbox 云端路径，会自动创建
SOURCE_DIR="/root/docker/book/kosync_data"
TEMP_BACKUP_DIR="/root/docker/book/backups"
FILE_NAME="kosync_$(date +%Y%m%d_%H%M%S).tar.gz"

# ================= 执行区 =================
mkdir -p $TEMP_BACKUP_DIR

echo "开始打包数据库..."
# 压缩时剔除多余目录层级
tar -czvf $TEMP_BACKUP_DIR/$FILE_NAME -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"

echo "正在上传至 Dropbox..."
rclone copy $TEMP_BACKUP_DIR/$FILE_NAME $REMOTE_NAME:"$REMOTE_DIR"

echo "正在清理云端旧文件，仅保留最新一份..."
# 按时间倒序拉取文件列表，跳过第一个（最新），删除其余所有旧文件
rclone lsf $REMOTE_NAME:"$REMOTE_DIR" --files-only --sort modtime --reverse | tail -n +2 | while read -r line; do
    echo "删除过期备份: $line"
    rclone deletefile $REMOTE_NAME:"$REMOTE_DIR/$line"
done

# 清理 VPS 本地的临时压缩包
rm -f $TEMP_BACKUP_DIR/$FILE_NAME

echo "备份与清理任务全部完成！"

```

### 2. 赋予权限与设置定时任务

```bash
# 赋予脚本运行权限
chmod +x ~/docker/book/backup_to_dropbox.sh

# 打开定时任务编辑器
crontab -e

```

在底部加入这一行（每天凌晨 3:15 自动运行，并生成日志供你日后排错）：

```bash
15 3 * * * /bin/bash /root/docker/book/backup_to_dropbox.sh > /root/docker/book/backup.log 2>&1

```

🎉 **至此，你的“多端阅读+自建同步+自动单例备份”系统已全部搭建完毕！你可以先手动运行一次脚本 `~/docker/book/backup_to_dropbox.sh`，去你的 Dropbox 网页端看看是不是已经躺着那个压缩包了。**

 
