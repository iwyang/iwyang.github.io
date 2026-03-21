#!/bin/bash
# ==========================================================
# 脚本：sync_notes.sh (VPS 端完全体)
# 功能：自动生成 Perl 引擎、排版推送、智能自毁检测与优先备份
# ==========================================================

# --- 1. 核心配置区 ---
WATCH_DIR="/root/Koreader"               
BLOG_DIR="/root/iwyang.github.io"        
CONTENT_DIR="$BLOG_DIR/content/shuoshuo" 
BACKUP_DIR="$BLOG_DIR/vps-backup"
PROCESSED_LOG="$BLOG_DIR/.processed_notes.log"
PERL_ENGINE="/root/scripts/split_notes.pl"
SERVICE_FILE="/etc/systemd/system/koreader-sync.service"

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

### 📚 《$book》 <small>👤 $author · 🔖 $current_chapter · 📍 第 ${page} 页</small>

$final_text

</div>
MARKDOWN
    close($out);
    if ($next_chapter ne "") { $current_chapter = $next_chapter; }
}
PERL_EOF
chmod +x "$PERL_ENGINE"

# --- 3. 核心处理逻辑 (防误杀+优先备份机制) ---
run_process() {
    local FILE=$1
    echo "[$(date)] 🔄 正在处理新文件: $FILE"
    
    cd "$BLOG_DIR" || exit
    
    # 【步骤 A】：先强制对齐云端。如果云端把 vps-backup 删了，本地也会被同步删掉。
    git fetch origin
    git reset --hard origin/develop
    git clean -fd 

    # 【步骤 B】：绝对优先备份检测！
    # 如果目录不存在（被误删）或有更新，立刻拦截，先完成备份！
    echo "[$(date)] 🛡️ 正在执行系统安全与备份自检..."
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "[$(date)] 🚨 警告：云端备份夹丢失，正在强制重建并优先备份！"
        mkdir -p "$BACKUP_DIR"
    fi
    
    cp "$0" "$BACKUP_DIR/sync_notes.sh"
    [ -f "$SERVICE_FILE" ] && cp "$SERVICE_FILE" "$BACKUP_DIR/"
    
    git add "$BACKUP_DIR"
    if ! git diff --staged --quiet; then
        git commit -m "Backup: Auto-update VPS scripts [$(date +'%Y-%m-%d %H:%M')]"
        git push origin develop
        echo "[$(date)] ✅ 运维脚本已优先安全送达云端！"
    fi

    # 【步骤 C】：后方安全确认完毕，开始处理真正的笔记
    echo "[$(date)] ✂️ 正在进行书摘切割排版..."
    perl "$PERL_ENGINE" "$WATCH_DIR/$FILE" "$CONTENT_DIR"

    git add .
    if ! git diff --staged --quiet; then
        git commit -m "Auto-publish: 批量书摘拆分 ($FILE)"
        git push origin develop
        echo "[$(date)] 🚀 笔记最终推送成功！"
    else
        echo "[$(date)] 💡 笔记无变化，跳过推送。"
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
            # 记录已处理，防止重复
            echo "$FILENAME" >> "$PROCESSED_LOG"
        fi
    done
    exit 0 # 处理完立刻退出，释放本地终端
fi

# --- 5. 逻辑分流 B：24小时守护进程模式 ---
echo "🚀 哨兵已就位，正在监听 $WATCH_DIR"
inotifywait -m -e close_write -e moved_to --format '%f' "$WATCH_DIR" | while read FILE
do
    if [[ "$FILE" == *.md ]] && [[ "$FILE" != .* ]]; then
        if ! grep -Fxq "$FILE" "$PROCESSED_LOG"; then
            run_process "$FILE"
            echo "$FILE" >> "$PROCESSED_LOG"
        fi
    fi
done