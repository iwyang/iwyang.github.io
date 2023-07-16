---
title: linux利用crontab设置定时任务
categories:
  - 技术
tags:
  - linux
abbrlink: 964093b3
date: 2020-08-10 10:52:25
cover: false
---

## 更改时区

如果你不知道服务器当前时间，可以使用下面的命令，查看当前时间：

```
date -R
```

修改当前时区为上海：

```
sudo timedatectl set-timezone Asia/Shanghai
```

再次不带任何选项参数调用 `timedatectl `命令，打印系统当前设置的时区即可：

```
timedatectl
```

## 查看定时任务

```bash
crontab -l
```

## 编辑定时任务

```bash
crontab -e
```
第一个*是分钟

第二个*是小时

第三个*是日期

第四个*是月份

第五个*是星期(0-6)

**例如：每个星期一凌晨3点自动重启**
```bash
0 3 * * 1  /sbin/reboot
```
## 使用实例

每天，每月，每年 定时启动:

```js
每五分钟执行  */5 * * * *

每小时执行     0 * * * *

每天执行        0 0 * * *

每周执行       0 0 * * 0

每月执行        0 0 1 * *

每年执行       0 0 1 1 *
```

crontab时间举例：

```js
# 每天早上6点 
0 6 * * * echo "Good morning." >> /tmp/test.txt //注意单纯echo，从屏幕上看不到任何输出，因为cron把任何输出都email到root的信箱了。

# 每两个小时 
0 */2 * * * echo "Have a break now." >> /tmp/test.txt  

# 晚上11点到早上8点之间每两个小时和早上八点 
0 23-7/2，8 * * * echo "Have a good dream" >> /tmp/test.txt

# 每个月的4号和每个礼拜的礼拜一到礼拜三的早上11点 
0 11 4 * 1-3 command line

# 1月1日早上4点 
0 4 1 1 * command line SHELL=/bin/bash PATH=/sbin:/bin:/usr/sbin:/usr/bin MAILTO=root //如果出现错误，或者有数据输出，数据作为邮件发给这个帐号 HOME=/ 

# 每小时（第一分钟）执行/etc/cron.hourly内的脚本
01 * * * * root run-parts /etc/cron.hourly

# 每天（凌晨4：02）执行/etc/cron.daily内的脚本
02 4 * * * root run-parts /etc/cron.daily 

# 每星期（周日凌晨4：22）执行/etc/cron.weekly内的脚本
22 4 * * 0 root run-parts /etc/cron.weekly 

# 每月（1号凌晨4：42）去执行/etc/cron.monthly内的脚本 
42 4 1 * * root run-parts /etc/cron.monthly 

# 注意:  "run-parts"这个参数了，如果去掉这个参数的话，后面就可以写要运行的某个脚本名，而不是文件夹名。 　 

# 每天的下午4点、5点、6点的5 min、15 min、25 min、35 min、45 min、55 min时执行命令。 
5，15，25，35，45，55 16，17，18 * * * command

# 每周一，三，五的下午3：00系统进入维护状态，重新启动系统。
00 15 * *1，3，5 shutdown -r +5

# 每小时的10分，40分执行用户目录下的innd/bbslin这个指令： 
10，40 * * * * innd/bbslink 

# 每小时的1分执行用户目录下的bin/account这个指令： 
1 * * * * bin/account

# 每天早晨三点二十分执行用户目录下如下所示的两个指令（每个指令以;分隔）： 
203 * * * （/bin/rm -f expire.ls logins.bad;bin/expire$#@62;expire.1st）

# 每1分钟执行一次myCommand
* * * * * myCommand

# 每小时的第3和第15分钟执行
3,15 * * * * myCommand

# 在上午8点到11点的第3和第15分钟执行
3,15 8-11 * * * myCommand

# 每隔两天的上午8点到11点的第3和第15分钟执行
3,15 8-11 */2  *  * myCommand

# 每周一上午8点到11点的第3和第15分钟执行
3,15 8-11 * * 1 myCommand

# 每晚的21:30重启smb
30 21 * * * /etc/init.d/smb restart

# 每月1、10、22日的4 : 45重启smb
45 4 1,10,22 * * /etc/init.d/smb restart

# 每周六、周日的1 : 10重启smb
10 1 * * 6,0 /etc/init.d/smb restart

# 每天18 : 00至23 : 00之间每隔30分钟重启smb
0,30 18-23 * * * /etc/init.d/smb restart

# 每星期六的晚上11 : 00 pm重启smb
0 23 * * 6 /etc/init.d/smb restart

# 每一小时重启smb
* */1 * * * /etc/init.d/smb restart

# 晚上11点到早上7点之间，每隔一小时重启smb
0 23-7 * * * /etc/init.d/smb restart
```

