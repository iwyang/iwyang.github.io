---
title: "安卓手机发布说说"
slug: "srzz8b3a"
description: ""
date: 2026-02-23T16:38:08.839+08:00
lastmod: 2026-02-23T16:38:08.839+08:00
draft: false
toc: true
weight: false
image: ""
categories: [""]
shuoshuotags: ["折腾"]
---
这是第一条由安卓手机`http shortcuts`发布的说说

```yaml
services:
  decotv-core:
    image: ghcr.io/decohererk/decotv:latest
    container_name: decotv-core
    restart: always  # You can keep 'unless-stopped' or 'always' as preferred
    ports:
      - '3000:3000'
    environment:
      - USERNAME=admin
      - PASSWORD=你的密码
      - NEXT_PUBLIC_STORAGE_TYPE=kvrocks
      - KVROCKS_URL=redis://decotv-kvrocks:6666
      - NEXT_PUBLIC_DISABLE_YELLOW_FILTER=false
    networks:
      - decotv-network
    depends_on:
      - decotv-kvrocks

  decotv-kvrocks:
    image: apache/kvrocks
    container_name: decotv-kvrocks
    restart: always  # You can keep 'unless-stopped' or 'always' as preferred
    volumes:
      - kvrocks-data:/var/lib/kvrocks
    networks:
      - decotv-network

  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 86400 --cleanup
    restart: always  # You can keep 'unless-stopped' or 'always' as preferred

networks:
  decotv-network:
    driver: bridge

volumes:
  kvrocks-data:

```

