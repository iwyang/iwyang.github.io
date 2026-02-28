#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m' 

echo -e "${CYAN}[1/3] 检查本地状态...${NC}"

# 检查是否有未提交的更改
HAS_CHANGES=$(git status --porcelain)

if [ -n "$HAS_CHANGES" ]; then
    echo -e "${YELLOW}检测到本地有未提交修改，正在自动存入 Stash...${NC}"
    git stash
    STASHED=true
else
    STASHED=false
fi

echo -e "${CYAN}[2/3] 正在拉取远程更新 (Rebase 模式)...${NC}"
git pull --rebase

# 检查拉取是否成功
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ [错误] 拉取失败！${NC}"
    if [ "$STASHED" = true ]; then
        echo -e "${YELLOW}正在尝试还原本地修改...${NC}"
        git stash pop
    fi
    echo "--------------------------------"
    echo "请检查网络或手动处理冲突后再尝试。"
    read -p "按回车键确认并关闭窗口..." 
    exit 1
fi

echo -e "${CYAN}[3/3] 正在恢复本地进度...${NC}"
if [ "$STASHED" = true ]; then
    # 尝试恢复暂存，并检查是否产生冲突
    if git stash pop; then
        echo -e "${GREEN}✅ 修改已成功恢复。${NC}"
    else
        echo ""
        echo -e "${RED}❌ [注意] 恢复本地修改时产生冲突！${NC}"
        echo -e "${YELLOW}请在编辑器中手动解决冲突并提交。${NC}"
        echo "--------------------------------"
        read -p "按回车键确认并关闭窗口..." 
        exit 1
    fi
else
    echo "本地无修改需要恢复。"
fi

echo ""
echo -e "${GREEN}✨ [成功] 博客已同步并保持最新状态！${NC}"
echo "窗口将在 2 秒后自动关闭..."
sleep 2
exit 0