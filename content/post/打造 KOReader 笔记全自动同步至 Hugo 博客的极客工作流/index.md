---
title: "终极指南：打造 KOReader 笔记全自动同步至 Hugo 博客的极客工作流"
slug: "8458c80f"
description: ""
date: 2026-02-27T23:03:44+08:00
lastmod: 2026-02-27T23:03:44+08:00
draft: false
toc: true
weight: false
image: ""
categories: ["技术"]
tags: ["hugo"]
---

对于习惯使用 KOReader 阅读（比如追《剑来》等网文）的极客来说，如何优雅地将高亮笔记汇集并展示出来，一直是个不断优化的命题。

本篇终极指南将带你从零开始，在 Linux VPS 上搭建一套坚不可摧的自动化系统。打通 **安卓手机 (KOReader) ➡️ FolderSync (SFTP) ➡️ VPS (inotify) ➡️ Git自动化 ➡️ GitHub ➡️ Hugo 博客** 的全链路。

实现效果：看书时划线并点击“导出”，1分钟内，经过时间格式化、去除冗余链接、排版精美的读书笔记就会自动挂载着专属标签，出现在你的博客说说页面上。

## 阶段一：手机端自动化搬运 (FolderSync)

我们需要建立一条从手机到 VPS 的“私有通道”。

1. **KOReader 导出设置**：阅读时划线，在菜单中选择“导出标注” -> 格式选择 Markdown。文件默认存放在手机的 `/storage/emulated/0/koreader/clipboard/` 目录下。
2. **配置 FolderSync App**：
   * 在 App 内添加 **SFTP** 账户，填入 VPS 的 IP、端口 `22` 以及 root 账号密码。
3. **创建文件夹同步对**：
   * **同步类型**：选择 **“到左侧文件夹”**（单向上传至 VPS）。
   * **本地目录**：选择手机的 `/koreader/clipboard/`。
   * **远程目录**：在 VPS 上新建并选择 `/root/Koreader`。
   * **调度**：开启 **“即时同步”**。

---

## 阶段二：VPS 基础环境与 Git 深度配置

为了让后台脚本能全自动推送到 GitHub，必须在 VPS 上安装所需软件，并打通 SSH 免密通道。

### 1. 安装基础依赖 (Git, SSH, inotify)
更新系统，并确保安装了 Git、SSH 客户端以及用于实时监听文件变动的 `inotify-tools`。
```bash
apt update && apt upgrade -y
apt install git openssh-client inotify-tools -y

```

### 2. 配置 Git 全局身份

告诉 Git 你是谁。这里的邮箱最好与你的 GitHub 账号邮箱保持一致，否则推送到 GitHub 后的提交记录上不会显示你的专属头像。

```bash
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的GitHub注册邮箱"

```

### 3. 生成 SSH 密钥并对接 GitHub

生成高强度的 `ed25519` 密钥对（**执行后一路回车，千万不要设置密码，否则后台脚本会卡死**）：

```bash
ssh-keygen -t ed25519 -C "你的GitHub邮箱"

```

查看并复制你的公钥内容：

```bash
cat ~/.ssh/id_ed25519.pub

```

登录 GitHub 网页端 ➡️ **Settings** ➡️ **SSH and GPG keys** ➡️ **New SSH key**，将刚才复制的内容粘贴进去并保存。

### 4. 测试连接并克隆博客仓库

测试 VPS 是否能免密连接到 GitHub：

```bash
ssh -T git@github.com

```

*(看到 `Hi <用户名>! You've successfully authenticated...` 即为成功)*

使用 **SSH 地址** 克隆你的博客仓库到 VPS（注意替换）：

```bash
cd /root
git clone git@github.com:你的用户名/你的仓库名.git

```

---

## 阶段三：部署坚不可摧的核心脚本 (防 Windows 报错版)

