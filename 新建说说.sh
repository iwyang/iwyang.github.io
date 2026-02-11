#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # 恢复默认颜色

# 定义编辑器路径
TYPORA_PATH="D:\Program Files\Typora\Typora.exe"

echo -e "${CYAN}💬 开始新建一条说说...${NC}"

# 1. 提示用户输入说说名称
echo -en "${YELLOW}👉 请输入说说标题/文件名 (例如: my-status): ${NC}"
read SHUO_NAME

# 检查输入是否为空
if [ -z "$SHUO_NAME" ]; then
    echo -e "${RED}❌ 错误: 名称不能为空！${NC}"
    read -p "按回车键退出..."
    exit 1
fi

# 2. 构建路径 (说说通常直接使用 .md 文件)
RELATIVE_PATH="shuoshuo/${SHUO_NAME}.md"
FULL_PATH="content/${RELATIVE_PATH}"

# 3. 执行 Hugo 命令新建说说
echo -e "${CYAN}正在创建说说: ${RELATIVE_PATH}...${NC}"
hugo new "$RELATIVE_PATH"

# 检查是否创建成功
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 说说创建成功！${NC}"
    
    # 4. 调用 Typora 打开
    echo -e "${CYAN}🚀 🚀 正在启动 Typora...${NC}"
    
    if [ -f "$FULL_PATH" ]; then
        # 打开 Typora
        "$TYPORA_PATH" "$FULL_PATH" &
        
        echo -e "${GREEN}操作完成，窗口即将关闭...${NC}"
        sleep 2
        exit 0
    else
        echo -e "${RED}❌ 错误: 找不到创建的文件 ${FULL_PATH}${NC}"
        echo ""
        read -p "按回车键关闭窗口..."
        exit 1
    fi
else
    echo -e "${RED}❌ 错误: Hugo 命令执行失败。${NC}"
    echo ""
    read -p "按回车键关闭窗口..."
    exit 1
fi