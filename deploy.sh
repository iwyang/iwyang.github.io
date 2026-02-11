#!/bin/bash

# 注意：为了能捕获错误并显示“失败”提示，我们不使用 set -e，而是手动判断关键步骤
# set -e  <-- 已注释掉

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 开始部署更新到 GitHub (develop 分支)...${NC}"

# 1. 确保在 develop 分支
current_branch=$(git symbolic-ref --short HEAD)
if [ "$current_branch" != "develop" ]; then
    echo "正在切换到 develop 分支..."
    git checkout develop || { echo -e "${RED}错误: 切换分支失败${NC}"; read -p "按回车退出..."; exit 1; }
fi  

# 2. 配置环境
git config --global core.autocrlf false

# 3. 提交更改
git add .

# 检查是否有内容需要提交
if git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}没有检测到新的更改，本地工作区是干净的。${NC}"
else
    git commit -m "site backup: $(date +'%Y-%m-%d %H:%M:%S')"
fi

# 4. 尝试推送
echo -e "${CYAN}正在推送至远程仓库...${NC}"
# 注意：--force 会覆盖远程仓库，请确保你已经运行过 pull.sh
if git push origin develop --force; then
    echo ""
    echo -e "${GREEN}✨ [成功] 博客已推送至 GitHub，同步完成！${NC}"
    echo -e "${GREEN}现在可以开始新的创作了。${NC}"
else
    echo ""
    echo -e "${RED}❌ [失败] 推送过程中出现错误。${NC}"
    echo "请检查：1. 网络连接是否正常 2. 是否有冲突需要处理"
fi

echo -e "${BLUE}任务结束。${NC}"

# 强行停留，直到你按回车
echo ""
read -p "按回车键关闭窗口..."