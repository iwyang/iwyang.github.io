---
title: 彻底卸载onedrive
categories:
  - 技术
tags:
  - win10
comments: true
cover: /img/cover/onedrive.jpg
abbrlink: e0c4249b
date: 2023-09-03 20:41:26
sticky:
keywords:
description:
top_img:
---

1、通过组策略编辑器来禁用OneDrive。点击任务栏上的Contana搜索框并输入“组策略”，在最佳匹配结果中选择“编辑组策略”控制面板项，进入到本地组策略编辑器环境，如图：

2、在组策略编辑器窗口左侧栏内，依次定位到“计算机配置→管理模板→Windows组件→OneDrive”，可看到右侧窗格内的5个相关选项，如图所示：

3、将右侧的5个选项并将它们设置为“已禁用”状态，如图：

4、右键单击任务栏空白处，调出任务管理器。切换到“启动”。在进程管理列表中找到OneDrive进程，右键单击并选择“禁用”。

随后，在Windows资源管理器中，点击“查看”功能面板，将“显示/隐藏”分组中的“隐藏的项目”复选框选中。最后进入到当前Windows用户所在的“AppData→Local→Microsoft”文件夹，找到Onedrive子文件夹，将其删除即可。

若无法直接删除，可利用Unlocker工具或360右键强力删除命令进行删除。

参考：[教你彻底卸载OneDrive图文操作方法](https://office.tqzw.net.cn/computer/computer/229566.html)
