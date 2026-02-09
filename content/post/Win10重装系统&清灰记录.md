---
title: Win10重装系统&清灰记录&整机&护眼
categories:
  - 技术
tags:
  - win10
slug: 88857f5f
date: 2020-05-24 06:36:25
cover: false
---

<div class="note primary">Fn+F2进入bios，Fn+F12选择启动顺序。</div> 

### ~~原版系统~~

1. ~~备份E盘文件到移动硬盘。~~  

2. ~~进PE，这里使用[微pe工具箱](http://www.wepe.com.cn/)。~~

3. ~~将系统iso文件装载到虚拟光驱，然后运行`setup.exe`~~
   + 先删掉所有分区，然后给C盘分区，大小为：82703M（80*1024+100+16+567+100=82703）
   
   + 安装完系统再用系统自带磁盘管理给D盘和E盘分区，D盘大小为：71780M（70*1024+100=71780），剩下的给E盘。

### 精简系统

1. 备份E盘文件到移动硬盘。
2. 进PE，这里使用[微pe工具箱](http://www.wepe.com.cn/)。
3. 用DiskGenius分区，C盘80G，D盘70G，剩余给E盘。注意给C盘分区时，勾选`建立ESP分区`和`建立MSR分区`，勾选`对齐到此扇区的整数倍`，选择`2048扇区`。给D盘和E盘分区时也要勾选对齐到`2048扇区`。
4. 用windows安装器安装系统。注意`选择安装驱动器的位置`为`C盘`，还有选择相应的安装版本。

### 系统安装记录

| 序号 |   日期    |    版本    |
| :--: | :-------: | :--------: |
|  5   | 2025.2.17  | win11 24H2 |
|  4   | 2023.2.19  | win11 22H2 |
|  3   | 2022.3.4  | win10 21H2 |
|  2   | 2021.8.29 | win10 21H1 |
|  1   | 2020.5.24 | win10 2004 |


### 笔记本清灰记录

| 序号 |   日期    |         备注         |
| :--: | :-------: | :------------------: |
|  1   | 2020.6.18 | 风扇都没有拆下来清理 |
|  2   | 2022.3.5  |                      |

### 常见问题

~~0.办公室旧电脑安装精简版Win7，出现错误`Windows could not start the installation process`，解决方法：删除分区，重新分区。~~

**1.MSVCP120.dll错误**

重新安装Visual C++ 2013运行库
这是解决MSVCP120.dll问题最彻底的方法。访问微软官方网站下载vcredist_x86.exe（32位系统）或vcredist_x64.exe（64位系统），运行安装程序并按照提示完成安装。安装完成后建议重启计算机以确保所有更改生效。

### 整机

`2022年3月13号购入`

0.分区：C盘100G D盘200G E盘剩下

1.微星主板按`F11`选择启动顺序，按`Delete`进入bios。

~~2.蓝宝石北极狐机箱尺寸：392×185×303（长×宽×高 mm）~~

机箱玻璃摔破了，新机箱尺寸：335×182×423 MM

包装尺寸：460×231×390MM

3.AOC 23.8寸显示器尺寸：长550mm，宽200mm,高430mm

4.aoc键盘 446×143×34

5.调显存大小，重启黑屏。解决方法：拔掉主板电池（拔掉电池的方法见bibi收藏夹，直接将挡板往外按，电池会自动弹起。注意不要用手挡住电池，否则电池无法弹出），5分钟后再装上去。买之前 应该说清楚，不用搞高频，正常使用就好；不用调显存大小，默认就行。默认内建显示配置：

```
Initiate Graphic Adapter   [PEG]
Integrated Graphics        [Game Mode]
UMA Frame Butter Size      [自动]
```

估计是直接将显存由`4g`直接改成`自动`，第二项没有设置为`Game Mode`而导致黑屏，无法点亮。



### 护眼模式

一、显示设置—夜间模式强度调到30左右。

二、调整颜色：



1、鼠标右键点击【开始】菜单按钮选择【运行】，
2、输入 regedit 点击【确定】，
3、展开注册表路径至：HKEY_CURRENT_USER\Control Panel, 点击【Colors】文件夹，
4、在右侧找到 Window，鼠标右击【Window】选择【修改】，
5、将数值数据改为【202 234 206】（豆沙绿）点击【确定】，（初始：255 255 255）

6、定位：`HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\DefaultColors\Standard`，找到Window，双击Window，更改数值：`caeace` (默认值为ffffff)，选择：十六进制

7、重启电脑，设置生效。

三、右键—个性化—颜色—浅色—打开透明效果—自定义颜色（202 234 206)—勾选`在标题栏和窗口边框`显示主颜色。



三、浏览器安装保护眼睛插件。[保护眼睛](https://chrome.google.com/webstore/detail/eye-protector/fgadnbmmolnmbkbklpaojbogcopipopl)

### 常见问题

Windows开始菜单绝对路径：`C:\ProgramData\Microsoft\Windows\Start Menu\Programs`
