---
title: debian 10安装xfce桌面和配置vnc和wine
categories:
  - 技术
tags:
  - linux
comments: true
cover: /img/cover/xfce.jpg
abbrlink: 26d4b8da
date: 2023-07-18 19:36:29
sticky:
keywords:
description:
top_img:
---

{% note warning flat %}
Debian10 上安装部分应用，速度几乎为0，至少需要Debian11以上，512M内存足够。
{% endnote %}

## 安装桌面环境和VNC服务器

默认情况下，Debian 11的服务器并没有安装图形化桌面环境或VNC服务器，所以你将从安装这些开始。
在选择 VNC 服务器和桌面环境方面，您有很多选择。在本教程中，你将安装最新的Xfce桌面环境和TightVNC软件包，这些软件包可从Ubuntu官方仓库获得。Xfce和TightVNC都以轻量级和快速著称，这将有助于确保即使在较慢的互联网连接上，VNC连接也能顺利和稳定。



0.如果新装系统，参考:[`vi` 无法正常使用](/archives/9eb70758/#vi无法正常使用)



1.用SSH连接到你的服务器后，更新你的软件包列表。

```sql
sudo apt update
```

2.现在在你的服务器上安装Xfce桌面环境，以及`xfce4-goodies` 包。

```sql
sudo apt install xfce4 xfce4-goodies
```

在安装过程中，你可能会被提示为Xfce选择一个默认的显示管理器。显示管理器是一个允许你通过图形界面选择和登录到桌面环境的程序。你只有在用VNC客户端连接时才会使用Xfce，在这些Xfce会话中，你已经以你的非root Debian用户身份登录了。所以在本教程中，你对显示管理器的选择并不重要。选择其中一个，然后按`ENTER` 。



3.安装完成后，安装TightVNC服务器。

```sql
sudo apt install tightvncserver
```

> 如果是debian 11，还需要安装dbus-x11 依赖关系，以确保与VNC服务器的正常连接:`sudo apt install tightvncserver`

4.为了在安装后完成VNC服务器的初始配置，使用`vncserver` 命令来设置安全密码并创建初始配置文件。

```sql
vncserver
```

接下来会有一个提示，要求输入并验证一个密码，以便远程访问你的机器。

```
Output
You will require a password to access your desktops.

Password:
Verify:
```

密码的长度必须在六到八个字符之间。超过八个字符的密码将被自动截断。

一旦你验证了密码，你可以选择创建一个仅供查看的密码。使用只查看密码登录的用户将不能用鼠标或键盘控制VNC实例。如果你想用你的VNC服务器向其他人演示一些东西，这是一个有用的选项，但这不是必需的。`Would you like to enter a view-only password (y/n)? n`

然后，该过程为服务器创建必要的默认配置文件和连接信息。

```
OutputWould you like to enter a view-only password (y/n)? n
xauth:  file /home/sammy/.Xauthority does not exist

New 'X' desktop is your_hostname:1

Creating default startup script /home/sammy/.vnc/xstartup
Starting applications specified in /home/sammy/.vnc/xstartup
Log file is /home/sammy/.vnc/your_hostname:1.log
```

接下来，配置它以启动Xfce并通过图形界面访问服务器。

5.提示`执行子进程“dbus-launch”失败`

```
sudo apt-get install dbus-x11
```

## 配置VNC服务器

VNC服务器需要知道启动时要执行哪些命令。具体来说，VNC需要知道它应该连接到哪个图形桌面。

这些命令位于你的主目录下`.vnc` 文件夹中一个名为`xstartup` 的配置文件中。启动脚本是在上一步运行`vncserver` 命令时创建的，但你将创建自己的脚本来启动Xfce桌面。

当VNC第一次被设置时，它在端口`5901` ，启动一个默认的服务器实例。这个端口被称为*显示端口*，VNC称其为`:1` 。VNC可以在其他显示端口启动多个实例，如`:2` 、`:3` ，等等。

因为你要改变VNC服务器的配置方式，所以首先用以下命令停止运行在端口`5901` 的VNC服务器实例。

```
vncserver -kill :1
```

以下是针对你的服务器环境的PID的输出。

```
Output
Killing Xtightvnc process ID 17648
```

在你修改`xstartup` 文件之前，先备份原文件。

```
mv ~/.vnc/xstartup ~/.vnc/xstartup.bak
```

现在创建一个新的`xstartup` 文件并在你喜欢的文本编辑器中打开它。

```
vi ~/.vnc/xstartup
```

只要你启动或重新启动VNC服务器，该文件中的命令就会自动执行。如果你的桌面环境还没有启动，你需要VNC来启动它。在该文件中添加以下命令。

```bash
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
```

下面简要介绍一下每一行的作用。

- `#!/bin/bash`:第一行是一个[shebang](https://link.juejin.cn?target=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FShebang_(Unix))。在*nix平台上的可执行纯文本文件中，shebang告诉系统将该文件传递给哪个解释器来执行。在这个例子中，你要把文件传给Bash解释器。这将使每一个连续的行被当作命令来执行，按顺序进行。
- `xrdb $HOME/.Xresources`:这个命令告诉VNC的GUI框架读取用户的`.Xresources` 文件。`.Xresources` ，用户可以在这里对图形桌面的某些设置进行修改，比如终端颜色、光标主题和字体渲染。
- `startxfce4 &`:这个命令告诉服务器启动Xfce。在这里你可以找到所有你需要的图形软件，以便舒适地管理你的服务器。

当你完成后，保存并退出你的编辑器。如果你使用的是`nano` ，你可以通过按`CTRL+X` ，然后按`Y` ，再按`ENTER` 。

为了确保VNC服务器能够正确使用这个新的启动文件，你需要使它可执行。

```
sudo chmod +x ~/.vnc/xstartup
```

现在，重新启动VNC服务器。

```
vncserver
```

输出结果将类似于以下内容。

```
Output
New 'X' desktop is your_hostname:1

Starting applications specified in /home/sammy/.vnc/xstartup
Log file is /home/sammy/.vnc/your_hostname:1.log
```

## 配置防火墙

如果你Debian 11正在运行防火墙，并且使用[ufw](https://www.myfreax.com/how-to-setup-a-firewall-with-ufw-on-debian-10/)作为[防火墙](https://www.myfreax.com/how-to-setup-a-firewall-with-ufw-on-debian-10/)管理工具。则需要打开端口5901的连接。

如果你显示端口是`:2`。则需要打开端口5902的连接，以此类推，请随时添加你需要允许的端口。

在本教程中我们将打开端口5901，运行ufw命令`sudo ufw allow 5901`。

```
sudo ufw allow 5901
```

配置到位后，你就可以从你的本地机器连接到VNC服务器了。

## 安全地连接VNC桌面

这部分内容参考：[Step 3 — Connecting the VNC Desktop Securely](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-debian-10#step-3-connecting-the-vnc-desktop-securely)

我直接用的：[VNC Viewer](https://www.realvnc.com/en/connect/download/viewer/)

## 作为系统服务运行VNC

接下来，你将把VNC服务器设置为一个systemd服务。你可以像其他服务一样，根据需要启动、停止和重启它。这也将确保VNC在你的服务器重启时也能启动。

首先，用你喜欢的文本编辑器创建一个名为`/etc/systemd/system/vncserver@.service` 的新单元文件。



```
sudo vi /etc/systemd/system/vncserver@.service
```

名字后面的`@` 符号将让你传入一个参数，你可以在服务配置中使用。你将用它来指定你在管理服务时要使用的VNC显示端口。

在文件中添加以下几行。请确保修改`User` 、`Group` 、`WorkingDirectory` ，以及`PIDFILE` 中的用户名，以符合你的用户名。

**官方：**(如果要用下面配置，先参考：[Initial Server Setup with Debian 10](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-debian-10)，进行设置用户名、防火墙等操作)

```bash
[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=sammy
Group=sammy
WorkingDirectory=/home/sammy

PIDFile=/home/sammy/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
```

**修改为：**

```bash
[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=root
Group=root
WorkingDirectory=/root

PIDFile=/root/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
```

如果VNC已经在运行，`ExecStartPre` 命令会停止它。`ExecStart` 命令启动VNC，并将色深设置为24位色，分辨率为1280x800。你也可以修改这些启动选项以满足你的需要。完成后保存并关闭该文件。

接下来，让系统知道这个新的单元文件。

```
sudo systemctl daemon-reload
```

然后，启用该单元文件。

```
sudo systemctl enable vncserver@1.service
```

`@` 后面的`1` 标志着服务应该出现在哪个显示号码上，在这种情况下，默认的`:1` ，正如在 中讨论的那样。

如果VNC服务器的当前实例仍在运行，请停止它。

```
vncserver -kill :1
```

然后像启动其他systemd服务一样启动它。

```
sudo systemctl start vncserver@1
```

你可以用下面的命令来验证它是否启动。

```
sudo systemctl status vncserver@1
```

如果启动正确，输出结果将类似于下面。

```
Output
● vncserver@1.service - Start TightVNC server at startup
Loaded: loaded (/etc/systemd/system/vncserver@.service; enabled; vendor preset: enabled)
Active: active (running) since Fri 2022-08-19 16:21:36 UTC; 5s ago
Process: 24469 ExecStartPre=/usr/bin/vncserver -kill :1 > /dev/null 2>&1 (code=exited, status=2)
Process: 24474 ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 -localhost :1 (code=exited, status=0/SUCCESS)
Main PID: 24482 (Xtightvnc)
. . .
```

当你重新启动机器时，你的VNC服务器就可以使用了。

再次启动你的SSH隧道。

```
ssh -L 5901:127.0.0.1:5901 -C -N -l sammy your_server_ip
```

然后用你的VNC客户端软件建立一个新的连接，`localhost:5901` ，连接到你的机器。

## Too many authentication failures VNC server

解决方法：

```
vncserver -kill :1
vncserver
```

## xfce4 设置中文

1.安装locales并配置

```
sudo apt install locales
sudo dpkg-reconfigure locales
```

进入语言设置界面，其中，空格键为选取/取消，Tab键为切换到确认选择。

2.通过方向键与空格键选择语言编码en_US.UTF8，zh_CN GB2312，zh_CN GBK GBK，zh_CN UTF-8 UTF-8

3.然后按Tab选择<OK>，回车进入下一个界面，选择 `zh_CN UTF-8 UTF-8`为默认系统环境，回车。

4.为当前用户配置默认语言为中文zh_CN UTF-8 UTF-8

```
vi ~/.bashrc
在.bashrc最后添加一行
export LANG=zh_CN.UTF-8
```

5.安装中文字体

```
sudo apt install fonts-wqy-zenhei
```

6.重启

## Debian 10安装firefox

```
sudo apt update
sudo apt upgrade
sudo apt install firefox-esr -y
```

## Debian 10安装wine 7.0

> 貌似debian 10只能装wine 7.0，装不了wine 8.0。debian 11才能安装wine 8.0，wine 8.0可以微信，不过都是乱码，**根本就没必要装wine**，不过还是记录以下

### Step 1: Prerequsiteis

In order to run Winehq, You need to enable i386 architecture on your Debian system. Also, import the GPG key to your system by which the wine packages are signed.

```
sudo dpkg --add-architecture i386  
wget -qO - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add - 
```

Use one of the following commands to enable the Wine apt repository in your system based on your operating system and version.

```
sudo apt -y install gnupg2 software-properties-common
sudo apt-add-repository https://dl.winehq.org/wine-builds/debian/ 
```

### Step 2: Install Wine on Debian 10

Your system is ready to install Winehq. Update the apt information with the newly added repositories. Execute the following commands. The `--install-recommends` option will install all the recommended packages by **winehq-stable** on your system.

```
sudo apt update 
sudo apt install --install-recommends winehq-stable 
```

The wine packages are installed under /opt/wine-stable directory. So set the wine bin directory to the **PATH** environment to access commands system-wide.

```
export PATH=$PATH:/opt/wine-stable/bin 
```

### Step 3: Check Wine Version

Wine installation successfully completed. Use the following command to check the version of wine installed on your system

```
wine --version 

wine-7.0
```

### How to Use Wine (Optional)

To use wine we need to log in to the Debian desktop system. After that download a windows .exe file like [PuTTY ](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)on your system and open it with Wine as below screenshot or use the following command.

```
wine ~/Downloads/putty.exe 
```

## Debian 11安装wine 8.0

### Step 1: Enable 32 bit architecture

If you’re running a 64-bit system, enable support for 32-bit applications.

```
sudo dpkg --add-architecture i386
```

The command above won’t return any output.

### Step 2: Add WineHQ repository

We will pull the latest Wine packages from WineHQ repository that is added manually.

First, import GPG key:

```
sudo apt update
sudo apt -y install gnupg2 software-properties-common
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
```

You should receive “**OK**” in the output.



Add the Wine repository by running the following command:



```
sudo apt-add-repository https://dl.winehq.org/wine-builds/debian/
```

The command will add repository to line */etc/apt/sources.list* file.

Update APT package index after:

```
sudo apt update
```

### Using OBS repository (Alternative)

You can also use OBS repository instead of the official repository. Add Wine OBS repository as shown below:



**Debian 11:**

```
wget -O- -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_11/Release.key | sudo apt-key add -    
echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_11 ./" | sudo tee /etc/apt/sources.list.d/wine-obs.list
```

### Step 3: Install Wine on Debian 11|10|9

After configuration of the APT repository, the final step is the actual installation of Wine on Debian.

Then install Wine from Stable branch:

```
sudo apt update
sudo apt install --install-recommends winehq-stable
```

The wine packages are installed under /opt/wine-stable directory. So set the wine bin directory to the **PATH** environment to access commands system-wide.

```
export PATH=$PATH:/opt/wine-stable/bin 
```

After installation. verify version installed.

```
$ wine --version
wine-8.0
```

### Step 4: Using Wine on Debian

For basic usage of wine, check help page.

```
$ wine --help
```

Example below is used to run [Notepad++ editor](https://github.com/notepad-plus-plus/notepad-plus-plus/releases) on Linux.

```
cd ~/Downloads
VER=$(curl -s https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//g')
wget https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v${VER}/npp.${VER}.Installer.exe
wine ./npp.${VER}.Installer.exe
```



Follow installation prompts like for any other Windows application.

## 附：第二种作为系统服务运行VNC

1.创建systemd服务文件：使用命令 `sudo nano /etc/systemd/system/tightvncserver@.service`创建一个新的systemd服务文件。

2.编辑systemd服务文件：在文件中填写以下内容：

```bash
[Unit]
Description=TightVNC server
After=syslog.target network.target

[Service]
Type=forking
User=<username>
PAMName=login
PIDFile=/home/<username>/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target

```

**修改为：**

```sql
[Unit]
Description=TightVNC server
After=syslog.target network.target

[Service]
Type=forking
User=root
PAMName=login
PIDFile=/root/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target

```

3.重新加载systemd服务：在终端窗口中输入命令 `sudo systemctl daemon-reload`。

4.启用VNC Server服务：在终端窗口中输入命令 `sudo systemctl enable tightvncserver@1`

5.启动VNC Server服务：在终端窗口中输入命令 `sudo systemctl start tightvncserver@1`

6.检查VNC Server服务状态：在终端窗口中输入命令 `systemctl status tightvncserver@1`，检查服务是否已启动。

这样，你就可以在Ubuntu系统开机时自动启动VNC Server服务了。

## 总结

你现在有了一个安全的VNC服务器并在你的Debian 11服务器上运行。现在，您可以通过一个用户友好和熟悉的图形界面来管理您的文件、软件和设置。您还可以远程运行图形化软件，如网页浏览器。

## 参考链接

+ [How to Install and Configure VNC on Debian 10](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-debian-10)
+ [如何在Debian 11上安装和配置VNC](https://juejin.cn/post/7162831879303856164)
+ [如何在Debian 11安装VNC](https://www.myfreax.com/how-to-install-and-configure-vnc-on-debian-11/)
+ [xfce4 设置中文](https://www.cnblogs.com/KylinBlog/p/16588008.html)

+ [ubuntu vnc开机启动](https://juejin.cn/s/ubuntu%20vnc%E5%BC%80%E6%9C%BA%E5%90%AF%E5%8A%A8)

+ [Initial Server Setup with Debian 10](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-debian-10)

+ [How to Install and Configure VNC on Debian 11](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-debian-11)

+ [How To Install Wine 7.0 on Debian 10 ](https://tecadmin.net/install-wine-on-debian-10-buster/)

+ [How To Install Wine 8 on Debian 11](https://computingforgeeks.com/how-to-install-wine-on-debian/?expand_article=1)
