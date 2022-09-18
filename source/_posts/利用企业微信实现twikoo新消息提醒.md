---
title: 利用企业微信实现twikoo新消息提醒&&数据导出等
categories:
  - 技术
tags:
  - hexo
comments: true
abbrlink: 9a366c6
date: 2022-02-06 09:27:38
sticky:
keywords:
description:
top_img:
cover: false
---

## 注册企业微信

1．搜索下载企业，并使用手机号进行企业微信注册

2．选择成立企业

3．输入企业名称等信息

4．完成后，在通讯录内添加成员

## 企业微信创建一个应用

在 “企业微信 —— 应用管理” 最底部的 “自建” 应用处，新建一个 “应用”。名称比如就叫消息通知，配置完成后记录下应用页面的 AgentId 和 Secret。注意，查看 Secret 需要安装一个企业微信，查看完可以卸载。

在 “企业微信 —— 我的企业” 底部，记录下 “企业 ID”。

至此，微信配置完成，开始配置提醒 API。

## 创建 API 云函数

首先参考 Heo 的教程，创建一个腾讯云或 vercel 版本的云函数。

### Vercel版本

我之前使用vercel部署过twikoo，因此不需要再创建新的云函数。如果你不是使用vercel，[参考这里](https://blog.zhheo.com/p/1e9f35bc.html#使用vercel开发搭建教程（推荐）)。

#### 安装python

下载并安装python，安装时注意勾选`Add Python 3.10 to PATH`

#### 安装pipenv

找到你的twikoo github仓库，clone到本地，进入`api/`，执行以下命令：

```powershell
pip install pipenv
```

如果安装时报错：`ERROR: Exception: Traceback (most recent call last)`，就使用一下命令安装：

```powershell
pip install pipenv -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
```

#### 下载requests

继续在`api/`文件夹下执行以下命令：

```powershell
pipenv install requests
```

如果按照报错，请先关闭dl。

#### 新建python.py

然后在该目录创建一个`python.py`文件，内容如下：

```python
from http.server import BaseHTTPRequestHandler
import json
import requests
from urllib.parse import parse_qs
# -*- coding: utf8 -*-


class handler(BaseHTTPRequestHandler):
    

    def do_GET(self):
        def getTocken(id, secert, msg, agentId):
            url = "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=" + \
                id + "&corpsecret=" + secert

            r = requests.get(url)
            tocken_json = json.loads(r.text)
            # print(tocken_json['access_token'])
            sendText(tocken=tocken_json['access_token'], agentId=agentId, msg=msg)

        def sendText(tocken, agentId, msg):
            sendUrl = "https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=" + tocken
            # print(sendUrl)
            data = json.dumps({
                "safe": 0,
                "touser": "@all",
                "msgtype": "text",
                "agentid": agentId,
                "text": {
                    "content": str(msg)
                }
            })
            requests.post(sendUrl, data)
            
        try:
            params = parse_qs(self.path[12:])
            apiid = params['id'][0]
            apisecert = params['secert'][0]
            apiagentId = params['agentId'][0]
            apimsg = params['msg'][0]
        except:
            apimsg = self.path
        else:
            #try:
            # 执行主程序
            getTocken(id=apiid, secert=apisecert,
                        msg=apimsg, agentId=apiagentId)
            #except:
            #    status = 1
            #    apimsg = '主程序运行时出现错误，请检查参数是否填写正确。详情可以参阅：https://blog.zhheo.com/p/1e9f35bc.html'
            #else:
            #    status = 0
        # print(event)
        # print("Received event: " + json.dumps(event, indent = 2))
        # print("Received context: " + str(context))
        # print("Hello world")

        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(apimsg)
        return
```

push当前的更改之后，当Vercel完成部署后，你可以使用下面这样的方式，拼接一个 URL，浏览器访问，看看手机微信能不能接收到消息。

```
https://< vercel_app_address>/api/python?id=<ww....>&secert=<secret...>&agentId=<agentId...>&msg=测试一下吧
```

如果成功的话你的手机会接收到对应的推送（如果你的企业微信注册成功且所填信息正确）。

#### 在twikoo中配置

~~在twikoo后台管理`WECOM_API_URL`中添加你拼接的url即可。注意`msg`后面不要有参数：~~

```
https://<vercel_app_address>/api/python?id=<企业id>&secert=<secret>&agentId=<agentId>&msg=
```

---

2022.3.6 [Twikoo](https://twikoo.js.org/) v1.5.0更新： 消息推送逻辑，从 1.5.0 之前的版本升级后，请在管理面板重新配置评论提醒的消息推送服务，增加了对 Bark、Telegram 等平台的支持

##### [企业微信](https://guole.fun/posts/626/) 缩写: `wecom`

企业微信应用消息推送，免费，限制较少。

1. 用电脑打开 https://work.weixin.qq.com/，注册一个企业
2. 注册成功后，点「管理企业」进入管理界面，选择「应用管理」 → 「自建」 → 「创建应用」
3. 应用名称填入机器人的名称，应用 logo 选择机器人的头像，可见范围选择公司名
4. 创建完成后进入应用详情页，可以得到应用ID( `agentid` )，应用Secret( `secret` )，复制
   PS：获取应用Secret时，可能会将其推送到企业微信客户端，这时候微信里边是看不到的，需要在企业微信客户端里边才能看到
5. 进入「[我的企业](https://work.weixin.qq.com/wework_admin/frame#profile)」页面，拉到最下边，可以看到企业ID，复制
6. 进入「我的企业」 → 「[微信插件](https://work.weixin.qq.com/wework_admin/frame#profile/wxPlugin)」，拉到下边扫描二维码，关注以后即可收到推送的消息
7. 将第 4 步和第 5 步取得的 `企业ID#应用Secret#应用ID` 拼到一起，中间用 “`#`” 号分隔，填入 pushoo 的 token 中

示例 token：`ww97a01a*****1e5f1#xHapDXmgZtlBgRQQXMb4kfh3y75Ynoubl*****l9ytE#1000005`

PS：如果出现接口请求正常，企业微信接受消息正常，个人微信无法收到消息的情况，请确认如下配置：

- 进入「我的企业」 → 「微信插件」，拉到最下方，勾选「允许成员在微信插件中接收和回复聊天消息 」
- 在企业微信客户端 「我」 → 「设置」 → 「新消息通知」中关闭「仅在企业微信中接受消息」限制条件

#### 在微信中接收企业微信消息

在“企业微信——我的企业——微信插件”页面配置，[点击这里查看](https://work.weixin.qq.com/wework_admin/frame#profile/wxPlugin)。

使用微信扫码，关注你的企业微信，并且在设置中打开`允许成员在微信插件中接收和回复聊天消息`选项。

### 腾讯云版本

可以复用之前 Twikoo 那个云开发环境，直接创建一个新的云函数，名称自定义如 weixin-push，选择 helloworld 空白模板函数，Python3.6 环境， 128MB 就 OK 了。下一步粘贴下面的代码，点击创建：

```python
# -*- coding: utf8 -*-
import requests
import json

def getTocken(id,secert,msg,agentId):
    url = "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=" + id + "&corpsecret=" + secert

    r =requests.get(url)
    tocken_json = json.loads(r.text)
    # print(tocken_json['access_token'])
    sendText(tocken=tocken_json['access_token'],agentId=agentId,msg=msg)

def sendText(tocken,agentId,msg):
    sendUrl = "https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=" + tocken
    # print(sendUrl)
    data = json.dumps({
        "safe": 0,
        "touser" : "@all",
        "msgtype" : "text",
        "agentid" : agentId,
        "text" : {
            "content" : msg
        }
    })
    requests.post(sendUrl,data)

def main(event, context):
    try:
        apiid=event['queryStringParameters']['id']
        apisecert=event['queryStringParameters']['secert']
        apiagentId = event['queryStringParameters']['agentId']
        apimsg = event['queryStringParameters']['msg']
    except:
        apimsg = '有必填参数没有填写，请检查是否填写正确和格式是否错误。详情可以参阅：https://blog.zhheo.com/p/1e9f35bc.html'
        status = 1
    else:
        try:
            # 执行主程序
            getTocken(id=apiid,secert=apisecert,msg=apimsg,agentId=apiagentId)
        except:
            status = 1
            apimsg = '主程序运行时出现错误，请检查参数是否填写正确。详情可以参阅：https://blog.zhheo.com/p/1e9f35bc.html'
        else:
            status = 0
    # print(event)
    # print("Received event: " + json.dumps(event, indent = 2)) 
    # print("Received context: " + str(context))
    # print("Hello world")
    status_str = json.dumps({
            "status":status,
            "msg":apimsg
        })
    return(status_str)
```

配置好访问服务（如果第一次创建，参考 Twikoo 教程还需要配置安全域名等）：

```
域名：*
触发路径：/weixin-push           (自定义)
关联资源：云函数   weixin-push    (上文创建的云函数)
```

![](../img/%E5%88%A9%E7%94%A8%E4%BC%81%E4%B8%9A%E5%BE%AE%E4%BF%A1%E5%AE%9E%E7%8E%B0twikoo%E6%96%B0%E6%B6%88%E6%81%AF%E6%8F%90%E9%86%92/202202061010000.jpg)

至此，云函数创建完成。可以使用下面这样的方式，拼接一个 URL，浏览器访问，看看手机微信能不能接收到消息。

云函数的访问服务 URL + 触发路径 + ?id = 你的企业微信 ID + secert = 上文记录的 secert + Id = 上文记录的 AgentId + &msg = 随便测试一下吧

如我下面这样的：

```
https://blogpkly-13278c-1258453354.ap-shanghai.app.tcloudbase.com/weixin-push?id=ww*******&secert=Ne******&agentId=1000003&msg=随便测试一下吧
```

浏览器返回以下内容，说明配置完成 (msg 后的内容，是 Unicode 编码后的 “随便测试一下吧” 内容，点击这里可以转换 )。

```json
{"status": 0, "msg": "\u968f\u4fbf\u6d4b\u8bd5\u4e00\u4e0b\u5427"}
```

#### Twikoo 配置

在 Twikoo v1.4.5 及以上版本中，打开控制面板，在上述企业微信 API 搭建完成后，拼接成下述样式的 URL，填写在即时通知 ——WECOM_API_URL 中即可完成配置。

```
https://blogpkly-13278c-1258453354.ap-shanghai.app.tcloudbase.com/weixin-push?id=企业微信获取&secert=企业微信获取&agentId=企业微信获取&msg=
```

微信关注自己的企业微信账号，然后用其他非博主邮箱在网站留言，试试即时通知吧！

## 更换 CDN 镜像

> 如果遇到默认 CDN 加载速度缓慢，可更换其他 CDN 镜像。以下为可供选择的公共 CDN，其中一些 CDN 可能需要数天时间同步最新版本：
>
> - `https://cdn.staticfile.org/twikoo/1.6.4/twikoo.all.min.js`
> - `https://lib.baomitu.com/twikoo/1.6.4/twikoo.all.min.js`
> - `https://cdn.bootcdn.net/ajax/libs/twikoo/1.6.4/twikoo.all.min.js`
> - `https://cdn.jsdelivr.net/npm/twikoo@1.6.4/dist/twikoo.all.min.js`

例如[Butterfly主题 ](https://github.com/jerryc127/hexo-theme-butterfly)：

```diff
  custom_format:
  
  option:
    # main_css:
    # main:
    # utils:
    # translate:
    # local_search:
    # algolia_js:
    # algolia_search_v4:
    # instantsearch_v4:
    # pjax:
    # gitalk:
    # gitalk_css:
    # blueimp_md5:
    # valine:
    # disqusjs:
    # disqusjs_css:
+     twikoo: https://cdn.staticfile.org/twikoo/1.6.4/twikoo.all.min.js
```



> 以前记得只需更改后端版本号即可，不知什么时候开始还要更改前端CDN才行。也许主题前端没有更新到最新的版本号。这时只有自定义CDN了，还好
>
> 
>
> `butterfly`主题很容易就能自定义CDN



## 更换表情CDN

仓库地址：[zhheo](https://github.com/zhheo)/[Sticker-Heo](https://github.com/zhheo/Sticker-Heo)

使用：

```json
https://cdn.jsdelivr.net/npm/sticker-heo@2022.7.5/twikoo.json
https://cdn1.tianli0.top/npm/sticker-heo@2022.7.5/twikoo.json
```

## Twikoo 导出评论数据

> Twikoo前端后台只有导入数据功能，没有导出，要想导出数据，看下面。

### 导出 Twikoo 在 Vercel 的数据

1.下载并安装 MongoDB 数据库工具，下载地址：https://www.mongodb.com/try/download/database-tools；

`

然后添加环境变量：`D:\Program Files\mongodb-database-tools-windows-x86_64-100.5.4\bin`到`Path`



2.登录 [Vercel 管理后台](https://vercel.com/)，点开 Twikoo 的环境，点击上方的 Settings，点击左侧的 Environment Variables，在页面下方找到 MONGODB_URI，点击对应的小眼睛图标，会出现数据库连接地址，点击以复制这串地址；



3.如果地址中包含参数，请先删去参数，参数即 “?” 和 “?” 后面的部分，例如 `?journal=true&w=majority`；



4.打开一个命令行窗口，粘贴以下命令：

```
mongoexport --uri 这里换成刚才复制的地址 --collection comment --type json --out twikoo-comments.json
```

5.如果成功，你可以在当前目录下找到导出的 twikoo-comments.json 文件。

### 导出 Twikoo 在腾讯云的数据

1.登录 [腾讯云](https://console.cloud.tencent.com/tcb)；

2.打开云开发 CloudBase；

3.选择要导出的环境；

4.点击左侧的数据库，点击 comment 集合，点击导出按钮；

5.导出格式选择 JSON（推荐，如果想用 Excel 等软件查看，可以选择 CSV），字段不填；

6.点击导出按钮，导出的数据会通过浏览器自动下载。

##  参考链接

+ [搭建微信通知 API 实现 Twikoo 新消息提醒](https://guole.fun/posts/626/)
+ [利用企业微信实现twikoo新消息提醒(python.py错误)](https://www.cnblogs.com/yyyzyyyz/p/15542401.html#%E5%88%A9%E7%94%A8%E4%BC%81%E4%B8%9A%E5%BE%AE%E4%BF%A1%E5%AE%9E%E7%8E%B0twikoo%E6%96%B0%E6%B6%88%E6%81%AF%E6%8F%90%E9%86%92)
+ [微信通知Twikoo新消息提醒（Vercel版本）（python.py正确)](https://lucheng.xyz/2022/01/09/wechat-message-vercel/)
+ [twikoo即时消息推送](https://pushoo.js.org/)
+ [pip安装virtualenv报错：ERROR: Exception: Traceback (most recent call last)---有效解决方法](https://www.codeleading.com/article/43653014515/)
+ [pipenv install 包名 报错问题解决](https://blog.csdn.net/weixin_45252106/article/details/121973562)
+ [Twikoo 评论数据导出教程](https://www.imaegoo.com/2022/twikoo-data-export/)
