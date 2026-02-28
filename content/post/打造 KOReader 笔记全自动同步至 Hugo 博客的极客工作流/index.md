---
title: "终极指南：打造 KOReader 笔记全自动同步至 Hugo 博客的极客工作流"
slug: "8458c80f"
description: "从手机到服务器，从自动拆分排版到免冲突推送，打造坚不可摧的读书笔记全自动闭环。"
date: 2026-02-28T19:00:00+08:00
lastmod: 2026-02-28T19:00:00+08:00
draft: false
toc: true
weight: false
image: ""
categories: ["技术"]
tags: ["hugo", "KOReader", "自动化", "折腾"]
---

对于习惯使用 KOReader 阅读（比如追《剑来》等网文）的极客来说，如何优雅地将高亮笔记汇集并展示出来，一直是个不断优化的命题。

本篇终极指南将带你从零开始，在 Linux VPS 上搭建一套坚不可摧的自动化系统。打通 **安卓手机 (KOReader) ➡️ FolderSync (SFTP) ➡️ VPS (inotify) ➡️ Git自动化 ➡️ GitHub ➡️ Hugo 博客** 的全链路。

**实现效果**：看书时划线并点击“导出”，1分钟内，经过时间格式化、去除冗余链接、排版精美且完美分离“原著引文与个人想法”的**独立卡片式读书笔记**，就会自动挂载着专属标签，出现在你的博客说说页面上。

---

## 阶段一：手机端自动化搬运 (FolderSync)

我们需要建立一条从手机到 VPS 的“私有通道”，并做到**“阅后即焚”**，防止旧笔记重复同步死循环。

1. **KOReader 导出设置**：阅读时划线，在菜单中选择“导出标注” -> 格式选择 Markdown。文件默认存放在手机的 `/storage/emulated/0/koreader/clipboard/` 目录下。
2. **配置 FolderSync App**：
   * 在 App 内添加 **SFTP** 账户，填入 VPS 的 IP、端口 `22` 以及 root 账号密码。
3. **创建文件夹同步对**：
   * **同步类型**：选择 **“到左侧文件夹”**（单向上传至 VPS）。
   * **同步选项**：**必须勾选“同步后删除源文件”（Delete source files after sync）**。这是为了实现“阅后即焚”，防止每次导出都把旧笔记重复传给 VPS。
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

查看并复制你的公钥内容 `cat ~/.ssh/id_ed25519.pub`。
登录 GitHub 网页端 ➡️ **Settings** ➡️ **SSH and GPG keys** ➡️ **New SSH key**，将刚才复制的内容粘贴进去并保存。

### 4. 测试连接、克隆仓库与忽略日志

测试免密连接：`ssh -T git@github.com`

克隆仓库并设置 `.gitignore`（防止脚本生成的处理记录日志引发冲突）：

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

## 阶段三：部署坚不可摧的核心脚本 (纯净工人模式)

这份终极版脚本内置了强大的 Perl 智能切割引擎，它具备三大极客特性：

1. **动态章节追踪**：无论你一次导出多少跨章节的笔记，它都能精准识别并打上正确的章节标签。
2. **防 DOM 崩溃装甲**：利用 `` 魔法注释与专用的 `<hr>` 标签，完美规避了 Hugo Markdown 解析器“吞噬标签、生成幽灵空行”的臭名昭著的 Bug。
3. **纯净工人模式 (无感去冲突)**：每次处理新笔记前，VPS 会强制 `git reset --hard` 对齐云端。无论你在云端怎么删改旧笔记，本地都不会再发生致命的 modify/delete 冲突！

创建脚本：`vi /root/scripts/sync_notes.sh`