这份脚本内置了强大的 Perl 正则处理器，能够智能合并书籍信息、将繁琐的英文时间换算为极简的 24 小时制。
**特别注意：** 脚本中生成文件夹时间的格式使用了横杠 `-` 而不是冒号 `:`，完美避开了 Windows 系统不允许文件夹名带冒号的巨坑。

创建脚本：`vi /root/scripts/sync_notes.sh`

```bash
#!/bin/bash

# --- 核心配置区 ---
WATCH_DIR="/root/Koreader"               
BLOG_DIR="/root/iwyang.github.io"        
CONTENT_DIR="$BLOG_DIR/content/shuoshuo" 

mkdir -p "$WATCH_DIR"
mkdir -p "$CONTENT_DIR"

echo "🚀 守护进程启动：正在监听 $WATCH_DIR"

inotifywait -m -e close_write --format '%f' "$WATCH_DIR" | while read FILE
do
    if [[ "$FILE" == *.md ]]; then
        echo "[$(date)] 接收到新文件: $FILE"

        # 1. 提取书名与时间
        CLEAN_NAME=$(echo "$FILE" | sed -E 's/^[0-9-]{19}\s+//')
        BOOK_TITLE="${CLEAN_NAME%.*}"
        
        # 时间格式使用横杠代替冒号，防止 Windows 本地 Git 拉取时报 invalid path 错误
        NOW_TIME=$(date +"%Y-%m-%d %H-%M")
        
        FULL_DISPLAY_NAME="书摘：《$BOOK_TITLE》 ($NOW_TIME)"

        # 2. 创建 Page Bundle
        TARGET_DIR="$CONTENT_DIR/$FULL_DISPLAY_NAME"
        mkdir -p "$TARGET_DIR"
        TARGET_FILE="$TARGET_DIR/index.md"

        # 3. 生成变量
        DATE_STR=$(date +"%Y-%m-%dT%H:%M:%S+08:00")
        SLUG_STR="note-$(date +'%Y%m%d%H%M%S')"

        # 4. 文本清洗与排版优化 (时间转换 + 修复引用跨行失效)
        raw_content=$(grep -v -e "在书中查看" -e "Generated at:" "$WATCH_DIR/$FILE")
        
        # 使用强大的 Perl 脚本直接进行日期换算和格式重构
        NOTE_CONTENT=$(echo "$raw_content" | perl -0777 -pe '
            # A. 转换标题行 (书名作者章节合体)
            s/^\s*#\s+([^\n]+)\n+#*\s*([^\n]+)\n+#*\s*([^\n]+)\n+/### 📚 《$1》 <small style="font-weight: normal; margin-left: 8px;">👤 $2 · 🔖 $3<\/small>\n\n/s;
            
            # B. 提取英文时间计算为 YYYY-MM-DD HH:MM 格式，并且使用 \n\n 完美隔开段落
            s/^.*?Page\s+(\d+)\s+@\s+(\d{1,2})\s+([a-zA-Z]+)\s+(\d{4})\s+(\d{2}):(\d{2}):\d{2}\s+(AM|PM).*$/
                my ($page, $d, $mon, $y, $h, $m, $ampm) = ($1, $2, ucfirst(lc($3)), $4, $5, $6, uc($7));
                my %months = (January=>"01", February=>"02", March=>"03", April=>"04", May=>"05", June=>"06", July=>"07", August=>"08", September=>"09", October=>"10", November=>"11", December=>"12");
                my $m_num = $months{$mon} || "01";
                $h += 12 if ($ampm eq "PM" && $h < 12);
                $h = 0 if ($ampm eq "AM" && $h == 12);
                sprintf("📍 第 %s 页 | ⏱️ %04d-%02d-%02d %02d:%02d\n\n", $page, $y, $m_num, $d, $h, $m);
            /gemi;
            
            # 兜底匹配：如果时间已经是普通数字格式，直接提取
            s/^.*?Page\s+(\d+)\s+@\s+(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}).*$/📍 第 $1 页 | ⏱️ $2\n\n/gm;
            
            # C. 核心修复：支持多段落跨行引用！去掉首尾星号，并为每一行单独加上大引号 >
            s/^[ \t]*\*\s*(.*?)\s*\*[ \t]*$/ my $t = $1; $t =~ s!^!> !mg; $t /msge;
        ')

        # 5. 写入 Hugo 格式
        cat <<EOF > "$TARGET_FILE"
---
title: "$FULL_DISPLAY_NAME"
date: "$DATE_STR"
slug: "$SLUG_STR"
lastmod: "$DATE_STR"
draft: false
toc: false
weight: false
categories: [""]
shuoshuotags: ["书摘"]
---

$NOTE_CONTENT
EOF

        # 6. 推送至 GitHub
        cd "$BLOG_DIR" || exit
        git add .
        git commit -m "Auto-publish: $FULL_DISPLAY_NAME"
        git pull --rebase origin develop
        
        if git push origin develop; then
            echo "[$(date)] 🚀 成功推送至 GitHub！"
        else
            echo "[$(date)] ❌ 推送失败。"
        fi
    fi
done
```

