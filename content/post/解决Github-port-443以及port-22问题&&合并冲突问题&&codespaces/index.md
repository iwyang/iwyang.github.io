---
title: 解决Github Port 443以及Port 22问题&&合并冲突问题&&codespaces
categories:
  - 技术
tags:
  - github
slug: 2284a148
date: 2021-08-18 03:56:29
cover: false
---

## 解决port 443问题

1.切换到全：

```bash
git config --global http.proxy http://127.0.0.1:10808
 
git config --global https.proxy http://127.0.0.1:10808
```

2.取消全：

```bash
git config --global --unset http.proxy
 
git config --global --unset https.proxy
```

3.再次切换到全：

```bash
git config --global http.proxy http://127.0.0.1:10808
 
git config --global https.proxy http://127.0.0.1:10808
```

这时会出现 `port 22: Connection refused`问题。

4.测试

```
git clone https://github.com/iwyang/DecoTV.git
```

**用https克隆，不要用ssh协议克隆，否则即使daili了速度还是很慢。**

修改后提交：

```
git add .
git commit -m "你的提交信息"
git push origin main
```

```
cd /root/docker/tv
docker-compose pull
docker-compose up -d
docker image prune
```
## 解决`port 22`问题

1.进入.ssh的目录，使用命令`touch config`创建一个配置文件，并写入你github的配置信息。（`xxxxx@xx.com`是你github的注册邮箱）

```bash
Host github.com  
User xxxxx@xx.com  
Hostname ssh.github.com  
PreferredAuthentications publickey  
IdentityFile ~/.ssh/id_rsa  
Port 443
```

2.更改配置文件config的权限。

```bash
chmod 600 config
```

3.再尝试查看连接状态

```bash
ssh git@github.com
```

**Please make sure you have the correct access rights and the repository exist**

如果即使已经添加本地公钥到github，还提示以上错误，并且执行`ssh -T git@github.com`提示22端口关闭，解决方法见上。
## 解决合并冲突问题

