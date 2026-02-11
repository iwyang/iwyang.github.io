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
echo -e "${YELLOW}按 Ctrl+C 即可停止服务器并自动关闭本窗口。${NC}"
echo ""

# 执行 Hugo server 命令并记录其退出码
hugo server -O -D --renderToMemory
EXIT_CODE=$?

# 判断退出码：
# 0 表示纯正常退出
# 130 表示被 Ctrl+C (SIGINT 信号) 中断退出
if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 130 ]; then
    echo ""
    echo -e "${GREEN}⏹️ 服务器已正常关闭，窗口即将退出...${NC}"
    sleep 1
    exit 0
else
    # 其他退出码（比如端口冲突导致的退出）才会走这里
    echo ""
    echo -e "${RED}❌ 启动失败！(错误码: $EXIT_CODE)${NC}"
    echo -e "${YELLOW}报错信息如上，请检查是否有无法跳过的端口冲突等问题。${NC}"
    echo ""
    read -p "按回车键关闭窗口..."
    exit 1
fi