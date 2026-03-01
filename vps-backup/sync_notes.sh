#!/bin/bash

# --- 核心配置区 ---
WATCH_DIR="/root/Koreader"               
BLOG_DIR="/root/iwyang.github.io"        
CONTENT_DIR="$BLOG_DIR/content/shuoshuo" 
PROCESSED_LOG="$BLOG_DIR/.processed_notes.log"

mkdir -p "$WATCH_DIR" "$CONTENT_DIR"
touch "$PROCESSED_LOG"

# ==========================================================
# 👇 核心进化：基于“划线原初时间”的绝对幂等切割引擎 👇
# 包含修复：新增“动态章节追踪”，完美解决跨章节标签错乱与笔记污染
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

# --- 1. 全局净化 KOReader 残留垃圾 ---
$raw =~ s/\r//g;
$raw =~ s/^\s*\[?在书中查看\]?.*$//mg; 
$raw =~ s/^_?Generated at:.*_?$//mg; 

my @chunks = split(/(?=(?:\*\* ?)?Page\s+\d+\s+@)/, $raw);
my $header = shift @chunks; 

# 提取书名、作者，并初始化第一章
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
    
    # 👇 核心修复：动态提取并剔除夹在 chunk 尾部的“下一章”标题（防血崩污染笔记） 👇
    my $next_chapter = "";
    while ($chunk =~ s/^\s*##\s+([^\n]*)$//m) {
        my $c = $1; $c =~ s/^\s+|\s+$//g;
        $next_chapter = $c if $c ne "";
    }
    $chunk =~ s/^\s*##\s*$//mg; # 兜底清空残留的纯 ## 空行

    my ($page, $formatted_time, $dir_time, $fm_date, $slug) = ("", "", "", "", "");
    
    # --- 2. 提取时间与页码 ---
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
    } else {
        next; 
    }

    # --- 3. 智能切割：引文(Quote) vs 个人想法(Note) ---
    my $note = "";
    if ($chunk =~ m/^\s*---\s*$/m) {
        my @parts = split(/^\s*---\s*$/m, $chunk, 2);
        $chunk = $parts[0];
        $note = $parts[1] if @parts > 1;
    }

    $chunk =~ s/^\s+|\s+$//g;
    $chunk =~ s/^\*+//;       
    $chunk =~ s/\*+$//;       
    $chunk =~ s/^\s+|\s+$//g;
    $chunk =~ s/^/> /mg;      
    
    if ($note) {
        $note =~ s/^\s+|\s+$//g;
        $note =~ s/^\*+//; 
        $note =~ s/\*+$//;
    }

    my $final_text = $chunk;
    $final_text .= "\n\n" . $note if $note;
    
    next if $final_text =~ /^\s*$/; 

    # --- 4. 写入文件（精准使用 current_chapter） ---
    my $display_title = "书摘：《$book》- 第${page}页 ($dir_time)";
    my $target_dir = "$content_dir/$display_title";
    system("mkdir", "-p", $target_dir);
    my $target_file = "$target_dir/index.md";
    
    open(my $out, '>:encoding(UTF-8)', $target_file) or next;
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
    
    # 👇 记录更新：把找到的下一章名称，交给下一次循环使用 👇
    if ($next_chapter ne "") {
        $current_chapter = $next_chapter;
    }
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
            echo "[$(date)] ⚠️ 拦截：导出文件 $FILE 已处理过，跳过！"
            continue
        fi

        # 核心：调用引擎切割
        perl "$PERL_ENGINE" "$WATCH_DIR/$FILE" "$CONTENT_DIR"

        BACKUP_DIR="$BLOG_DIR/vps-backup"
        mkdir -p "$BACKUP_DIR"
        cp /root/scripts/sync_notes.sh "$BACKUP_DIR/" 2>/dev/null
        cp /etc/systemd/system/koreader-sync.service "$BACKUP_DIR/" 2>/dev/null
        cp "$PERL_ENGINE" "$BACKUP_DIR/" 2>/dev/null

        cd "$BLOG_DIR" || exit
        git add .
        
        # 判断 Git 是否真的有新东西需要提交
        if git diff --staged --quiet; then
            echo "[$(date)] 💡 检测到内容无变化（全是旧笔记），跳过 Git 推送环节。"
            echo "$FILE" >> "$PROCESSED_LOG"
            continue
        fi
        
        git commit -m "Auto-publish: 批量书摘拆分 ($FILE) & Backup"
        
        # 👇 核心防卡死机制：尝试合并云端代码，如果遇到冲突报错，立刻中止，绝不卡死！ 👇
        if ! git pull --rebase origin develop; then
            echo "[$(date)] ⚠️ 警告：拉取云端代码时发生冲突！已自动取消合并。"
            git rebase --abort
            echo "[$(date)] ❌ 本次推送中断，将在下次有新笔记时自动重试。"
            continue
        fi
        
        if git push origin develop; then
            echo "[$(date)] 🚀 成功推送至 GitHub！(新书摘已独立上线)"
            echo "$FILE" >> "$PROCESSED_LOG"
        else
            echo "[$(date)] ❌ 推送失败。"
        fi
    fi
done