#!/bin/bash

# ========================================================
# 1. 定义颜色 (同步自 deploy.sh)
# ========================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 [博取] 正在同步静态资源到本地...${NC}"

# 2. 定义存放路径
CSS_DIR="./static/css"
JS_DIR="./static/js"

# 3. 确保目录存在
mkdir -p $CSS_DIR
mkdir -p $JS_DIR

# 4. 定义代理变量
PROXY="http://127.0.0.1:10808"

# 错误标记位
SUCCESS=true

# ========================================================
# 5. 执行下载任务
# ========================================================

echo -e "${YELLOW}📥 正在同步 Swiper 资源...${NC}"
curl -f -x $PROXY -L https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css -o $CSS_DIR/swiper-bundle.min.css || SUCCESS=false
curl -f -x $PROXY -L https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js -o $JS_DIR/swiper-bundle.min.js || SUCCESS=false

echo -e "${YELLOW}📥 正在同步 Fancybox 资源...${NC}"
curl -f -x $PROXY -L https://cdn.jsdelivr.net/npm/@fancyapps/ui@5.0/dist/fancybox/fancybox.css -o $CSS_DIR/fancybox.css || SUCCESS=false
curl -f -x $PROXY -L https://cdn.jsdelivr.net/npm/@fancyapps/ui@5.0/dist/fancybox/fancybox.umd.js -o $JS_DIR/fancybox.umd.js || SUCCESS=false

# ========================================================
# 6. 处理关闭逻辑
# ========================================================
if [ "$SUCCESS" = true ]; then
    echo ""
    echo -e "${GREEN}✨ [成功] 所有资源已通过代理 $PROXY 同步完成！${NC}"
    echo -e "${BLUE}任务结束，窗口将在 2 秒后自动关闭...${NC}"
    sleep 2
    exit 0
else
    echo ""
    echo -e "${RED}❌ [失败] 部分资源下载出现问题。${NC}"
    echo -e "${YELLOW}请检查：1. 代理软件是否开启 2. 端口是否为 10808${NC}"
    echo ""
    read -p "按回车键确认并手动关闭窗口..."
    exit 1
fi