---
title: 利用Github Actions自动同步Fork&&自动同步Releases
categories:
  - 技术
tags:
  - github
comments: true
cover: /img/cover/github-action.jpg
slug: 12dd937c
date: 2023-07-13 18:02:15
sticky:
keywords:
description:
top_img:
---

## 自动同步Fork

在你的 fork 仓库中新建：

```yaml
.github/workflows/sync.yml
```

内容如下（免填上游地址）：

```yaml
name: Scheduled Repo Sync

on:
  schedule:
    - cron: '0 0 * * *'
  workflow_dispatch:

permissions:
  contents: write # 自动赋予仓库写入权限

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Sync Fork with Upstream
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh repo sync "${{ github.repository }}" --force
```



## 自动同步Releases

1.创建新的workflow，在仓库右上角点`Add file`，先输入`workflows`文件夹名，再点击空白位置，自动进入下一目录，然后输入文件名`Sync Upstream Releases.yaml`。接着

在`Sync Upstream Releases.yaml`输入里面的内容：**(注意修改`UPSTREAM_OWNER`和`UPSTREAM_REPO`,上游仓库拥有者和仓库名称)**

```yaml
# 同步上游仓库全部 release（包括最新版）
# 说明：
# - 会分页获取上游仓库的所有 releases（per_page=100），逐个检查本仓库是否已有相同 tag。
# - 若本仓库不存在该 tag 的 release，则会：
#     1) 下载上游 release 的所有 assets（放到 upstream-assets/<tag>/）
#     2) 通过 GitHub Releases API 在当前仓库创建同名 release（保留 name、body、draft、prerelease）
#     3) 上传对应的 assets 到新创建的 release
# - 定时与手动触发均支持。请确保本仓库的 secrets.GITHUB_TOKEN 有权限创建 release 与上传资产。
name: Sync Upstream Releases

on:
  workflow_dispatch: {}
  schedule:
    - cron: "0 0 * * *" # every day

concurrency:
  group: sync-upstream-releases
  cancel-in-progress: false

jobs:
  sync-releases:
    runs-on: ubuntu-latest
    env:
      UPSTREAM_OWNER: Decohererk
      UPSTREAM_REPO: DecoTV
      PER_PAGE: "100"
    steps:
      - name: Checkout repo (needed for GitHub context)
        uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt-get update -y
          sudo apt-get install -y jq

      - name: Sync all upstream releases to this repo
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITHUB_REPOSITORY: ${{ github.repository }}
        run: |
          set -euo pipefail

          UPSTREAM="${UPSTREAM_OWNER}/${UPSTREAM_REPO}"
          echo "Syncing releases from $UPSTREAM into ${GITHUB_REPOSITORY}"
          mkdir -p upstream-assets

          page=1
          while true; do
            echo "Fetching releases page $page"
            releases=$(curl -s -H "Authorization: token $GH_TOKEN" \
              "https://api.github.com/repos/${UPSTREAM_OWNER}/${UPSTREAM_REPO}/releases?per_page=${PER_PAGE}&page=${page}")

            # 如果本页没有条目则结束
            count=$(echo "$releases" | jq 'length')
            if [ "$count" -eq 0 ]; then
              echo "No more releases (page $page empty)."
              break
            fi

            echo "Processing $count releases from page $page"
            echo "$releases" | jq -c '.[]' | while read -r rel; do
              tag_name=$(echo "$rel" | jq -r '.tag_name')
              # 防止空 tag
              if [ -z "$tag_name" ] || [ "$tag_name" = "null" ]; then
                echo "Skipping release with empty tag"
                continue
              fi

              release_name=$(echo "$rel" | jq -r '.name // ""')
              release_body=$(echo "$rel" | jq -r '.body // ""')
              draft=$(echo "$rel" | jq -r '.draft')
              prerelease=$(echo "$rel" | jq -r '.prerelease')

              echo "Checking tag $tag_name..."
              status_code=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GH_TOKEN" \
                "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/tags/${tag_name}")

              if [ "$status_code" -eq 200 ]; then
                echo "Release with tag $tag_name already exists in ${GITHUB_REPOSITORY}, skipping."
                continue
              fi

              echo "Downloading assets for $tag_name (if any)..."
              safe_dir="upstream-assets/$(echo "$tag_name" | sed 's/[^A-Za-z0-9._-]/_/g')"
              mkdir -p "$safe_dir"
              echo "$rel" | jq -r '.assets[]?.browser_download_url' | while read -r asset_url; do
                if [ -z "$asset_url" ] || [ "$asset_url" = "null" ]; then
                  continue
                fi
                fname=$(basename "$asset_url")
                echo "  - Downloading $fname"
                # 使用 -L 跟随重定向
                curl -sL -H "Authorization: token $GH_TOKEN" "$asset_url" -o "${safe_dir}/${fname}"
              done

              echo "Creating release $tag_name in ${GITHUB_REPOSITORY}..."
              # 构造 payload（保留 draft & prerelease）
              payload=$(jq -nc --arg tag "$tag_name" --arg name "$release_name" --arg body "$release_body" \
                --argjson draft "$draft" --argjson prerelease "$prerelease" \
                '{ tag_name: $tag, name: $name, body: $body, draft: $draft, prerelease: $prerelease }')

              create_resp=$(curl -s -H "Authorization: token $GH_TOKEN" -H "Accept: application/vnd.github.v3+json" \
                -d "$payload" "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases")

              upload_url=$(echo "$create_resp" | jq -r '.upload_url // empty')
              message=$(echo "$create_resp" | jq -r '.message // empty')

              if [ -z "$upload_url" ]; then
                echo "Failed to create release for $tag_name: $message"
                # 继续处理下一个 release，而不是退出整个流程
                continue
              fi

              echo "Upload URL obtained. Uploading assets for $tag_name..."
              if compgen -G "${safe_dir}/*" > /dev/null; then
                for f in "${safe_dir}"/*; do
                  [ -f "$f" ] || continue
                  fname=$(basename "$f")
                  echo "  - Uploading $fname ..."
                  # upload_url 包含 "{?name,label}"，去掉括号部分并附加 ?name=...
                  upload_endpoint="${upload_url%\{*}?name=${fname}"
                  curl -s --fail -X POST -H "Authorization: token $GH_TOKEN" \
                    -H "Content-Type: application/octet-stream" --data-binary @"$f" "$upload_endpoint" \
                    || echo "    Warning: failed to upload asset $fname for $tag_name"
                done
              else
                echo "  - No assets to upload for $tag_name."
              fi

              echo "Release $tag_name created successfully (if no errors above)."

            done

            page=$((page + 1))
          done

          echo "All pages processed."
```

