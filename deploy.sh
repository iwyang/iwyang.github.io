#!/bin/bash
echo -e "\033[0;32mDeploying updates to vps...\033[0m"
git add .	
git commit -m "site backup"
git push --force origin backup
node link.js
hexo clean
hexo g -d

#!/usr/bin/env bash

# 一句话暴力解决
rm -rf "E:/Dropbox/资料/文档/个人/_posts" 2>/dev/null
cp -r "E:/blog/source/_posts" "E:/Dropbox/资料/文档/个人/"

echo "完成！"