## 开机自动运行脚本

```bash
@reboot /root/s.sh
```

更多查看：[开机启动 kkapi](/archives/6c31209c/#开机启动kkapi)



## ChatGPT设置定时任务

> PS：ChatGPT有时给出的答案可能是错误的，需要验证：[crontab guru](https://crontab.guru/)

**1.提问：每隔2天运行一次**

回答：要设置一个每隔2天运行一次的cron作业，你可以使用以下cron表达式：

```markdown
0 0 */2 * *
```

解析这个cron表达式的含义如下：

- 第一个字段（`0`）表示cron作业运行的分钟数（在这种情况下，设置为0，表示整点）。
- 第二个字段（`0`）表示cron作业运行的小时数（在这种情况下，设置为0，表示午夜）。
- 第三个字段（`*/2`）表示月份中的日期。`*/2` 表示每隔2天运行一次。
- 第四个字段（`*`）表示月份，设置为`*`，表示任意月份。
- 第五个字段（`*`）表示星期几，也设置为`*`，表示任意星期几。

使用这个cron表达式，你的作业将在每隔2天的午夜运行一次。根据你的具体需求，可以调整时间（前两个字段）来适应你的要求。

**2.每隔48小时运行一次**

要设置一个每隔48小时运行一次的cron作业，你可以使用以下cron表达式：

```markdown
0 */48 * * *
```

这个cron表达式的含义如下：

- 第一个字段（`0`）表示cron作业运行的分钟数（在这种情况下，设置为0）。
- 第二个字段（`*/48`）表示小时数。`*/48` 表示每隔48小时运行一次。
- 第三个字段（`*`）表示月份中的日期，设置为`*`，表示任意日期。
- 第四个字段（`*`）表示月份，设置为`*`，表示任意月份。
- 第五个字段（`*`）表示星期几，设置为`*`，表示任意星期几。

使用这个cron表达式，你的作业将在每隔48小时运行一次。请注意，这个表达式不是严格意义上的每隔48小时，而是以作业开始时间为基准，再加上48小时的间隔运行。因此，如果作业在一个特定时间点启动，它将在启动后的48小时再次运行。

3.输入`* */48 * * *`

`* */48 * * *` 是一个有效的cron表达式，它表示每隔48小时运行一次。

让我们对这个cron表达式进行解析：

- 第一个字段（`*`）表示cron作业运行的分钟数，这里设置为`*`表示每分钟都匹配。
- 第二个字段（`*/48`）表示cron作业运行的小时数，`*/48` 表示每隔48小时运行一次。
- 第三个字段（`*`）表示月份中的日期，设置为`*`表示任意日期。
- 第四个字段（`*`）表示月份，设置为`*`表示任意月份。
- 第五个字段（`*`）表示星期几，设置为`*`表示任意星期几。

使用这个cron表达式，你的作业将在每隔48小时运行一次。无论何时启动作业，它都会在每个完整的48小时周期后再次运行。请注意，这个表达式不是严格意义上的每隔48小时，而是以作业启动时间为基准，再加上48小时的间隔运行。

## 参考链接

+ [0.crontab guru](https://crontab.guru/)
+ [1.Linux之crontab定时任务](https://blog.csdn.net/qq_22823581/article/details/80783835)
+ [2.crontab 定时任务](https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/crontab.html)
+ [3.crontab 每天，每月，每年   定时启动](https://blog.csdn.net/qq_22823581/article/details/80783835)
+ [4.Linux系统如何设置开机自动运行脚本](https://www.cnblogs.com/yychuyu/p/13095732.html)