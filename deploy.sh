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

# ========================================================
# [核心逻辑] 1.5 检测是否落后于远程仓库
# ========================================================
echo -e "${CYAN}🔍 正在检查远程仓库是否有未拉取的更新...${NC}"
# 静默获取远程最新状态，不改变本地工作区
git fetch origin develop -q

# 计算远程分支有，但本地没有的提交数量
BEHIND_COUNT=$(git rev-list HEAD..origin/develop --count 2>/dev/null || echo 0)

if [ "$BEHIND_COUNT" -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ [危险拦截] 你的本地仓库落后于远程仓库 ${BEHIND_COUNT} 个提交！${NC}"
    echo -e "${YELLOW}检测到你在网页端或其他地方修改了代码，尚未拉取到本地。${NC}"
    echo -e "${YELLOW}为了防止 --force 强推覆盖掉你的修改，已自动取消本次部署。${NC}"
    echo ""
    echo -e "👉 ${GREEN}请先双击运行你的 pull.sh，然后再重新部署。${NC}"
    echo ""
    read -p "按回车键关闭窗口..."
    exit 1
else
    echo -e "${GREEN}✅ 检查通过：本地代码已包含远程最新进度，安全放行。${NC}"
fi
# ========================================================

# 2. 配置环境
git config --global core.autocrlf false

# 3. 提交更改
git add .

# 检查是否有内容需要提交
if git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}没有检测到新的更改，本地工作区是干净的。${NC}"
else
    # ========================================================
    # [新增交互逻辑] 提示用户输入提交信息
    # ========================================================
    # 动态生成默认提交信息 (带有当前时间戳)
    DEFAULT_MSG="site backup: $(date +'%Y-%m-%d %H:%M:%S')"
    
    echo ""
    echo -e "${YELLOW}👉 请输入本次部署的说明 (直接回车默认: ${DEFAULT_MSG}): ${NC}"
    read COMMIT_MSG
    
    # 如果用户没有输入任何内容（直接敲了回车），则赋予默认的带时间的信息
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="$DEFAULT_MSG"
        echo -e "未输入内容，已自动使用默认信息: ${GREEN}${COMMIT_MSG}${NC}"
    else
        echo -e "已记录你的自定义提交信息: ${GREEN}${COMMIT_MSG}${NC}"
    fi

    git commit -m "$COMMIT_MSG"
    # ========================================================
fi

# 4. 尝试推送
echo -e "${CYAN}正在推送至远程仓库...${NC}"
# 注意：--force 会覆盖远程仓库，但上方已做了安全拦截
if git push origin develop --force; then
    echo ""
    echo -e "${GREEN}✨ [成功] 博客已推送至 GitHub，同步完成！${NC}"
    echo -e "${GREEN}现在可以开始新的创作了。${NC}"
else
    echo ""
    echo -e "${RED}❌ [失败] 推送过程中出现错误。${NC}"
    echo "请检查：1. 网络连接是否正常 2. 账号权限是否失效"
fi

echo -e "${BLUE}任务结束。${NC}"

# 强行停留，直到你按回车
echo ""
read -p "按回车键关闭窗口..."