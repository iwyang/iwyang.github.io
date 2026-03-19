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
# 你的终极凭证
SESSDATA="你的SESSDATA"
# 如果你只想下这一个，或者下合集，都直接用参数喂给它
# "$@" 会把你输入的 URL 和 -b 等参数传过去
docker run --rm -it -v "$(pwd):/app" siguremo/yutto "$@" --sessdata "$SESSDATA"
EOF
# 授权
chmod +x /usr/local/bin/bili
```

2.下载单个视频

```bash
bili "https://www.bilibili.com/video/BV1TezzYhEfn/"
```

3.下载合集

```bash
bili "https://www.bilibili.com/video/BV1Cp4y1H7k7" -b
```

