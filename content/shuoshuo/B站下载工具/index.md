---
title: "B站下载工具"
slug: "fee24682"
description: ""
date: 2026-03-19T19:17:54+08:00
lastmod: 2026-03-19T19:17:54+08:00
draft: false
toc: true
weight: false
image: ""
categories: [""]
shuoshuotags: ["技术"]
---

  B站下载工具：[yutto](https://github.com/yutto-dev/yutto)

1.请直接在你的 VPS 终端完整执行下面这一整块代码：

```
cat << 'EOF' > /usr/local/bin/bili
#!/bin/bash
# 顺手删掉我们之前为了测试生成的配置文件，防止它捣乱
rm -f yutto.toml .yutto_tmp.toml
# 你最新的、绝对有效的凭证
SESSDATA="你的SESSDATA"
# 最纯粹、你亲自验证过能跑通的命令格式！先传 URL ($@)，再传 --sessdata
docker run --rm -it -v "$(pwd):/app" -w /app siguremo/yutto "$@" --sessdata "$SESSDATA"
EOF
# 重新授权
chmod +x /usr/local/bin/bili
```

2.下载单个视频

```bash
cd /home/admin/bili
bili "https://www.bilibili.com/video/BV1TezzYhEfn/"
```

3.下载合集

```bash
cd /home/admin/bili
bili "https://www.bilibili.com/video/BV1Cp4y1H7k7" -b
```

4.清理镜像

```bash
docker system prune -f
```

