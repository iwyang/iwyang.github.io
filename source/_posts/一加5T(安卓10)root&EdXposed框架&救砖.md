---
title: 一加5T(安卓10)root&EdXposed框架&救砖
categories:
  - 技术
tags:
  - tips
abbrlink: a2a9d239
date: 2020-07-10 10:34:25
cover: false
---

 首先保障手机已解锁，一加5T解锁教程：[一加5T解锁、root、刷机教程](https://www.oneplusbbs.com/forum.php?mod=viewthread&tid=3829403)

## root&EdXposed框架

1. 准备以下6个文件

注意要先把2—6号文件放在手机根目录（如果放在文件夹里，文件夹名不能有中文）。

1. 一加手机5T工具箱 _2.2.1
2. twrp-3.3.1-0-dumpling.img  （第三方recovery镜像）
3. Magisk-v20.4(20400).zip （集root管理、模块安装等功能）
4. MM管理器(叶子修改版)v1.8.zip 

<div class="note info">可在TWRP下对Magisk模块进行管理、卸载。一定要先安装这个，再安装EdXposed的两个模块，防止安装模块后手机变砖无法开机，这时就可以通过MM管理器来删除安装的模块，使用方法：在第三方rec下，点击高级→终端，输入/data/media/mm，然后回车，就可以禁用该模块了。</div>

5. Riru_(Riru_-_Core)-v21.2(35).zip和Riru_-_EdXposed-v0.4.6.1_(4510)_(YAHFA)(4510).zip （EdXposed两个模块包）

6. EdXposedManager.apk （EdXposed管理器）

2. 刷入第三方recover&root

+ 打开一加手机5T工具箱，选择选项8—刷写自选Recovery，按照提示把下载好的rec拖入工具箱随后回车刷入。（如果无法拖入，直接输入rec路径即可）
+ 刷完会自动进入第三方Recovery（TWRP），这时候可以一次性选择2—5号文件刷入，当然如果只想root则只用刷入Magisk。
+ `root`后可以利用`link2sd`这个软件，冻结或者卸载系统应用，安卓10好像只能冻结，卸载不了。具体使用方法，例如：搜索更新，将自动更新冻结，以后就收不到更新了。

3. 刷入EdXposed模块

选择MM管理器以及两个模块刷入。（如果模块无法刷入，可能是命名格式问题，将模块重命名为1.zip、2.zip即可，同理上面Magisk无法刷入，也重命名一下；实在不行就在`Magisk`里刷入模块）

4. 安装EdXposed管理器

   重启手机安装EdXposed管理器。之后就是安装各种使用的模块了。

## 救砖

主要教程查看：[一加手机全系列⑮机型线刷救砖资源★附教程](https://www.oneplusbbs.com/forum.php?mod=viewthread&tid=4446250)，这里要注意以下几点：

+ 1.救砖后系统恢复为安卓7。

+ 2.要升级系统好像只能逐级升级（安卓7—安卓8—安卓9—安卓10），将下载好的官方全量包—安卓8、安卓9、安卓10放在根目录依次升级，如果想直接从安卓7升级到安卓10，会失败。这里用官方`recovery`即可。

+ 3.升级到安卓9，出现bug—WiFi开关打不开；升级到安卓10，出现bug—相机、手电筒不能用。于是乎就卡刷了第三方ROM：[终结之作-5T Beta30 纯净优化包](https://www.oneplusbbs.com/thread-4723496-1.html)，刷这个包用到的`recovery`是用`一加手机5T工具箱 _2.2.1`刷的自选`Recovery`—`twrp-3.3.1`。

+ 4.`root`后可以利用`link2sd`这个软件，冻结或者卸载系统应用，安卓10好像只能冻结，卸载不了。具体使用方法，例如：搜索更新，将自动更新冻结，以后就收不到更新了。

+ 5.网上还有线刷的方法：[【任意升降级】一加系统任意升级降级 7.1/8.0/8.1 新手福利](https://www.oneplusbbs.com/thread-4330832-1.html)，不过测试未成功，不想再折腾了。

+ 6.不知为什么升级到安卓10后，相机不能用了。以后就暂且用这个包：[终结之作-5T Beta30 纯净优化包](https://www.oneplusbbs.com/thread-4723496-1.html)。（这里好像是在升级到安卓10出现问题后，再卡刷这个包的，不知道能否直接从安卓7卡刷，以后有机会再测试吧，当然要注意`recovery`版本不能太低了，用`twrp-3.3.1`应该没问题）。

## 手机使用记录

1. 2018年2月买的，用到2021年6月
2. 一加9R 2021年6月买的一加5T 

## 参考链接

+ [1.OnePlus 5T Android 10 root亲测教程](https://www.oneplusbbs.com/thread-5460360-1.html)
+ [2.完美支持安卓10Xposed框架★EdXposed](https://www.oneplusbbs.com/forum.php?mod=viewthread&tid=4662409)

