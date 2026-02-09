#!/bin/bash

# 遇到错误立即停止执行  
set -e

echo -e "\033[0;32mDeploying updates to Github(develop branch)...\033[0m"

# 1. 确保在 develop 分支（如果不在则尝试切换）
current_branch=$(git symbolic-ref --short HEAD)
if [ "$current_branch" != "develop" ]; then
    echo "Switching to develop branch..."
    git checkout develop
fi  

# 2. 配置环境
git config --global core.autocrlf false

# 3. 提交更改
git add .

# 检查是否有内容需要提交，避免 commit 报错
if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
else
    git commit -m "site backup: $(date +'%Y-%m-%d %H:%M:%S')"
fi

# 4. 强制推送
git push origin develop --force

echo -e "\033[0;34mDone!\033[0m"