赋予执行权限：

```bash
chmod +x /root/scripts/sync_notes.sh

```

---

如果**更新脚本**，请执行以下命令踢掉旧的后台进程

```bash
pkill -9 -f sync_notes.sh
systemctl restart koreader-sync
```

## 阶段四：注册系统服务与实时监控

将脚本做成系统服务，确保 VPS 重启后依然坚守岗位。

### 1. 创建服务

```bash
vi /etc/systemd/system/koreader-sync.service

```

填入以下配置：

```ini
[Unit]
Description=KOReader to Hugo Auto Sync Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/bin/bash /root/scripts/sync_notes.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

```

### 2. 激活并启动服务

```bash
systemctl daemon-reload
systemctl enable --now koreader-sync

```

### 3. 极客排错利器：实时日志监控

这是测试整个链路是否畅通的最强武器。手机点击导出后，在 VPS 终端输入以下命令，即可如同看电影一般，实时观察脚本处理和推送的全过程：

```bash
journalctl -u koreader-sync -f

```

*(按 `Ctrl + C` 退出监控模式)*

---

## 阶段五：定时清理大扫除 (Cron)

VPS 上的原始 `.md` 笔记在处理后就失去了保留价值，可以通过 `cron` 每天凌晨自动清理。

1. 输入 `crontab -e` 开启定时任务编辑器。
2. 在末尾添加以下规则（每天凌晨 4 点，自动查杀 3 天前的原始垃圾笔记）：

```bash
0 4 * * * find /root/Koreader -type f -name "*.md" -mtime +3 -delete

```

---

## 🛑 附录：跨平台 Git Pull `invalid path` 避坑指南

如果你在 VPS 上生成的文件夹名字中包含了冒号（例如 `20:10`），由于 Windows 系统严格禁止在文件名中使用冒号 `< > : " / \ | ? *`，当你在本地电脑上执行 `git pull` 时，Git 会直接报错 `error: invalid path` 并且拒绝同步。

**补救方法：**

1. 首先参考本教程，将脚本中的时间格式修改为横杠（`-`），重启服务。
2. 在 **VPS 终端**上，暴力删除那些带有冒号的非法文件夹，并推送到云端：
```bash
cd /root/iwyang.github.io/content/shuoshuo/
rm -rf *:*
git add .
git commit -m "Fix: 删除带有冒号的非法 Windows 路径"
git push origin develop

```


3. 在你的 **本地 Windows 电脑** 终端执行强行覆盖，与云端重新对齐：
```bash
git fetch origin develop
git reset --hard origin/develop

```



彻底解决跨平台同步死锁！

至此，这套坚如磐石的闭环系统已经完全确立。拿起设备安心阅读吧，剩下的繁杂代码，就交给服务器的齿轮去默默运转！

