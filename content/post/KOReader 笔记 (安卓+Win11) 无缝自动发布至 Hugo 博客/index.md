---
title: "KOReader 笔记 (安卓+Win11) 无缝自动发布至 Hugo 博客"
slug: "koreader-sync-ultimate-guide"
description: "从手机同步到桌面一键推送，从自动拆分排版到免冲突发布，打造涵盖全平台、坚不可摧的读书笔记全自动闭环。"
date: 2026-02-28T19:00:00+08:00
lastmod: 2026-03-05T20:00:00+08:00
draft: false
toc: true
weight: false
image: ""
categories: ["技术"]
tags: ["hugo", "KOReader"]
---

对于习惯使用 KOReader 阅读（比如追《剑来》等网文）的极客来说，如何优雅地将高亮笔记汇集并展示出来，一直是个不断优化的命题。

本篇终极指南将带你从零开始，在 Linux VPS 上搭建一套坚不可摧的自动化系统。无论你是躺在床上用**安卓手机**看书，还是坐在电脑前用 **Windows 11 / WSL2** 阅读，只需轻轻一点，1 到 2 秒钟内，经过时间格式化、排版精美且完美分离“原著引文与个人想法”的**独立卡片式读书笔记**，就会自动挂载着专属标签，出现在你的 Hugo 博客上。

---

## 阶段一：本地端自动化搬运配置 (双端齐下)

我们需要建立一条从阅读设备到 VPS 的“私有通道”。你可以根据自己的阅读场景，配置手机端或 PC端（或两者皆备）。

### 场景 A：手机端自动化搬运 (FolderSync)
我们需要做到**“阅后即焚”**，防止旧笔记重复同步死循环。

1. **KOReader 导出设置**：阅读时划线，在菜单中选择“导出标注” -> 格式选择 Markdown。文件默认存放在手机的 `/storage/emulated/0/koreader/clipboard/` 目录下。
2. **配置 FolderSync App**：
   * 在 App 内添加 **SFTP** 账户，填入 VPS 的 IP、端口 `22` 以及 root 账号密码。
3. **创建文件夹同步对**：
   * **同步类型**：选择 **“到左侧文件夹”**（单向上传至 VPS）。
   * **同步选项**：**必须勾选“同步后删除源文件”（Delete source files after sync）**。这是为了实现“阅后即焚”。
   * **本地目录**：选择手机的 `/koreader/clipboard/`。
   * **远程目录**：在 VPS 上新建并选择 `/root/Koreader`。
   * **调度**：开启 **“即时同步”**。

### 场景 B：Win11 WSL2 极速推送与软件安装 (Rsync + SSH 触发)
如果你在电脑上阅读，配置 WSL 环境并使用脚本主动推送是最高效的方式。

1. **Win11 安装 WSL2**：
   在 PowerShell (管理员) 中执行 `wsl --install` 和 `wsl --install -d Ubuntu`，安装完成后重启电脑并设置 Ubuntu 账号密码。
2. **开启镜像网络模式 (关键)**：
   按下 `Win + R` 输入 `%UserProfile%`，新建或修改 `.wslconfig` 文件，填入：
   ```ini
   [wsl2]
   memory=2GB
   networkingMode=mirrored
   autoProxy=true

*注意：切勿添加 `localhostForwarding=true`，镜像模式下两端已共享网络，保留会引发报错。*

3. **执行重启命令**：
   在 PowerShell 中输入 `wsl --shutdown`。然后重新打开 Ubuntu 终端，**网络配置**即刻生效。

4. **避坑与准备：在 WSL 中安装 KOReader (可选)**：
* 💡 **路径避坑**：如果你是从管理员 PowerShell 直接输入 `wsl` 进入的，你的提示符可能会显示在 `/mnt/c/Windows/system32`。**强烈建议**：在 WSL 里操作时，养成进终端先输入 `cd ~` 的习惯，回到你的 Linux 家目录（即 `/home/yang`）。在 `/mnt/c/`（Windows 分区）下操作 Linux 文件的性能非常差，且容易遇到权限限制问题（Permission Denied）。
* **创建目录与下载安装包**：刚装好的 Ubuntu 不会默认创建 `Downloads` 等常用文件夹，我们需要手动创建并下载：
```bash
# 1. 刷新软件源列表，防止系统因包列表太旧而在安装依赖时报 404 错误
sudo apt update

