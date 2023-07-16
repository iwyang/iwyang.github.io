---
title: 利用Github Actions自动同步Fork
categories:
  - 技术
tags:
  - github
comments: true
cover: /img/cover/github-action.jpg
abbrlink: 12dd937c
date: 2023-07-13 18:02:15
sticky:
keywords:
description:
top_img:
---

虽然Github自带一个Sync Fork的按钮，但是每次都自己点总是麻烦的，所以有人搞了个Github Action来做这件事，https://github.com/tgymnich/fork-sync

## 创建workflow

创建新的workflow后在`sync.yml`输入里面的内容：

**官方：**

```yaml
name: Sync Fork

on:
  schedule:
    - cron: '*/30 * * * *' # every 30 minutes
  workflow_dispatch: # on button click

jobs:
  sync:

    runs-on: ubuntu-latest

    steps:
      - uses: tgymnich/fork-sync@v1.8
        with:
          token: ${{ secrets.PERSONAL_TOKEN }}
          owner: llvm
          base: master
          head: master
```

**注释：**

```yaml
name: Sync Fork

on:
  push: # push 时触发, 主要是为了测试配置有没有问题
  schedule:
    - cron: '* */24 * * *' # 每天一次
jobs:
  repo-sync:
    runs-on: ubuntu-latest
    steps:
      - uses: tgymnich/fork-sync@v1.8
        with:
          token: ${{ secrets.TOKEN }} #Github Token，记得加入secrets
          owner: ngosang # fork 的上游仓库 user
          head: master # fork 的上游仓库 branch
          base: master # 本地仓库 branch
```

**最终**`sync.yml`

```yaml
name: Sync Fork

on:
  schedule:
    - cron: '* */24 * * *' # 每天一次
  workflow_dispatch: # on button click

jobs:
  sync:

    runs-on: ubuntu-latest

    steps:
      - uses: tgymnich/fork-sync@v1.8
        with:
          token: ${{ secrets.PERSONAL_TOKEN }}
          owner: mack-a
          base: master
          head: master
```

`* */24 * * *`改成`* */48 * * *`每两天运行一次

> PS：ChatGPT有时给出的答案可能是错误的，需要验证：[crontab guru](https://crontab.guru/)

## 创建github访问token

参考：[管理个人访问令牌](https://docs.github.com/zh/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

1.在任何页面的右上角，单击个人资料照片，然后单击“设置”。

2.在左侧边栏中，单击“ 开发人员设置”。
3.请在左侧边栏的“ Personal access token”下，单击“细粒度令牌” 。
4.单击“生成新令牌”。
5.在“令牌名称”下，输入令牌的名称。
6.在“过期时间”下，选择令牌的过期时间（永不过期）。

7.然后权限要开启**repo**和**workflow**的权限

![](../img/%E5%88%A9%E7%94%A8Github-Actions%E8%87%AA%E5%8A%A8%E5%90%8C%E6%AD%A5Fork/github.png)

8.创建完成后复制token内容

## 添加环境变量secret

在`settings/secrets(Secrets and variables)/actions`里把Github的Token设置上，比如workflow写的是secrets.PERSONAL_TOKEN，所以添加的时候Name填写PERSONAL_TOKEN，Secret里填写上一步创建Token内容。

如果部署完成之后，运行显示错误是：

> repo-sync
> Failed to create or merge pull request: HttpError: Validation Failed: {“resource”:”PullRequest”,”code”:”custom”,”message”:”No commits between knight000:master and ngosang:master”}

就证明初步成功了，因为你部署了workflow所以比原仓库新，等原仓库更新后点`Re-run jobs`就可以测试是否正确部署了。

## 自动提交修改到Gitee(未测试)

以下action文件来自https://juejin.cn/post/6894928345830522887

把GITEE_PRIVATE_KEY、[GITEE_TOKEN](https://gitee.com/profile/personal_access_tokens)、GITEE_USER都添加到secrets里，然后Gitee内[从URL导入仓库](https://gitee.com/projects/import/url)，创建同名仓库即可同步。

```yaml
# 通过 Github actions， 在 Github 仓库的每一次 commit 后自动同步到 Gitee 上
name: sync2gitee
on:
  push:
    branches:
      - master
jobs:
  repo-sync:
    env:
      dst_key: ${{ secrets.GITEE_PRIVATE_KEY }}
      dst_token: ${{ secrets.GITEE_TOKEN }}
      gitee_user: ${{ secrets.GITEE_USER }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          persist-credentials: false

      - name: sync github -> gitee
        uses: Yikun/hub-mirror-action@master
        if: env.dst_key && env.dst_token && env.gitee_user
        with:
          # 必选，需要同步的 Github 用户（源）
          src: 'github/${{ github.repository_owner }}'
          # 必选，需要同步到的 Gitee 用户（目的）
          dst: 'gitee/${{ secrets.GITEE_USER }}'
          # 必选，Gitee公钥对应的私钥，https://gitee.com/profile/sshkeys
          dst_key: ${{ secrets.GITEE_PRIVATE_KEY }}
          # 必选，Gitee对应的用于创建仓库的token，https://gitee.com/profile/personal_access_tokens
          dst_token:  ${{ secrets.GITEE_TOKEN }}
          # 如果是组织，指定组织即可，默认为用户 user
          # account_type: org
          # 直接取当前项目的仓库名
          static_list: ${{ github.event.repository.name }}
```

因为有`if: env.dst_key && env.dst_token && env.gitee_user`这一句所以信息不足的情况下是会跳过执行，显示执行成功而不是显示错误，请注意。

## 参考链接

+ [GithunActionAutoSync2Gitee](https://knight.abn-team.top/2023/03/29/GithunActionAutoSync2Gitee/)
+ [利用Github Actions自动同步Fork](https://zhuanlan.zhihu.com/p/500768626)
+ [fork-sync](https://github.com/tgymnich/fork-sync)
