#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # 恢复默认颜色

echo -e "${CYAN}🚀 正在启动 Hugo 预览服务器...${NC}"

# ========================================================
# 核心逻辑：
# -O (--openBrowser): 启动后自动打开系统默认浏览器
# -D (--buildDrafts): 包含被标记为草稿的文章
# --renderToMemory: 在内存中渲染，速度更快
# ========================================================

echo -e "${YELLOW}提示：Hugo 将自动选择可用端口并为你打开浏览器。${NC}"
echo ""

# 执行 Hugo server 命令
if hugo server -O -D --renderToMemory; then
    echo ""
    echo -e "${GREEN}⏹️ 服务器已正常关闭。${NC}"
else
    echo ""
    echo -e "${RED}❌ 启动失败！${NC}"
    echo -e "${YELLOW}报错信息如上，请检查是否有无法跳过的端口冲突。${NC}"
fi

# 强行停留
echo ""
read -p "按回车键关闭窗口..."