# 2. 创建下载目录并进入 (-p 参数非常稳，父目录不存在也会一并创建)
mkdir -p ~/Downloads
cd ~/Downloads

# 3. 下载 KOReader 安装包
wget https://github.com/iwyang/backup/releases/download/koreader-v2025.10/koreader-2025.10-amd64.deb

# 4. 消除 _apt 安全权限警告 (让沙盒用户有权读取这个本地安装包)
sudo chmod 644 ./koreader-2025.10-amd64.deb

# 5. 执行安装 (系统会自动下载并补齐 alsa-lib 等所需环境依赖)
sudo apt install ./koreader-2025.10-amd64.deb -y
```


* 🏁 **最后的冲刺**：执行完安装后，你可以尝试直接输入 `koreader` 来启动它！


5. **配置免密登录**：在 WSL 终端中执行 `ssh-keygen -t ed25519`，然后用 `ssh-copy-id -p 22 root@你的VPS_IP` 发送公钥。
6. **测试免密登录**：
```bash
ssh -p 22 root@142.171.177.173

```


*如果直接进入了 VPS 而没有弹密码框，说明配置成功。输入 `exit` 退回 WSL。*
如果还需密码，设置权限：
* **强制修正权限**
登录VPS，SSH 对 `root` 用户目录的权限极其敏感。执行这三行：


```bash
chmod 700 /root
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

```


* **检查文件所有权**
虽然你用的是 root，但最好确认一下文件是否归属正确：


```bash
chown -R root:root /root/.ssh

```


7. **创建本地一键推送脚本**： 在 WSL 中执行 `vi ~/sync_notes.sh`，贴入以下代码（注意修改用户名和 IP），并赋予执行权限 `chmod +x ~/sync_notes.sh`：

```bash
#!/bin/bash
# 功能: 同步 KOReader 笔记至 VPS，并远程瞬间唤醒切割引擎
USER_NAME="yang"
LOCAL_NOTE_DIR="/home/$USER_NAME/.config/koreader/clipboard/"  
LOG_FILE="/home/$USER_NAME/koreader_sync.log"
REMOTE_USER="root"
REMOTE_IP="你的VPS_IP"
REMOTE_PORT="22" 
REMOTE_DIR="/root/Koreader/" 
REMOTE_SCRIPT="/root/scripts/sync_notes.sh" 

if [ ! -d "$LOCAL_NOTE_DIR" ]; then exit 1; fi

echo "正在将笔记同步至 VPS ($REMOTE_IP)..."
rsync -avz -e "ssh -p $REMOTE_PORT" --delete "$LOCAL_NOTE_DIR" "$REMOTE_USER@$REMOTE_IP:$REMOTE_DIR" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "正在通知 VPS 执行笔记切割与发布..."
    # 附带 --now 参数，VPS 处理完瞬间退出，本地永不卡死
    ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_IP "bash $REMOTE_SCRIPT --now" >> "$LOG_FILE" 2>&1
else
    echo "❌ 同步失败，请检查网络。" >> "$LOG_FILE"
    exit 1
fi

```

---

## 阶段二：VPS 基础环境与 Git 深度配置

为了让后台脚本能全自动推送到 GitHub，必须在 VPS 上安装所需软件，并打通云端提交通道。

### 1. 安装基础依赖 (Git, SSH, inotify, Perl)

```bash
apt update && apt upgrade -y
apt install git openssh-client inotify-tools perl -y

```

### 2. 配置 Git 全局身份

```bash
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的GitHub注册邮箱"

```

### 3. 生成 SSH 密钥并对接 GitHub

生成高强度的 `ed25519` 密钥对（**执行后一路回车，千万不要设置密码，否则后台脚本会卡死**）：

```bash
ssh-keygen -t ed25519 -C "你的GitHub邮箱"

```

复制公钥内容 `cat ~/.ssh/id_ed25519.pub`，前往 GitHub **Settings** -> **SSH and GPG keys** 添加。

### 4. 克隆仓库与忽略日志

```bash
cd /root
git clone git@github.com:你的用户名/你的仓库名.git
cd /root/你的仓库名
echo ".processed_notes.log" >> .gitignore
git add .gitignore
git commit -m "Chore: 忽略同步记录日志文件"
git push origin develop

