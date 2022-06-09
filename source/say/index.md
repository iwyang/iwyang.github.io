---
title: "说说"
date: 2021-10-02
aside: true
type: say
comments: false
---
<style>
.page-title {
    display: none;
  }
</style>
<!--  自言自语  -->

<div id='speak'>
<script type="text/javascript" src="../img/js/ispeak-bber.min.js" charset="utf-8" ></script>
<script>
ispeakBber
    .init({
        el: '#speak', // 容器选择器
        name: 'Bore 🦄', // 显示的昵称
        envId: 'hello-cloudbase-0gc8y1np937491cb', // 环境id
        region: 'ap-shanghai', // 腾讯云地址，默认为上海
        limit: 10, // 每次加载的条数，默认为5
        avatar: '../img/avatar.jpg', // 头像地址
        fromColor:'rgb(245, 150, 170)', // 下方标签背景颜色 默认 rgb(245, 150, 170)
        loadingImg: '../img/loading.gif', // 自定义loading的图片，示例值为默认值
        dbName:'talks' // 数据的名称，默认talks，避免有人的命名不是这个，所以加入此配置字段。
    })
    .then(function() {
        // 哔哔加载完成后的回调函数，你可以写你自己的功能
        console.log('哔哔 加载完成')
    })
</script>
</div>
