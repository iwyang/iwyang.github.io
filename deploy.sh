#!/bin/bash
echo -e "\033[0;32mDeploying updates to gitee...\033[0m"
git add .	
git commit -m "site backup"
git push --force origin backup
node link.js
hexo clean
hexo g -d