2.手动运行`Action`里面的`Sync Upstream Releases`

## 新建一仓库专门备份Releases 

### 新建脚本生成release-sync.yml

1.新建仓库：https://github.com/iwyang/backup

2.本地任意一文件夹新建脚本：`setup_backup.sh`，双击运行，它会帮你自动创建Workflow 文件，并将源码上传到指定仓库。

**PS：双击第一次会闪退，要双击第二次**，第一次上传部署成功后，以后只用在网页修改`release-sync.yml`，增加备份仓库信息即可。

```bash
name: Release Sync
permissions:
  contents: write

on:
  push:
    branches: 
      - main
  workflow_dispatch:
    inputs:
      force_resync:
        description: '是否强制重新同步所有项目'
        required: false
        default: 'false'
  schedule:
    - cron: '0 3 * * *'

jobs:
  sync-by-real-time:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Time-Travel Sync
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          FORCE_SYNC: ${{ github.event.inputs.force_resync }}
        run: |
          # 定义项目列表：格式为 "上游仓库|本地别名"
          repos=(
            "2dust/v2rayN|v2rayN"
            "2dust/v2rayNG|v2rayNG"
            "orion-lib/OrionTV|OrionTV"
            "zbezj/HEU_KMS_Activator|HEU_KMS"
            "eritpchy/FingerprintPay|FingerprintPay"
            "connectbot/connectbot|connectbot"
            "koreader/koreader|koreader"
            "Dr-TSNG/ZygiskNext|ZygiskNext"
            "JingMatrix/LSPosed|LSPosed"
            "Xposed-Modules-Repo/com.y7.fingerpay|com.y7.fingerpay"
            "twoone-3/AdGuardHomeForRoot|AdGuardHomeForRoot"
          )

          echo "正在获取各项目原作者发布时间..."
          rm -f repo_list.txt
          for item in "${repos[@]}"; do
            src=$(echo "$item" | cut -d'|' -f1)
            alias=$(echo "$item" | cut -d'|' -f2)
            # 获取上游最新发布的发布时间
            pub_date=$(gh release view "$src" --json publishedAt --jq .publishedAt 2>/dev/null || echo "1970-01-01T00:00:00Z")
            echo "$pub_date|$src|$alias" >> repo_list.txt
          done

          # 【降序排列】：加入 -r 参数，按照时间从新到旧处理，确保最新版排在最上面
          sort -t'|' -k1,1 -r repo_list.txt -o repo_list_sorted.txt
          
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

          total_items=$(wc -l < repo_list_sorted.txt)
          current_index=0

          while IFS='|' read -r date src alias; do
            current_index=$((current_index + 1))
            echo "=========================================="
            echo "正在处理 [$current_index/$total_items]: $alias (原作者更新于: $date)"
            
            # 获取上游最新的 Tag 名
            ORIGINAL_TAG=$(gh release view --repo "$src" --json tagName --jq .tagName)
            NEW_TAG="${alias}-${ORIGINAL_TAG}"

            # 检查本地是否已经存在该版本（如果不是强制同步）
            if [ "$FORCE_SYNC" != "true" ]; then
              if gh release view "$NEW_TAG" > /dev/null 2>&1; then
                echo "跳过已存在的最新版: $alias ($ORIGINAL_TAG)"
                continue
              fi
            fi

            # ==== 清理该项目的所有历史 Release 和 Tag ====
            echo "正在清理 [$alias] 的所有历史旧版本..."
            OLD_TAGS=$(gh release list --limit 100 --json tagName --jq ".[].tagName" | grep "^${alias}-" || true)
            for OLD_TAG in $OLD_TAGS; do
              echo "删除旧版本: $OLD_TAG"
              gh release delete "$OLD_TAG" --yes --cleanup-tag 2>/dev/null || true
            done
            gh release delete "$NEW_TAG" --yes --cleanup-tag 2>/dev/null || true

            # 【时间穿越】：注入原始发布时间到 Git 提交
            export GIT_AUTHOR_DATE="$date"
            export GIT_COMMITTER_DATE="$date"

            git commit --allow-empty -m "Release $alias $ORIGINAL_TAG"
            git pull --rebase origin main || true
            git push origin main
            
            # 下载上游资源
            mkdir -p ./temp_assets && rm -rf ./temp_assets/*
            gh release download "$ORIGINAL_TAG" --repo "$src" --pattern "*" --dir ./temp_assets || echo "此版本无资源文件可供下载"
            
            # ==== 核心修改：获取 Release 标题和正文（更新日志） ====
            # 一次性获取标题(name)和内容(body)
            RELEASE_INFO=$(gh release view "$ORIGINAL_TAG" --repo "$src" --json name,body)
            TITLE=$(echo "$RELEASE_INFO" | jq -r .name)
            UPSTREAM_BODY=$(echo "$RELEASE_INFO" | jq -r .body)

            if [ -z "$TITLE" ] || [ "$TITLE" == "null" ]; then
              TITLE="$ORIGINAL_TAG"
            fi
            
            CLEAN_DATE=$(echo "$date" | tr 'T' ' ' | tr -d 'Z')
            SYNC_TIME=$(date '+%Y-%m-%d %H:%M:%S')
            
            # 生成新的发布说明：包含元数据和原始更新日志，并使用 details 标签折叠
            cat << EOF > release_notes.md
**Upstream Release:** [🔗 $src@$ORIGINAL_TAG](https://github.com/$src/releases/tag/$ORIGINAL_TAG) | **Upstream Update:** $CLEAN_DATE | **Sync Date:** $SYNC_TIME

---

<details>
<summary><b>点击展开 / 折叠原作者更新日志</b></summary>

$UPSTREAM_BODY

</details>
EOF
            # ========================================================

            # 创建新的 Release (由于是降序排列，第一个处理的即为最新，打上 latest 标签)
            if [ "$current_index" -eq 1 ]; then
              echo "创建并标记为最新的 Release..."
              gh release create "$NEW_TAG" ./temp_assets/* \
                --title "[$alias] $TITLE" \
                --notes-file release_notes.md \
                --latest
            else
              echo "创建 Release..."
              gh release create "$NEW_TAG" ./temp_assets/* \
                --title "[$alias] $TITLE" \
                --notes-file release_notes.md \
                --latest=false
            fi
            
            echo "$alias 同步完成！"
            sleep 2
          done < repo_list_sorted.txt
```