```

---

## 阶段三：部署坚不可摧的核心引擎 (纯净双轨模式)

这份终极版 VPS 脚本包含了强大的 Perl 智能切割引擎，它具备三大极客特性：

1. **自动释放机制**：单文件部署，运行自动生成 Perl 引擎。
2. **防 DOM 崩溃装甲**：利用 `<hr>` 隔离带与魔法注释，彻底解决 Hugo 渲染幽灵空行的问题。
3. **双轨触发系统**：既能 24 小时监听手机上传 (`inotify`)，又能秒级响应 WSL 的主动调用 (`--now` + `moved_to` 识别)。

创建脚本：`mkdir -p /root/scripts && vi /root/scripts/sync_notes.sh`

```bash
#!/bin/bash
# ==========================================================
# 脚本：sync_notes.sh (VPS 端)
# 功能：自动生成 Perl 引擎、监听目录/响应远程指令、排版推送
# ==========================================================

# --- 1. 核心配置区 ---
WATCH_DIR="/root/Koreader"               
BLOG_DIR="/root/iwyang.github.io"        
CONTENT_DIR="$BLOG_DIR/content/shuoshuo" 
PROCESSED_LOG="$BLOG_DIR/.processed_notes.log"
PERL_ENGINE="/root/scripts/split_notes.pl"

mkdir -p "$WATCH_DIR" "$CONTENT_DIR"
touch "$PROCESSED_LOG"

# --- 2. 自动释放 Perl 切割引擎 ---
cat << 'PERL_EOF' > "$PERL_ENGINE"
use utf8;
use POSIX qw(strftime);
binmode(STDOUT, ":utf8");

my $file_path = $ARGV[0];
my $content_dir = $ARGV[1];

open(my $fh, '<:encoding(UTF-8)', $file_path) or exit;
my $raw = join("", <$fh>);
close($fh);

$raw =~ s/\r//g;
$raw =~ s/^\s*\[?在书中查看\]?.*$//mg; 
$raw =~ s/^_?Generated at:.*_?$//mg; 

my @chunks = split(/(?=(?:\*\* ?)?Page\s+\d+\s+@)/, $raw);
my $header = shift @chunks; 

