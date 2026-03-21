#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 开始部署更新到 GitHub (develop 分支)...${NC}"

# ========================================================
# 0. Git 身份自动检查与配置
# ========================================================
USER_EMAIL=$(git config user.email)
USER_NAME=$(git config user.name)

if [ -z "$USER_EMAIL" ] || [ -z "$USER_NAME" ]; then
    echo -e "${YELLOW}检测到 Git 尚未配置身份信息，正在自动初始化...${NC}"
    git config --global user.name "yang"
    git config --global user.email "iwyang@users.noreply.github.com"
    echo -e "${GREEN}✅ 身份配置完成: yang (iwyang@users.noreply.github.com)${NC}"
fi

# 1. 确保在 develop 分支
current_branch=$(git symbolic-ref --short HEAD)
if [ "$current_branch" != "develop" ]; then
    echo "正在切换到 develop 分支..."
    git checkout develop || { echo -e "${RED}错误: 切换分支失败${NC}"; read -p "按回车退出..."; exit 1; }
fi  

# ========================================================
# 2. 安全检查：检测是否落后于远程仓库
# ========================================================
echo -e "${CYAN}🔍 正在检查远程仓库状态...${NC}"
git fetch origin develop -q

# 计算远程分支有，但本地没有的提交数量
BEHIND_COUNT=$(git rev-list HEAD..origin/develop --count 2>/dev/null || echo 0)

if [ "$BEHIND_COUNT" -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ [危险拦截] 你的本地仓库落后于远程仓库 ${BEHIND_COUNT} 个提交！${NC}"
    echo -e "${YELLOW}为了防止 --force 强推覆盖掉远程修改，已自动取消本次部署。${NC}"
    echo ""
    echo -e "👉 ${GREEN}请先运行你的 pull.sh，然后再重新部署。${NC}"
    echo ""
    read -p "按回车键关闭窗口..."
    exit 1
fi

# ========================================================
# 3. [优化逻辑] 状态检查：是否真的有内容需要更新？
# ========================================================
echo -e "${CYAN}🔍 正在检查本地更新状态...${NC}"

# 检查是否有未提交的更改 (包括新增文件)
HAS_CHANGES=$(git status --porcelain)
# 检查本地是否领先于远程 (是否有已 commit 但未 push 的内容)
AHEAD_COUNT=$(git rev-list origin/develop..HEAD --count 2>/dev/null || echo 0)

if [ -z "$HAS_CHANGES" ] && [ "$AHEAD_COUNT" -eq 0 ]; then
    echo ""
    echo -e "${GREEN}☕ 检查完毕：当前没有任何更新（本地干净且已与远程同步）。${NC}"
    echo -e "${BLUE}无需执行部署，窗口将在 2 秒后自动关闭...${NC}"
    sleep 2
    exit 0
fi

# 4. 配置环境
git config --global core.autocrlf false

# ========================================================
# 5. 提交更改 (仅在有本地变动时执行)
# ========================================================
if [ -n "$HAS_CHANGES" ]; then
    git add .
    
    # 动态生成默认提交信息
    DEFAULT_MSG="site backup: $(date +'%Y-%m-%d %H:%M:%S')"
    
    echo ""
    echo -e "${YELLOW}👉 检测到本地改动，请输入部署说明 (直接回车默认: ${DEFAULT_MSG}): ${NC}"
    read COMMIT_MSG
    
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="$DEFAULT_MSG"
        echo -e "未输入内容，已自动使用默认信息: ${GREEN}${COMMIT_MSG}${NC}"
    else
        echo -e "已记录你的自定义提交信息: ${GREEN}${COMMIT_MSG}${NC}"
    fi

    # 执行 commit
    git commit -m "$COMMIT_MSG" || { echo -e "${RED}❌ 提交失败，请检查配置。${NC}"; exit 1; }
else
    echo -e "${YELLOW}检测到本地已有 ${AHEAD_COUNT} 个待推送提交，准备直接同步至 GitHub...${NC}"
fi

# ========================================================
# 6. 尝试推送
# ========================================================
echo -e "${CYAN}正在推送至远程仓库...${NC}"
if git push origin develop --force; then
    echo ""
    echo -e "${GREEN}✨ [成功] 博客已推送至 GitHub，同步完成！${NC}"
    echo -e "${GREEN}现在可以开始新的创作了。${NC}"
    echo -e "${BLUE}任务结束，窗口将在 2 秒后自动关闭...${NC}"
    sleep 2
    exit 0
else
    echo ""
    echo -e "${RED}❌ [失败] 推送过程中出现错误。${NC}"
    echo "请检查：1. 网络连接是否正常 2. 账号权限是否失效"
    echo ""
    read -p "按回车键关闭窗口..."
    exit 1
fi