### 直接新建`release-sync.yml`

```yaml
name: Release Sync
permissions:
  contents: write

on:
  push:
    branches: 
      - main
  workflow_dispatch:
    inputs:
      force_resync:
        description: '是否强制重新同步所有项目'
        required: false
        default: 'false'
  schedule:
    - cron: '0 3 * * *'

jobs:
  sync-by-real-time:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Time-Travel Sync
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          FORCE_SYNC: ${{ github.event.inputs.force_resync }}
        run: |
          repos=(
            "2dust/v2rayN|v2rayN"
            "2dust/v2rayNG|v2rayNG"
            "orion-lib/OrionTV|OrionTV"
            "zbezj/HEU_KMS_Activator|HEU_KMS"
            "eritpchy/FingerprintPay|FingerprintPay"
            "connectbot/connectbot|connectbot"
            "koreader/koreader|koreader"
            "Dr-TSNG/ZygiskNext|ZygiskNext"
            "JingMatrix/LSPosed|LSPosed"
            "Xposed-Modules-Repo/com.y7.fingerpay|com.y7.fingerpay"
            "twoone-3/AdGuardHomeForRoot|AdGuardHomeForRoot"
          )

          echo "正在获取各项目原作者发布时间..."
          rm -f repo_list.txt
          for item in "${repos[@]}"; do
            src=$(echo "$item" | cut -d'|' -f1)
            alias=$(echo "$item" | cut -d'|' -f2)
            # 获取发布时间
            pub_date=$(gh release view --repo "$src" --json publishedAt --jq .publishedAt 2>/dev/null || echo "1970-01-01T00:00:00Z")
            echo "$pub_date|$src|$alias" >> repo_list.txt
          done

          # 核心修改：使用 -r 倒序排序（按时间从新到旧），确保最新的版本最先被处理并固定在顶部
          sort -t'|' -k1,1 -r repo_list.txt -o repo_list_sorted.txt
          
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

          total_items=$(wc -l < repo_list_sorted.txt)
          current_index=0

          while IFS='|' read -r date src alias; do
            current_index=$((current_index + 1))
            echo "=========================================="
            echo "正在处理 [$current_index/$total_items]: $alias"
            
            ORIGINAL_TAG=$(gh release view --repo "$src" --json tagName --jq .tagName)
            NEW_TAG="${alias}-${ORIGINAL_TAG}"

            if [ "$FORCE_SYNC" != "true" ]; then
              if gh release view "$NEW_TAG" > /dev/null 2>&1; then
                echo "跳过已存在的版本: $alias ($ORIGINAL_TAG)"
                continue
              fi
            fi

            # 清理旧版本
            OLD_TAGS=$(gh release list --limit 100 --json tagName --jq ".[].tagName" | grep "^${alias}-" || true)
            for OLD_TAG in $OLD_TAGS; do
              gh release delete "$OLD_TAG" --yes --cleanup-tag 2>/dev/null || true
            done
            gh release delete "$NEW_TAG" --yes --cleanup-tag 2>/dev/null || true

            # 时间穿越提交
            export GIT_AUTHOR_DATE="$date"
            export GIT_COMMITTER_DATE="$date"
            git commit --allow-empty -m "Release $alias $ORIGINAL_TAG"
            git pull --rebase origin main || true
            git push origin main
            
            # 下载资源
            mkdir -p ./temp_assets && rm -rf ./temp_assets/*
            gh release download "$ORIGINAL_TAG" --repo "$src" --pattern "*" --dir ./temp_assets || echo "此版本无资源文件可供下载"
            
            # 获取标题和更新日志
            RELEASE_JSON=$(gh release view "$ORIGINAL_TAG" --repo "$src" --json name,body)
            TITLE=$(echo "$RELEASE_JSON" | jq -r .name)
            [ -z "$TITLE" ] || [ "$TITLE" == "null" ] && TITLE="$ORIGINAL_TAG"
            
            echo "$RELEASE_JSON" | jq -r .body > upstream_body.txt
            
            CLEAN_DATE=$(echo "$date" | tr 'T' ' ' | tr -d 'Z')
            SYNC_TIME=$(date '+%Y-%m-%d %H:%M:%S')
            
            # 生成 release_notes.md，并将更新日志放入折叠块中
            echo "**Upstream Release:** [🔗 $src@$ORIGINAL_TAG](https://github.com/$src/releases/tag/$ORIGINAL_TAG) | **Upstream Update:** $CLEAN_DATE | **Sync Date:** $SYNC_TIME" > release_notes.md
            echo -e "\n---\n" >> release_notes.md
            echo "<details>" >> release_notes.md
            echo "<summary><b>点击展开 / 折叠原作者更新日志</b></summary>" >> release_notes.md
            echo "" >> release_notes.md
            cat upstream_body.txt >> release_notes.md
            echo "" >> release_notes.md
            echo "</details>" >> release_notes.md

            # 核心修改：由于现在是最新的排在最前面，所以当 current_index 为 1 时打上 latest 标签
            LATEST_FLAG="--latest=false"
            if [ "$current_index" -eq 1 ]; then
              LATEST_FLAG="--latest"
            fi

            # 资产附件检测：如果有文件则上传，没文件则仅创建 Release
            ASSET_COUNT=$(ls -A ./temp_assets | wc -l)
            if [ "$ASSET_COUNT" -gt 0 ]; then
              echo "正在创建 Release 并上传 $ASSET_COUNT 个附件..."
              gh release create "$NEW_TAG" ./temp_assets/* \
                --title "[$alias] $TITLE" \
                --notes-file release_notes.md \
                $LATEST_FLAG
            else
              echo "未发现附件，仅创建 Release 页面..."
              gh release create "$NEW_TAG" \
                --title "[$alias] $TITLE" \
                --notes-file release_notes.md \
                $LATEST_FLAG
            fi
            
            echo "$alias 同步完成！"
            sleep 2
          done < repo_list_sorted.txt
```

更新代码后，去网页端点 **Run workflow**，把 `force_resync` 填为 **`true`**，跑一次。

## 参考链接

+ [GithunActionAutoSync2Gitee](https://knight.abn-team.top/2023/03/29/GithunActionAutoSync2Gitee/)
+ [利用Github Actions自动同步Fork](https://zhuanlan.zhihu.com/p/500768626)
+ [fork-sync](https://github.com/tgymnich/fork-sync)
