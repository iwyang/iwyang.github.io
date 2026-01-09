#!/bin/bash
echo -e "\033[0;32mDeploying updates to vps...\033[0m"
git add .	
git commit -m "site backup"
git push --force origin backup
node link.js
hexo clean
hexo g -d

#!/usr/bin/env bash

# 目标位置
DEST="E:/Dropbox/资料/文档/个人"

# 先删除旧的 _posts（如果存在）
if [ -d "$DEST/_posts" ]; then
    rm -rf "$DEST/_posts"
    echo "已删除旧的 _posts 文件夹"
fi

# 使用 rsync 高效复制（推荐）
rsync -av --delete \
    "E:/blog/source/_posts/" \
    "$DEST/_posts/"

echo "复制完成！"
echo "目标路径: $DEST/_posts"