#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # 恢复默认颜色

echo -e "${CYAN}🚀 正在启动 Hugo 预览服务器 (含自动清理逻辑)...${NC}"

# ========================================================
# 1. 自动清理逻辑：杀掉残留进程并清除锁文件
# ========================================================
echo -e "${YELLOW}正在清理后台残留的 Hugo 进程...${NC}"

# 强制杀掉所有 hugo.exe 进程 (适配 Windows)
# 2>/dev/null 是为了在没有进程可杀时不报错
taskkill //F //IM hugo.exe //T 2>/dev/null || true

# 检查并删除可能导致死锁的 lock 文件
if [ -f ".hugo_build.lock" ]; then
    echo -e "${YELLOW}发现残留的 .hugo_build.lock，正在移除...${NC}"
    rm -f .hugo_build.lock
fi

# ========================================================
# 2. 环境变量配置 (防止网络请求卡死)
# ========================================================
export GOPROXY="https://goproxy.cn,direct"
export HUGO_MODULE_WORKSPACE="off"

# ========================================================
# 3. 核心启动逻辑
# ========================================================
echo -e "${GREEN}清理完成，准备在 1313 端口启动服务器...${NC}"
echo ""

# 执行 Hugo server 命令
# -O: 启动后自动打开浏览器
# -D: 包含草稿
# --renderToMemory: 内存渲染，速度最快
# --logLevel info: 输出关键日志
hugo server -O -D --renderToMemory --logLevel info
EXIT_CODE=$?

# 判断退出状态
if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 130 ]; then
    echo ""
    echo -e "${GREEN}⏹️ 服务器已正常关闭，窗口即将退出...${NC}"
    sleep 1
    exit 0
else
    echo ""
    echo -e "${RED}❌ 启动失败！(错误码: $EXIT_CODE)${NC}"
    echo ""
    read -p "按回车键关闭窗口..."
    exit 1
fi