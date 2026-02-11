#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # 恢复默认颜色

# 定义编辑器路径
TYPORA_PATH="D:\Program Files\Typora\Typora.exe"

echo -e "${CYAN}📝 开始新建 Hugo 文章...${NC}"

# 1. 提示用户输入文章名
echo -en "${YELLOW}👉 请输入文章文件名 (例如: my-new-post): ${NC}"
read POST_NAME

# 检查输入是否为空
if [ -z "$POST_NAME" ]; then
    echo -e "${RED}❌ 错误: 文章名不能为空！${NC}"
    read -p "按回车键退出..."
    exit 1
fi

# 2. 构建文章完整路径
# 格式为: post/文章名/index.md
RELATIVE_PATH="post/${POST_NAME}/index.md"
FULL_PATH="content/${RELATIVE_PATH}"

# 3. 执行 Hugo 命令新建文章
echo -e "${CYAN}正在创建文章: ${RELATIVE_PATH}...${NC}"
hugo new "$RELATIVE_PATH"

# 检查文章是否创建成功
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 文章创建成功！${NC}"
    
    # 4. 调用 Typora 打开新建的文章
    echo -e "${CYAN}🚀 正在启动 Typora...${NC}"
    
    # 使用 Windows 的 start 命令调用指定路径的编辑器
    if [ -f "$FULL_PATH" ]; then
        # 注意路径中的空格需要用引号包裹
        "$TYPORA_PATH" "$FULL_PATH" &
    else
        echo -e "${RED}❌ 错误: 找不到创建的文件 ${FULL_PATH}${NC}"
    fi
else
    echo -e "${RED}❌ 错误: Hugo 文章创建失败。${NC}"
fi

# 强行停留
echo ""
read -p "按回车键关闭窗口..."