```bash
#!/bin/bash

# --- 核心配置区 ---
WATCH_DIR="/root/Koreader"               
BLOG_DIR="/root/iwyang.github.io"        
CONTENT_DIR="$BLOG_DIR/content/shuoshuo" 
PROCESSED_LOG="$BLOG_DIR/.processed_notes.log"

mkdir -p "$WATCH_DIR" "$CONTENT_DIR"
touch "$PROCESSED_LOG"

# ==========================================================
# 👇 核心引擎：基于“划线原初时间”的绝对幂等切割引擎 👇
# ==========================================================
PERL_ENGINE="/root/scripts/split_notes.pl"
cat << 'PERL_EOF' > "$PERL_ENGINE"
use utf8;
use POSIX qw(strftime);

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
        $page = $1; 
        my $d = $2; my $mon = ucfirst(lc($3)); my $y = $4; my $h = $5; my $m = $6; my $ampm = uc($7);
        my $m_num = $months{$mon} || "01";
        $h += 12 if ($ampm eq "PM" && $h < 12);
        $h = 0 if ($ampm eq "AM" && $h == 12);
        $formatted_time = sprintf("%04d-%02d-%02d %02d:%02d", $y, $m_num, $d, $h, $m);
        $dir_time = sprintf("%04d-%02d-%02d %02d-%02d", $y, $m_num, $d, $h, $m);
        $fm_date = sprintf("%04d-%02d-%02dT%02d:%02d:00+08:00", $y, $m_num, $d, $h, $m);
        $slug = sprintf("note-%04d%02d%02d%02d%02d-%s", $y, $m_num, $d, $h, $m, $page);
    } elsif ($chunk =~ s/^\s*(?:\*\* ?)?Page\s+(\d+)\s+@\s+(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2})\*?\*?\s*//) {
        $page = $1; my $y = $2; my $m_num = $3; my $d = $4; my $h = $5; my $m = $6;
        $formatted_time = "$y-$m_num-$d $h:$m";
        $dir_time = "$y-$m_num-$d $h-$m";
        $fm_date = sprintf("%04d-%02d-%02dT%02d:%02d:00+08:00", $y, $m_num, $d, $h, $m);
        $slug = sprintf("note-%04d%02d%02d%02d%02d-%s", $y, $m_num, $d, $h, $m, $page);
    } else { next; }

    my $note = "";
    if ($chunk =~ m/^\s*---\s*$/m) {
        my @parts = split(/^\s*---\s*$/m, $chunk, 2);
        $chunk = $parts[0];
        $note = $parts[1] if @parts > 1;
    }

    $chunk =~ s/^\s+|\s+$//g; $chunk =~ s/^\*+//; $chunk =~ s/\*+$//;
    $chunk =~ s/^\s+|\s+$//g; $chunk =~ s/^/> /mg;
    if ($note) { $note =~ s/^\s+|\s+$//g; $note =~ s/^\*+//; $note =~ s/\*+$//; $note =~ s/^\s+|\s+$//g; }

    # 👇 保留结构：使用 hr 作为隔离带，在 CSS 里将它隐形 👇
    my $final_text = $chunk;
    if ($note ne "") {
        $final_text .= "\n\n<hr class=\"note-divider\">\n\n$note";
    }
    
    next if $final_text =~ /^\s*$/; 

    my $display_title = "书摘：《$book》- 第${page}页 ($dir_time)";
    my $target_dir = "$content_dir/$display_title";
    system("mkdir", "-p", $target_dir);
    my $target_file = "$target_dir/index.md";
    
    open(my $out, '>:encoding(UTF-8)', $target_file) or next;
    # 👇 致命修复：注入 魔法注释，彻底解决套娃崩溃和幽灵空行 👇
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
# ==========================================================

echo "🚀 守护进程启动：正在监听 $WATCH_DIR"

inotifywait -m -e close_write --format '%f' "$WATCH_DIR" | while read FILE
do
    if [[ "$FILE" == *.md ]]; then
        echo "[$(date)] 接收到新文件: $FILE"

        if grep -Fxq "$FILE" "$PROCESSED_LOG"; then
            echo "[$(date)] ⚠️ 跳过已处理文件。"
            continue
        fi

        echo "[$(date)] 🔄 正在强制对齐云端状态..."
        cd "$BLOG_DIR" || exit
        git fetch origin
        git reset --hard origin/develop
        git clean -fd 

        perl "$PERL_ENGINE" "$WATCH_DIR/$FILE" "$CONTENT_DIR"

        git add .
        if git diff --staged --quiet; then
            echo "[$(date)] 💡 无变化，记录并跳过推送。"
            echo "$FILE" >> "$PROCESSED_LOG"
            continue
        fi
        
        git commit -m "Auto-publish: 批量书摘拆分 ($FILE)"
        
        if git push origin develop; then
            echo "[$(date)] 🚀 推送成功！"
            echo "$FILE" >> "$PROCESSED_LOG"
        else
            echo "[$(date)] ❌ 推送失败，等待下次重试。"
        fi
    fi
done
```

赋予执行权限，如果**更新脚本**，请执行以下命令踢掉旧进程：

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

这是测试整个链路是否畅通的最强武器。手机点击导出后，在 VPS 终端输入以下命令，即可如同看电影一般，实时观察脚本处理、云端对齐和推送的全过程：

```bash
journalctl -u koreader-sync -f

```

---

## 阶段五：定时清理大扫除 (Cron)

既然我们在手机端 FolderSync 设置了“同步后删除源文件”，那么传到 VPS 上的 `.md` 原始笔记就成了我们最后的“容错备份缓冲”。我们可以让 VPS 保留它们 7 天后再自动销毁。

1. 输入 `crontab -e` 开启定时任务编辑器。
2. 在末尾添加以下规则（每天凌晨 4 点，自动查杀 7 天前的原始垃圾笔记）：

```bash
0 4 * * * find /root/Koreader -type f -name "*.md" -mtime +7 -delete

```

---

## 阶段六：修复 GitHub Actions 并发冲突 (防连环车祸)

如果你一次性导出了多篇独立笔记，VPS 会连续进行多次 `git push`。这会导致 GitHub 瞬间触发多个并行编译任务，引发 `non-fast-forward` 冲突报错，网页彻底罢工。

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

这样，多个编译任务会自动排队，或直接取消旧任务只跑最新版，彻底杜绝云端部署失败！

至此，这套坚如磐石、绝对幂等、自动拆解章节、免 Git 冲突且永不丢失的**真·极客闭环系统**已经完全确立。拿起设备安心阅读吧，剩下的繁杂代码，就交给服务器的齿轮去默默运转！

```

```