参考：[在 GitHub 上解决合并冲突](https://docs.github.com/cn/enterprise-server@2.21/github/collaborating-with-pull-requests/addressing-merge-conflicts/resolving-a-merge-conflict-on-github)

1.在仓库名称下，单击 **拉取请求**。

2.在“Pull Requests（拉取请求）”列表中，单击含有您想要解决的合并冲突的拉取请求。

3.在拉取请求底部附近，单击 **Resolve conflicts（解决冲突）**。

**提示：**如果停用 **Resolve conflicts（解决冲突）**按钮，则拉取请求的合并冲突过于复杂而无法在 GitHub Enterprise Server 上解决，或站点管理员已禁用仓库之间拉取请求的冲突编辑器。 必须使用备用 Git 客户端或在命令行上使用 Git 解决合并冲突。 更多信息请参阅“[使用命令行解决合并冲突](https://docs.github.com/cn/enterprise-server@2.21/articles/resolving-a-merge-conflict-using-the-command-line)”。

4.决定您是否想只保持分支的更改、只保持其他分支的更改，还是进行全新的更改（可能包含两个分支的更改）。 删除冲突标记 `<<<<<<<`, `=======`, `>>>>>>>` 并在最终合并中进行所需的更改（**让AI帮你解决冲突**）。

5.如果文件中有多个合并冲突，请向下滚动到下一组冲突标记，然后重复步骤 4 和步骤 5 以解决合并冲突。

6.解决文件中的所有冲突后（**让AI帮你解决冲突**），单击 **Mark as resolved（标记为已解决）**。

7.如果您有多个冲突文件，请在“冲突文件”下的页面左侧选择您要编辑的下一个文件，并重复步骤 4 到 7，直到您解决所有拉取请求的合并冲突。

8.解决所有合并冲突后，单击 **Commit merge（提交合并）**。 这会将整个基本分支合并到头部分支。

9.如果出现提示，请审查您要提交的分支。 如果要提交到此分支，请单击 **I understand, update \*BRANCH\*（我已了解，请更新 BRANCH）**。

10.要合并拉取请求，请单击 **Merge pull request（合并拉取请求）**。 有关其他拉取请求合并选项的更多信息，请参阅“[合并拉取请求](https://docs.github.com/cn/enterprise-server@2.21/articles/merging-a-pull-request)”。

## fork后，GitHub action 自动拉取更新，当指定文件冲突时，保持当前分支版本

上传 `Fork-sync.yml` ，问 [gemini](https://gemini.google.com/app)：fork后，GitHub action 自动拉取更新，当指定文件冲突时，保持当前分支版本

既然你希望在同步 Fork 时，针对指定文件**永远保持你自己的版本（Ours）**，我们需要将之前的“以来源为准”逻辑反过来。

以下是针对 `LunaTV-config` 仓库实现“**全自动同步且保护本地配置**”的从头到尾完整教程。

------

### 第一阶段：本地环境准备

首先，我们需要在本地和云端定义一个“保持我方版本”的合并驱动。

1. **定义“保住自己”的合并驱动：**

   打开终端（Git Bash），执行以下命令：

   ```bash
   git config --global merge.ours.driver true
   ```

   > **原理：** `true` 是一个永远返回成功的命令。当 Git 遇到冲突并调用这个驱动时，它会认为“已经处理好了”，从而保留你本地当前分支的文件内容。

------

### 第二阶段：在项目中指定保护名单

你需要告诉 Git 哪些文件是“神圣不可侵犯”的，即同步时忽略上游的修改。

1. **创建/编辑 `.gitattributes`：**

   在项目根目录执行：

   ```bash
   touch .gitattributes
   ```

2. **写入保护规则：**

   使用编辑器打开 `.gitattributes`，输入你想保护的文件。例如：

   ```bash
   # 永远保留我自己的配置文件，不被上游覆盖
   README.md merge=ours
   report.md merge=ours
   
   # # 如果你想保护整个目录
   # my_private_configs/** merge=ours
   ```

------

### 第三阶段：配置 GitHub Action 自动化

为了让 GitHub 的服务器在自动同步时也遵守这个规则，我们需要修改你的 `Fork-sync.yml`。

1. 打开并编辑 `.github/workflows/Fork-sync.yml`，将内容替换为（如果有多个脚本，注意脚本执行先后顺序）：

```
name: Fork-sync

permissions:
  contents: write

on:
  schedule:
    - cron: "0 19 * * *"  # 每天北京时间凌晨3点运行
  workflow_dispatch:

jobs:
  sync_latest_from_upstream:
    name: Sync and Protect Local Configs
    runs-on: ubuntu-latest
    if: ${{ github.event.repository.fork }}

    steps:
      - name: Checkout target repo
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Configure Git & Ours Driver
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          # 关键：在 Action 服务器上激活 ours 驱动
          git config merge.ours.driver true

      - name: Sync upstream changes
        run: |
          # 添加上游
          git remote add upstream https://github.com/hafrey1/LunaTV-config.git
          git fetch upstream main
          
          # 执行合并。此时 .gitattributes 里标记为 merge=ours 的文件会无视上游修改
          git merge upstream/main --no-edit || (echo "检测到非受保护文件的核心冲突，需手动处理" && exit 1)

      - name: Push to origin
        run: |
          git push origin main

      - name: Delete workflow runs
        uses: Mattraks/delete-workflow-runs@main
        with:
          retain_days: 0
          keep_minimum_runs: 5
```

------

2. **提交并推送：**

```bash
git add .
git commit -m "chore: 配置同步时保护本地特定文件不被覆盖"
git push origin main
```

### 第四阶段：验证结果

1. **手动测试：** 在 GitHub 仓库的 **Actions** 页面，手动触发 **Fork-sync**。
2. **检查：** 观察日志中的 `Sync upstream changes` 步骤。
   - 如果上游修改了你 `.gitattributes` 中保护的文件，Action 会显示合并成功，但你检查该文件会发现**内容依然是你自己的**。
   - 这样你就实现了“既能拿到上游的新功能更新，又不会弄乱自己的私有配置”。

### 核心检查点

- **驱动名称一致性**：`.gitattributes` 里的 `merge=ours` 必须对应 `git config` 里的 `merge.ours.driver`。
- **文件路径**：确保 `.gitattributes` 中的文件路径书写正确（建议使用 `**/文件名` 来匹配所有层级的同名文件）。

**你会查看 `.gitattributes` 是否生效了吗？** 如果不确定，可以运行 `git check-attr -a <文件名>` 来核实。

##  GitHub 网页编辑器

1.打开方式：仓库页面按英文句号，或者将`https://github.com/iwyang/iwyang.github.io`改成`https://github.dev/iwyang/iwyang.github.io`

2.新建代码片段：左下角齿轮—代码片段—搜索并选择 `markdown.json`

3.粘贴以下配置：

```json
{
  "Hugo Article Front Matter": {
    "prefix": "wz",
    "body": [
      "---",
      "title: \"$1\"",
      "date: \"${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DATE}T${CURRENT_HOUR}:${CURRENT_MINUTE}:${CURRENT_SECOND}+08:00\"",
      "slug: \"$2\"",
      "description: \"$3\"",
      "lastmod: \"${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DATE}T${CURRENT_HOUR}:${CURRENT_MINUTE}:${CURRENT_SECOND}+08:00\"",
      "draft: false",
      "toc: true",
      "weight: false",
      "image: \"$4\"",
      "categories: [\"$5\"]",
      "tags: [\"$6\"]",
      "---",
      "",
      "$0"
    ],
    "description": "生成标准的博客文章 Front Matter (使用 tags 字段)"
  },

  "Hugo Shuoshuo Front Matter": {
    "prefix": "ss",
    "body": [
      "---",
      "title: \"$1\"",
      "date: \"${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DATE}T${CURRENT_HOUR}:${CURRENT_MINUTE}:${CURRENT_SECOND}+08:00\"",
      "slug: \"$2\"",
      "description: \"$3\"",
      "lastmod: \"${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DATE}T${CURRENT_HOUR}:${CURRENT_MINUTE}:${CURRENT_SECOND}+08:00\"",
      "draft: false",
      "toc: false",
      "weight: false",
      "image: \"$4\"",
      "categories: [\"$5\"]",
      "shuoshuotags: [\"$6\"]",
      "---",
      "",
      "$0"
    ],
    "description": "生成说说的专属 Front Matter (使用 shuoshuotags 字段)"
  }
}
```

4.**使用方法**：~~在新文件中输入 `sj` 然后按 `Tab` 键，它会自动生成生成完整的 Hugo Stack 标准 Front Matter（包含时区的标准日期）~~。~~PS：调不出，用下面**强制调用**~~

**强制调用：**左下角齿轮—命令面板（Ctrl+shirt+p）—搜索`Insert Snippet`—选择`代码片段：插入片段`—选择`wz`或者`ss`

5.同步设置：左下角齿轮—设置同步已打开

## **GitHub codespaces**(云端 VS Code)

### 新建codespaces

GitHub 提供免费的 **Codespaces**（云端 VS Code）。

1. 在你的 GitHub 仓库页面，点击绿色的 `<> Code` 按钮。
2. 选择 **Codespaces** 标签页 -> **Create codespace on main**。
3. 它会直接在浏览器里打开一个完整的 VS Code 编辑器，终端、插件一应俱全。
4. 你可以直接在浏览器终端里敲 `hugo server`，它甚至会给你生成一个预览链接！

**注意：用完关闭网页并没有关闭codespaces，要手动关闭，避免过多消耗免费额度。**

### 修改codespaces休眠时间

为了防止以后经常忘记关而浪费额度，你可以把这个默认的 30 分钟改成 **5 分钟** 甚至更短。

你可以通过以下步骤在 GitHub 的个人设置里全局修改它：

1. 点击 GitHub 右上角的头像，选择 **Settings**（设置）。
2. 在左侧边栏最底部的 "Code, planning, and automation" 区域，点击 **Codespaces**。
3. 找到 **Default idle timeout**（默认空闲超时）选项。
4. 在输入框里填入你想要的时间，比如输入 **`5`**（代表 5 分钟）。
5. 点击 **Save**（保存）。

### 勾选 “Auto-delete codespace”

点击右边三个点，选择`manage codespaces`，再点击右边三个点，勾选。

勾选 **“Auto-delete codespace”（自动删除 Codespace）** 意味着：当你停止（Shutdown）使用这个云端开发环境后，如果连续很长一段时间不去打开它，GitHub 会**自动帮你把这个环境彻底删除**。

### 修改 Codespaces 时区&&自动拉取更新

避免在codespaces里面自动构建hugo，出现时间显示不正常问题。

没问题，这就为你提供最稳妥、最详细的图文级操作指南。

因为 GitHub Codespaces 本质上是一台运行在云端的 Linux 虚拟机，我们需要通过一个配置文件来告诉这台机器：“请把系统时区设为北京时间”。

以下是具体步骤：

#### 第一步：找到或生成 `.devcontainer` 配置

我们需要在你的项目根目录下创建一个 `.devcontainer` 文件夹。如果你的项目里已经有这个文件夹和里面的 `devcontainer.json` 文件，请直接跳到第二步。

**如果没有，请让 Codespace 自动帮你生成：**

1. 在网页版 Codespace 界面，按下快捷键 **`Ctrl + Shift + P`**（Mac 用户按 `Cmd + Shift + P`），这会调出顶部的命令面板。
2. 在输入框里搜索并选择：**`Codespaces: Add Dev Container Configuration Files...`** (添加开发容器配置文件)。
3. 请选择第二个：**"Create a new configuration..."**（创建一个新配置）。
4. 接着选择：`Debian devcontainers`
5. 接着选择：第一个 `trixie (default)`即可。
6. 在当前的 **"Select Features"** 界面，你**不需要勾选任何项目**。

+ **直接点击右上角的蓝色“确定”按钮**（或者直接按回车键）。

+ 点击后，VS Code 会自动在你的项目左侧生成一个 **`.devcontainer`** 文件夹。

+ 文件夹里会有一个 **`devcontainer.json`** 文件，它会自动打开。

接下来如何修改代码（重点）：

打开那个 `devcontainer.json` 文件后，你会看到类似下面的代码。请找到合适的位置插入时区配置 `remoteEnv`。

**你可以直接把文件里的全部内容替换成下面这段代码：**

------

#### 第二步：修改 `devcontainer.json` 写入时区

点击打开 `.devcontainer/devcontainer.json` 文件。我们需要在里面加上 `remoteEnv` 参数。

假设你刚生成的文件内容如下，请在最后面**加一个英文逗号 `,`**，然后补上 `remoteEnv` 这三行代码（严格注意 JSON 格式）：

```json
{
    "name": "Debian",
    "image": "mcr.microsoft.com/devcontainers/base:debian",
    
    // 1. 设置环境变量：锁定北京时间
    "remoteEnv": {
        "TZ": "Asia/Shanghai"
    },

    // 2. 安装功能：自动安装 Git LFS (修复推送大文件报错)
    "features": {
        "ghcr.io/devcontainers/features/git-lfs:1": {}
    },

    // 3. 核心设置：每次打开或唤醒 Codespace 时，自动拉取最新代码
    "postStartCommand": "git pull origin develop"
}
```

*⚠️ 注意：如果你的大括号里原本就有其他配置（比如 `features` 或 `customizations`），记得在上一项的结尾加上英文逗号 `,`，否则 JSON 会报错。*

------

#### 第三步：重建容器让配置生效（最关键一步）

代码写好了，但云端电脑需要“重启”才能读取这个新配置。

1. 再次按下快捷键 **`Ctrl + Shift + P`** (Mac 为 `Cmd + Shift + P`)。
2. 在输入框里搜索并选择：**`Codespaces: Rebuild Container`** (重建容器)。
3. 此时网页右下角会提示正在 Rebuild，窗口可能会刷新一下。**别担心，这不会删除你写的文章或代码**，它只是在后台重置系统环境。
4. 等待一两分钟，右下角提示准备就绪即可。

**如果没有自动弹出 "Rebuild Now" 提示框，别担心，这是因为 VS Code 有时候反应比较慢。我们可以通过手动指令来强制它重新构建。**

请按照以下步骤操作：

#### 1. 确认文件已保存

首先确保你的 `.devcontainer/devcontainer.json` 已经保存（文件名上的白色小圆点消失了，或者按下 `Ctrl + S`）。

#### 2. 手动执行重建命令

1. 按下快捷键 **`Ctrl + Shift + P`** (Mac 用户是 `Cmd + Shift + P`)。
2. 在弹出的输入框里，输入单词：**`rebuild`**。
3. 在搜索结果中点击这一项：**`Codespaces: Rebuild Container`**。

#### 3. 等待过程完成

- 点击后，Codespace 会开始转圈，页面可能会提示“正在重新连接”。
- 这个过程大约需要 1-2 分钟，因为它正在按照你新写的“北京时间”规则重新配置这台云端电脑。

------

#### 验证是否成功

等它重新加载进入界面后，直接在最下方的 **Terminal（终端）** 里输入： `date` 然后回车。

- **如果显示：** `... CST 2026`（且小时数和你手机对得上），说明**大功告成**！
- **如果还是显示：** `... UTC 2026`，说明代码没写对，请把你的 `devcontainer.json` 文件内容截图发给我，我帮你检查。

------

#### 第四步：验证时间并刷新 Hugo

重建完成后，我们需要验证一下并且更新文章的 Git 记录：

1. **验证系统时间：** 在下方终端 (Terminal) 里输入 `date` 然后回车。如果输出的时间类似于 `Wed Feb 11 07:38:xx CST 2026`（显示 CST 或者与你当前时间一致），就说明时区修改成功了！
2. **更新你的说说：** 因为你的 Hugo Stack 主题是读取 **Git Commit 的时间** 作为“更新于”的时间的。你之前的那个 Commit 已经是 UTC 时间了。
   - 你只需要去那篇“碎碎念”的文章里，随便敲一个空格，然后保存。
   - 重新执行 `git add .` 和 `git commit -m "update time"`。
   - 这次的新 Commit 就会带上正确的北京时间戳了。

**你的项目中现在有 `.devcontainer` 文件夹吗？如果没有，要不要我一步步陪你调出命令面板生成它？**

### 新建代码片段

1.左下角齿轮—代码片段—搜索并选择 `markdown.json`

2.粘贴以下配置：

```json
{
  "Hugo Article Front Matter": {
    "prefix": "wz",
    "body": [
      "---",
      "title: \"$1\"",
      "date: \"${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DATE}T${CURRENT_HOUR}:${CURRENT_MINUTE}:${CURRENT_SECOND}+08:00\"",
      "slug: \"$2\"",
      "description: \"$3\"",
      "lastmod: \"${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DATE}T${CURRENT_HOUR}:${CURRENT_MINUTE}:${CURRENT_SECOND}+08:00\"",
      "draft: false",
      "toc: true",
      "weight: false",
      "image: \"$4\"",
      "categories: [\"$5\"]",
      "tags: [\"$6\"]",
      "---",
      "",
      "$0"
    ],
    "description": "生成标准的博客文章 Front Matter (使用 tags 字段)"
  },

  "Hugo Shuoshuo Front Matter": {
    "prefix": "ss",
    "body": [
      "---",
      "title: \"$1\"",
      "date: \"${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DATE}T${CURRENT_HOUR}:${CURRENT_MINUTE}:${CURRENT_SECOND}+08:00\"",
      "slug: \"$2\"",
      "description: \"$3\"",
      "lastmod: \"${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DATE}T${CURRENT_HOUR}:${CURRENT_MINUTE}:${CURRENT_SECOND}+08:00\"",
      "draft: false",
      "toc: false",
      "weight: false",
      "image: \"$4\"",
      "categories: [\"$5\"]",
      "shuoshuotags: [\"$6\"]",
      "---",
      "",
      "$0"
    ],
    "description": "生成说说的专属 Front Matter (使用 shuoshuotags 字段)"
  }
}
```

3.**使用方法**：~~在新文件中输入 `sj` 然后按 `Tab` 键，它会自动生成生成完整的 Hugo Stack 标准 Front Matter（包含时区的标准日期）~~。~~PS：调不出，用下面**强制调用**~~

**强制调用：**左下角齿轮—命令面板（Ctrl+shirt+p）—搜索`Insert Snippet`—选择`代码片段：插入片段`—选择`wz`或者`ss`

4.同步设置：左下角齿轮—设置同步已打开

## fork后，GitHub action 自动拉取更新，当指定文件冲突时，使用来源分支版本

既然你希望在 GitHub Action 自动同步 Fork 时，遇到冲突直接**使用来源分支（上游/对方）**的版本，我们需要配置 `theirs` 策略。这通常用于你希望某些文件（如 `nodes` 或 `configs`）始终紧跟上游更新，而不保留你本地的修改。

以下是针对 `LunaTV-config` 仓库实现“**全自动同步且冲突时以来源为准**”的从头到尾完整指南。

------

### 第一阶段：本地环境配置

由于 Git 默认没有内置名为 `theirs` 的自动合并驱动，我们必须手动定义一个。

1. **定义“以来源为准”的合并驱动：**

   打开终端（Git Bash），执行以下命令：

   ```bash
   git config --global merge.keep_theirs.driver "cat %B > %A"
   ```

   > **原理：** `%B` 代表来源（上游）文件，`%A` 代表本地文件。该命令会将上游内容直接覆盖到本地。

------

### 第二阶段：在项目中指定自动覆盖名单

你需要通过 `.gitattributes` 文件告诉 Git 哪些文件在冲突时应该触发这个驱动。

1. **创建属性文件：**

   在项目根目录下执行：

   ```bash
   touch .gitattributes
   ```

2. **写入匹配规则：**

   打开 `.gitattributes`，根据你的需求（例如始终同步 `nodes` 文件夹）输入：

   ```bash
   # 针对特定目录或文件，冲突时永远采用对方的版本
   nodes/** merge=keep_theirs
   configs/** merge=keep_theirs
   *.json merge=keep_theirs
   ```

------

### 第三阶段：配置 GitHub Actions 自动化

这是最关键的一步。由于 GitHub Action 运行环境是临时的，它不知道你本地的 `git config`。我们必须在脚本中注入驱动定义。

1. 修改 `.github/workflows/Fork-sync.yml`：

   将你之前上传的文件内容替换为以下原生 Git 逻辑：

```yaml
name: Fork-sync

permissions:
  contents: write

on:
  schedule:
    - cron: "0 17 * * *"  # 每天北京时间凌晨1点运行
  workflow_dispatch:

jobs:
  sync_latest_from_upstream:
    name: Sync latest commits from upstream repo
    runs-on: ubuntu-latest
    if: ${{ github.event.repository.fork }}

    steps:
      - name: Checkout target repo
        uses: actions/checkout@v4
        with:
          fetch-depth: 0 # 获取完整历史以支持合并

      - name: Configure Git & Merge Driver
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          # 关键：在云端服务器注入 keep_theirs 驱动定义
          git config merge.keep_theirs.driver "cat %B > %A"

      - name: Sync upstream changes
        run: |
          # 添加 LunaTV 原始仓库作为上游
          git remote add upstream https://github.com/hafrey1/LunaTV-config.git
          git fetch upstream main
          
          # 执行合并。Git 会读取 .gitattributes 并在冲突时调用 keep_theirs 驱动
          git merge upstream/main --no-edit || (echo "检测到非规则内的核心冲突，需手动干预" && exit 1)

      - name: Push to origin
        run: |
          # 将合并后的最新版本推送到你自己的仓库
          git push origin main

      - name: Delete workflow runs
        uses: Mattraks/delete-workflow-runs@main
        with:
          retain_days: 0
          keep_minimum_runs: 5
```

------

2. **提交并推送：**

```bash
git add .
git commit -m "chore: 配置冲突时自动以来源分支为准"
git push origin main
```

### 第四阶段：解决推送拒绝（non-fast-forward）

**如果**你在推送时遇到 `[rejected] main -> main (non-fast-forward)` 错误，说明你本地和远程的提交历史不一致。

**解决方法：**

1. **强制同步远程改动：**

   Bash

   ```
   git fetch origin
   git merge origin/main -X ours  # 这里的 -X ours 是为了确保在合并远程时先保住你刚写的 .gitattributes
   ```

2. **重新推送：**

   Bash

   ```
   git push origin main
   ```

------

### 总结与验证

- **验证驱动：** 运行 `git check-attr -a package-lock.json`（或任意你规则里的文件），如果输出包含 `merge: keep_theirs`，说明规则已识别。
- **手动测试：** 在 GitHub 仓库的 **Actions** 页面手动点击 **Run workflow**。如果运行成功且日志显示 `Merge made by the 'recursive' strategy`，则说明自动化忽略冲突已生效。

**你会操作了吗？** 如果运行 Action 时出现红色报错，请把报错日志发给我，我来帮你分析。

## 多 Git 仓库的 SSH-key 配置

**PS:未测试**

### 配置多 SSH key

#### 1. 添加 RSA key

仍然使用命令

```
ssh-keygen -t rsa -c "your@email.com"
```

生成 RSA 密钥对，但在接下来的选项中指定一个不同的文件名，例如：

```
Enter file in which to save the key (/Users/userName/.ssh/id_rsa): /Users/userName/.ssh/new_rsa
```

这样就在 `~/.ssh` 目录下生成了一对新的 RSA 密钥：`new_rsa` 和 `new_rsa.pub`.

#### 2. 密钥配置

生成了新的密钥后，便可将新密钥成功添加到第二个 GitHub 账号. 但此时向第二个 Github 仓库推送更新仍然会显示无权限，因为若不经配置系统默认仍使用默认的密钥对 `id_rsa`.

需要如下配置：

在密钥目录 `~/.ssh/` 下编辑或新建配置文件 `config`，添加如下内容：

```yaml
Host github.com
  HostName github.com
  IdentityFile ~/.ssh/id_rsa
  User git


Host alias
  HostName github.com
  IdentityFile ~/.ssh/new_rsa
  User git
```

理解其中配置项就可以灵活配置更多的 SSH key 了：

- `Host` 是我们**自己定义**的一个别名，用来更方便地指代 `HostName`.
- `HostName` 是远程地址的域名，需要正确配置.
- `IdentityFile` 指定使用该配置项中的域名（或别名）时所使用的密钥文件.
- `User` 使用 SSH 时的用户名，对于远程 Git 仓库来说一般使用 `git`.

以上第一个配置项，使域名为 `github.com` 的仓库默认使用 `id_rsa` 密钥对，第二个配置项为地址中使用了别名 `alias` 的仓库使用 `new_rsa` 密钥对

#### 3. 使用别名配置仓库的远程地址

配置完以上内容后，当我们使用 `alias` 作为登陆地址时会使用指定的 `new_rsa` 密钥，否则仍默认使用 `id_rsa` 密钥，因此我们需要对想要使用 `new_rsa` 密钥的仓库地址做修改. 例如：

对于仓库地址为

```
git@github.com:user_name/repository_name.git
```

的 GitHub 远程仓库，我们推送更新时系统仍默认使用 `id_rsa` 密钥，若想使用 `new_rsa` 密钥则需修改地址为：

```
git@alias:user_name/repository_name.git
```

### 其他

- 对于 Windows 用户需要注意 `.ssh` 目录的路径
- config 不生效的话检查语法或尝试重启终端或设备后重试
- 对于更多的密钥配置在 `~/.ssh/config` 文件中同理追加更多配置项即可

参考链接：

[1.解决 Failed to connect to github.com port 443](https://blog.csdn.net/Hodors/article/details/103226958)

[2.解决ssh: connect to host github.com port 22](https://blog.csdn.net/MBuger/article/details/70226712)

[3.多 Git 仓库的 SSH-key 配置](https://www.hozen.site/archives/43/)



