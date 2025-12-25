---
title: 解决Github Port 443以及Port 22问题
categories:
  - 技术
tags:
  - github
abbrlink: 2284a148
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
git config --global http.proxy http://127.0.0.1:10809
 
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