my ($book, $author, $current_chapter) = ("未知书名", "未知作者", "未知章节");
if ($header =~ /^\s*#\s+([^\n]+)/m) { $book = $1; $book =~ s/^\s+|\s+$//g; }
if ($header =~ /^\s*#####\s+([^\n]+)/m) { $author = $1; $author =~ s/^\s+|\s+$//g; }
while ($header =~ /^\s*##\s+([^\n]+)/mg) { 
    my $c = $1; $c =~ s/^\s+|\s+$//g;
    $current_chapter = $c if $c ne ""; 
}

my %months = (January=>"01", February=>"02", March=>"03", April=>"04", May=>"05", June=>"06", July=>"07", August=>"08", September=>"09", October=>"10", November=>"11", December=>"12");

foreach my $chunk (@chunks) {
    next if $chunk =~ /^\s*$/; 
    my $next_chapter = "";
    while ($chunk =~ s/^\s*##\s+([^\n]*)$//m) {
        my $c = $1; $c =~ s/^\s+|\s+$//g;
        $next_chapter = $c if $c ne "";
    }
    $chunk =~ s/^\s*##\s*$//mg;

    my ($page, $formatted_time, $dir_time, $fm_date, $slug) = ("", "", "", "", "");
    if ($chunk =~ s/^\s*(?:\*\* ?)?Page\s+(\d+)\s+@\s+(\d{1,2})\s+([a-zA-Z]+)\s+(\d{4})\s+(\d{2}):(\d{2}):(?:\d{2})\s+(AM|PM)\*?\*?\s*//i) {
        $page = $1; my $d = $2; my $mon = ucfirst(lc($3)); my $y = $4; my $h = $5; my $m = $6; my $ampm = uc($7);
        my $m_num = $months{$mon} || "01";
        $h += 12 if ($ampm eq "PM" && $h < 12); $h = 0 if ($ampm eq "AM" && $h == 12);
        $formatted_time = sprintf("%04d-%02d-%02d %02d:%02d", $y, $m_num, $d, $h, $m);
        $dir_time = sprintf("%04d-%02d-%02d %02d-%02d", $y, $m_num, $d, $h, $m);
        $fm_date = sprintf("%04d-%02d-%02dT%02d:%02d:00+08:00", $y, $m_num, $d, $h, $m);
        $slug = sprintf("note-%04d%02d%02d%02d%02d-%s", $y, $m_num, $d, $h, $m, $page);
    } elsif ($chunk =~ s/^\s*(?:\*\* ?)?Page\s+(\d+)\s+@\s+(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2})\*?\*?\s*//) {
        $page = $1; my $y = $2; my $m_num = $3; my $d = $4; my $h = $5; my $m = $6;
        $formatted_time = "$y-$m_num-$d $h:$m"; $dir_time = "$y-$m_num-$d $h-$m";
        $fm_date = sprintf("%04d-%02d-%02dT%02d:%02d:00+08:00", $y, $m_num, $d, $h, $m);
        $slug = sprintf("note-%04d%02d%02d%02d%02d-%s", $y, $m_num, $d, $h, $m, $page);
    } else { next; }

    my $note = "";
    if ($chunk =~ m/^\s*---\s*$/m) {
        my @parts = split(/^\s*---\s*$/m, $chunk, 2); $chunk = $parts[0]; $note = $parts[1] if @parts > 1;
    }
    $chunk =~ s/^\s+|\s+$//g; $chunk =~ s/^\*+//; $chunk =~ s/\*+$//; $chunk =~ s/^\s+|\s+$//g; $chunk =~ s/^/> /mg;
    if ($note) { $note =~ s/^\s+|\s+$//g; $note =~ s/^\*+//; $note =~ s/\*+$//; $note =~ s/^\s+|\s+$//g; }

    my $final_text = $chunk;
    if ($note ne "") { $final_text .= "\n\n<hr class=\"note-divider\">\n\n$note"; }
    next if $final_text =~ /^\s*$/; 

    my $display_title = "书摘：《$book》- 第${page}页 ($dir_time)";
    my $target_dir = "$content_dir/$display_title";
    system("mkdir", "-p", $target_dir);
    open(my $out, '>:encoding(UTF-8)', "$target_dir/index.md") or next;
    print $out <<"MARKDOWN";
---
title: "$display_title"
date: "$fm_date"
slug: "$slug"
lastmod: "$fm_date"
draft: false
toc: false
weight: false
categories: [""]
shuoshuotags: ["书摘"]
---

<div class="book-note-card">

### 📚 《$book》 <small style="font-weight: normal; margin-left: 8px;">👤 $author · 🔖 $current_chapter</small>

<div class="book-note-meta">📍 第 ${page} 页 | ⏱️ $formatted_time</div>

$final_text

</div>
MARKDOWN
    close($out);
    if ($next_chapter ne "") { $current_chapter = $next_chapter; }
}
PERL_EOF
chmod +x "$PERL_ENGINE"

# --- 3. 核心处理逻辑 ---
run_process() {
    local FILE=$1
    echo "[$(date)] 🔄 正在处理新文件: $FILE"
    
    cd "$BLOG_DIR" || exit
    # 强制对齐云端，无感去冲突
    git fetch origin && git reset --hard origin/develop && git clean -fd 

    perl "$PERL_ENGINE" "$WATCH_DIR/$FILE" "$CONTENT_DIR"

    git add .
    if git diff --staged --quiet; then
        echo "[$(date)] 💡 无变化，记录并跳过推送。"
        echo "$FILE" >> "$PROCESSED_LOG"
    else
        git commit -m "Auto-publish: 批量书摘拆分 ($FILE)"
        git push origin develop && echo "$FILE" >> "$PROCESSED_LOG" && echo "[$(date)] 🚀 推送成功！"
    fi
}

# --- 4. 逻辑分流 A：WSL 主动唤醒 (无阻断) ---
if [ "$1" == "--now" ]; then
    echo "收到主动触发信号，扫描新笔记..."
    for f in "$WATCH_DIR"/*.md; do
        [ -e "$f" ] || continue
        FILENAME=$(basename "$f")
        if ! grep -Fxq "$FILENAME" "$PROCESSED_LOG"; then
            run_process "$FILENAME"
        fi
    done
    exit 0 # 处理完立刻退出，不卡死远程 SSH
fi

# --- 5. 逻辑分流 B：24小时守护进程模式 ---
echo "🚀 守护进程启动：正在监听 $WATCH_DIR"
# 监听 close_write (手机直传) 和 moved_to (Rsync 重命名)
inotifywait -m -e close_write -e moved_to --format '%f' "$WATCH_DIR" | while read FILE
do
    if [[ "$FILE" == *.md ]] && [[ "$FILE" != .* ]]; then
        if grep -Fxq "$FILE" "$PROCESSED_LOG"; then
            echo "[$(date)] ⚠️ 跳过已处理文件。"
            continue
        fi
        run_process "$FILE"
    fi
done

```

赋予执行权限。如果日后**更新脚本**，请执行以下命令踢掉旧进程：

```bash
chmod +x /root/scripts/sync_notes.sh
pkill -9 -f sync_notes.sh
systemctl restart koreader-sync

```

---

## 阶段四：注册系统服务与实时监控

将脚本做成系统服务，确保 VPS 重启后依然坚守岗位。

### 1. 创建服务

```bash
vi /etc/systemd/system/koreader-sync.service

```

填入以下配置：

```ini
[Unit]
Description=KOReader Notes Auto-Sync Service
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

这是测试整个链路是否畅通的最强武器。手机点击导出或 WSL 运行同步后，在 VPS 终端输入以下命令，即可如同看电影一般实时观察处理全过程：

```bash
journalctl -u koreader-sync -f

```

---

## 阶段五：定时清理大扫除 (Cron)

传到 VPS 上的 `.md` 原始笔记是我们最后的“容错备份”。让 VPS 保留它们 7 天后再自动销毁。

1. 输入 `crontab -e` 开启定时任务编辑器。
2. 在末尾添加以下规则（每天凌晨 4 点查杀 7 天前的笔记）：

```bash
0 4 * * * find /root/Koreader -type f -name "*.md" -mtime +7 -delete

```

---

## 阶段六：修复 GitHub Actions 并发冲突 (防连环车祸)

如果你一次性导出了多篇独立笔记，VPS 会连续进行多次 `git push`。这会导致 GitHub 瞬间触发多个并行编译任务，引发 `non-fast-forward` 冲突报错。

**解决方案：给 GitHub Actions 加上排队机制。**

打开你博客仓库中的 `.github/workflows/deploy.yml` 文件，在文件顶部加入 `concurrency` 队列指令：

```yaml
name: GitHub Page Deploy

on:
  push:
    branches:
      - develop
  workflow_dispatch:

# 👇 核心：完美的防并发“排队”机制，杜绝多任务撞车报错 👇
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  TZ: Asia/Shanghai
# ...下面保持原样...

```

---

## 阶段七：Windows 桌面一键同步 (终极体验)

每次同步都要打开 WSL 终端敲代码？不够极客。我们来制作一个能在 Windows 桌面上双击运行，并且带有**智能倒计时关闭功能**的批处理脚本。

1. 在 Windows 电脑桌面上，右键 -> 新建 -> 文本文档。
2. 重命名为 `win11同步读书笔记.bat`（注意要删掉 `.txt` 后缀）。
3. 右键点击并在记事本中编辑，贴入以下代码保存（记得核对你的 WSL 用户名）：

```bat
@echo off
:: 设置字符集为 UTF-8，防止中文乱码
chcp 65001 >nul
title KOReader 笔记极速同步引擎
color 0A

echo ===================================================
echo     🚀 正在唤醒 WSL 执行 KOReader 笔记同步...
echo ===================================================
echo.

:: 核心命令：调用 WSL 里的 yang 用户执行脚本
wsl -u yang bash -c "/home/yang/sync_notes.sh"

:: 智能判断环节：检查 WSL 脚本的返回值
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===================================================
    echo     ✅ 远端发布成功！窗口将在 2 秒后自动关闭...
    echo ===================================================
    :: 倒计时 2 秒后自动退出
    timeout /t 2 >nul
    exit
) else (
    echo.
    :: 失败时把字体变成红色警告
    color 0C
    echo ===================================================
    echo     ❌ 同步似乎遇到了问题，请检查上方的报错信息。
    echo ===================================================
    :: 只有失败时才会暂停，等你排查问题
    pause
)

```

**最终体验**：现在你看完书，只需在桌面上双击这个图标。一个极客风的黑绿窗口瞬间弹出，行云流水般跑完同步指令，然后在你默念“一、二”后，乖乖地自动消失。

至此，这套坚如磐石、绝对幂等、涵盖手机与 PC 双平台的**真·极客闭环系统**已经完全确立。拿起设备安心阅读吧，剩下的繁杂代码，就交给服务器的齿轮去默默运转！

```

```