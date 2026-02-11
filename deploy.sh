#!/bin/bash

# 遇到错误立即停止执行  
set -e

# 定义颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${GREEN}Deploying updates to Github (develop branch)...${NC}"

# 1. 确保在 develop 分支
current_branch=$(git symbolic-ref --short HEAD)
if [ "$current_branch" != "develop" ]; then
    echo "Switching to develop branch..."
    git checkout develop
fi  

# 2. 配置环境
git config --global core.autocrlf false

# 3. 提交更改
git add .

# 检查是否有内容需要提交
if git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}No changes to commit. Your local is clean.${NC}"
else
    git commit -m "site backup: $(date +'%Y-%m-%d %H:%M:%S')"
fi

# 4. 强制推送
# 注意：--force 会覆盖远程仓库，请确保这是你想要的操作
git push origin develop --force

echo -e "${BLUE}Done!${NC}"

# 强行停留，直到你按回车，防止双击运行后直接消失
echo ""
read -p "按回车键关闭窗口..."