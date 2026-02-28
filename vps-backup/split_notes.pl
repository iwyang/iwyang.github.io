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
