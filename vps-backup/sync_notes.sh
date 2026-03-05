#!/bin/bash
# ==========================================================
# 脚本：sync_notes.sh (VPS 端完全体)
# 功能：自动生成 Perl 引擎、排版推送、并实现智能脚本自备份
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

# --- 2. 智能脚本自备份函数 ---
backup_self() {
    echo "[$(date)] 💾 正在检查运维脚本备份状态..."
    
    # 核心修复：防止被 git clean 误杀，每次备份前强制检测目录
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "[$(date)] 🆕 未检测到备份目录，正在初始化创建并准备首次备份..."
        mkdir -p "$BACKUP_DIR"
    fi
    
    # 将最新脚本和配置文件复制到备份区
    cp "$0" "$BACKUP_DIR/sync_notes.sh"
    if [ -f "$SERVICE_FILE" ]; then
        cp "$SERVICE_FILE" "$BACKUP_DIR/"
    fi
    
    cd "$BLOG_DIR" || exit
    git add "$BACKUP_DIR"
    
    # 智能判断：首次新建文件夹放入文件，或文件内容有改动时，都会触发推送
    if ! git diff --staged --quiet; then
        git commit -m "Backup: Auto-update VPS scripts [$(date +'%Y-%m-%d %H:%M')]"
        git push origin develop
        echo "[$(date)] ✅ 运维脚本已安全备份至 GitHub 仓库！"
    else
        echo "[$(date)] 💡 脚本无变动，跳过云端备份。"
    fi
}

# --- 3. 自动释放 Perl 切割引擎 ---
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

# --- 4. 核心处理逻辑 ---
run_process() {
    local FILE=$1
    echo "[$(date)] 🔄 正在处理新文件: $FILE"
    
    cd "$BLOG_DIR" || exit
    
    # 强制对齐云端，清理可能干扰的未追踪文件
    git fetch origin
    git reset --hard origin/develop
    git clean -fd 

    # 调用生成的 Perl 引擎切割笔记
    perl "$PERL_ENGINE" "$WATCH_DIR/$FILE" "$CONTENT_DIR"

    # 提交发布笔记
    git add .
    if ! git diff --staged --quiet; then
        git commit -m "Auto-publish: 批量书摘拆分 ($FILE)"
        git push origin develop
        echo "[$(date)] 🚀 笔记推送成功！"
    else
        echo "[$(date)] 💡 笔记无变化，跳过推送。"
    fi
}

# --- 5. 逻辑分流 A：WSL 主动唤醒 (无阻断) ---
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
    
    # 笔记处理完毕后，强制执行一遍智能自备份检查
    backup_self
    
    exit 0 # 处理完立刻退出，释放本地终端
fi

# --- 6. 逻辑分流 B：24小时守护进程模式 ---
echo "🚀 哨兵已就位，正在监听 $WATCH_DIR"
inotifywait -m -e close_write -e moved_to --format '%f' "$WATCH_DIR" | while read FILE
do
    if [[ "$FILE" == *.md ]] && [[ "$FILE" != .* ]]; then
        if ! grep -Fxq "$FILE" "$PROCESSED_LOG"; then
            run_process "$FILE"
            echo "$FILE" >> "$PROCESSED_LOG"
            
            # 被动触发处理笔记后，也顺带检查一下是否需要备份脚本
            backup_self
        fi
    fi
done