#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m' # 恢复默认颜色

echo -e "${CYAN}🚀 开始从远程获取最新主题 (Git Submodule)...${NC}"
echo -e "${YELLOW}如果主题更新内容较多，可能需要一点时间，请稍候。${NC}"
echo ""

# 执行子模块更新命令，并检查是否成功
if git submodule update --remote; then
    echo ""
    echo -e "${GREEN}✨ [成功] 主题已成功拉取并更新到最新版本！${NC}"
    echo -e "${YELLOW}💡 提示：主题的版本号指针已改变。如果你觉得新主题没问题，${NC}"
    echo -e "${YELLOW}   请记得稍后运行 deploy.sh 把这个改动提交并推送到 GitHub。${NC}"
    echo ""
    echo -e "窗口将在 2 秒后自动关闭..."
    sleep 2
    exit 0
else
    echo ""
    echo -e "${RED}❌ [失败] 主题更新过程中出现错误。${NC}"
    echo "请检查你的网络连接（特别是如果之前遇到过 GitHub 端口超时的问题）。"
    echo ""
    read -p "按回车键关闭窗口..."
    exit 1
fi