https://github.com/lifetea/vue-admin

新建一个工程 vue-admin
# 环境搭建
## 安装vue环境
安装vue
```
npm i --save-dev vue 
```
安装vue-router(路由)
```
npm i --save-dev vue-router
```
安装vuex
```
npm i --save-dev vuex
```
安装vue-resource(网络请求)
```
npm i --save-dev vue-resource
```
## 安装webpack环境
安装webpack到全局
```
npm i -g webpack
```
安装webpack到项目
```
npm i --save-dev webpack
```
安装webpack-dev-server(须和webpack版本兼容)
```
npm i --save-dev webpack-dev-server
```
## 安装babel
安装babel
```
npm i --save-dev babel-cli babel-core
```
转换es2015
```
npm i --save-dev babel-preset-es2015 babel-preset-es2015-loose
```
兼容es3
```
npm i --save-dev babel-plugin-transform-es2015-modules-commonjs  babel-plugin-transform-es3-member-expression-literals babel-plugin-transform-es3-property-literals
```
在webpack中使用babel
```
  module: {
      loaders: [
          {
            test: /\.js$/,
            exclude: /(node_modules|bower_components)/,
            loader: 'babel-loader',
          }
      ]
  },
```
配置babel 在根目录中创建.babelrc
```
{
  "presets" : [ ["es2015", {"loose": true}] ],
  "plugins" : [
    "transform-es3-property-literals",
    "transform-es3-member-expression-literals",
    "transform-es2015-modules-commonjs"
  ]
}
```
配置 babel-polyfill

作用:
    Babel默认只转换新的JavaScript句法（syntax），而不转换新的API，比如Iterator、Generator、Set、Maps、Proxy、Reflect、Symbol、Promise等全局对象，以及一些定义在全局对象上的方法（比如Object.assign）都不会转码。
    举例来说，ES6在Array对象上新增了Array.from方法。Babel就不会转码这个方法。如果想让这个方法运行，必须使用babel-polyfill，为当前环境提供一个垫片。

安装:
```
npm install i --save-dev babel-polyfill
```
webpack中配置:
```
entry: ["babel-polyfill", "./src/js/main.js"],
```
## 安装loader
安装style-loader
```
npm i --save-dev style-loader
```
安装vue-loader
```
npm i --save-dev vue-loader
```
安装css-loader
```
npm i --save-dev css-loader
```
安装babel-loader 
```
npm i --save-dev babel-loader
```
## 安装gulp
安装gulp
```
npm i --save-dev gulp
```
安装gulp-minify
```
npm i --save-dev gulp-minify
```
安装gulp-uglify
```
npm i --save-dev gulp-uglify
```

# 配置环境
## 配置webpack

在根目录创建 webpack.config.js
```
module.exports = {
  entry: './src/js/main.js',
  output: {
    path: __dirname + '/dist',
    publicPath: 'dist/',
    filename: 'build.js'
  },
  module: {
      loaders: [
          {
              test: /\.vue$/,
              loader: 'vue-loader'
          },
          {
            test: /\.js$/,
            exclude: /(node_modules|bower_components)/,
            loader: 'babel-loader',
          }
      ]

  },
  devtool: '#eval-source-map'
}
```

## 配置gulp
创建gulpfile.js
```
var gulp = require('gulp')
var gutil = require("gulp-util");
var path  = require('path');

// webpack dev server
var webpackDevServer = require('webpack-dev-server');
// webpack
var webpack = require('webpack')
// webpack 配置
var webpackConf = require("./webpack.config.js");
// 修改配置
var devConf = Object.create(webpackConf);

devConf.devtool = "sourcemap";

// 创建一个配置
var devCompiler = webpack(devConf);

gulp.task("webpack:build-dev", function(callback) {
    // 运行webpack
    devCompiler.run(function(err, stats) {
        if(err) throw new gutil.PluginError("webpack:build-dev", err);
        gutil.log("[webpack:build-dev]", stats.toString({
            colors: true
        }));
        callback();
    });
});

// 修改配置
var serverConf = Object.create(webpackConf);
serverConf.devtool = "eval";

gulp.task("webpack-dev-server", function(callback) {
    // 启动server
    new webpackDevServer(webpack(serverConf), {
        publicPath: "/" + serverConf.output.publicPath,
        stats: {
            colors: true
        },
        hot:true,
    }).listen(8080, "localhost", function(err) {
        if(err) throw new gutil.PluginError("webpack-dev-server", err);
        gutil.log("[webpack-dev-server]", "http://localhost:8080/webpack-dev-server/index.html");
    });
});
```
# 第三步构建入口
## webpack入口和输出
在webpack.config.js中配置
```
  //入口文件设置  
  entry: './src/js/main.js',
  //输出目录 和 文件设置
  output: {
    path: __dirname + '/dist',
    filename: 'build.js'
  },
```
## 创建index.html
创建 根目录/index.html
```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>哈喽宝贝后台管理</title>
</head>
  <body>
    <div id="main"></div>
    <!-- 这里使用dist中我们编译好的build.js -->
    <script src="./dist/build.js"></script>
  </body>
</html>
```
## 创建main.js
创建 src/js/main.js
```
// 导入Vue
import Vue               from 'vue'
// 导入Main.vue
import Main              from '../view/Main.vue'

//初始化APP
var app = new Vue({
    el:"#main",
    // router,
    // store,
    render: h => h(Main),
})
```
## 创建Main.vue
```
<template>
    <div id="app">
        <!--<nav-bar :show="true"></nav-bar>-->
        <!--<router-view></router-view>-->
        <!--<footer-bar></footer-bar>-->
    </div>
</template>
<style>
</style>
<script>
    export  default{
        //replase 用来替代html中的id为main的标签
        replace: true,
        name:"Main",
        data() {
            return {
                msg: 'Hello Vue!'
            }
        },
        components:{
        }
    }
</script>
```

# 第四步搭建路由
## Vue全局化
使用 webpack 插件 ProvidePlugin

ProvidePlugin是webpack内置的插件他能让如juqery这样的三方库暴露到全局环境中，即我们能够在全局环境中使用$。在项目中会在很多地方使用到Vue,如果不把Vue当做全局,每个使用了Vue的文件都引入一遍造成webpack打包之后代码的体积非常大每个页面加载很慢。
更新后的 webpack.config.js
```
//引入webpack
var webpack = require('webpack');

module.exports = {
    entry: './src/js/main.js',
    output: {
        path: __dirname + '/dist',
        publicPath: 'dist/',
        filename: 'build.js'
    },
    module: {
        loaders: [
          {
              test: /\.vue$/,
              loader: 'vue-loader'
          },
          {
            test: /\.js$/,
            exclude: /(node_modules|bower_components)/,
            loader: 'babel-loader',
          }
        ]
    },
    plugins: [
        //使用插件让我们能够在全局使用Vue
        new webpack.ProvidePlugin({
            Vue: 'Vue'
        }),
    ],
  devtool: '#eval-source-map'
}
```
## 创建配置路由
创建 src/view/Layout.vue 
```
<template>
    <div>
        <section class="app-main">
            <div class="container">
                {{msg}}
                <router-view></router-view>
            </div>
        </section>
    </div>
</template>
<style scoped>
</style>
<script>
    export default{
        name:"LayOut",
        data:function(){
            return{
                msg:'this is layout'
            }
        },
    }
</script>
```
创建 src/js/routes.js 
```
const routes = [
    { path: '', component: Layout,
        children: [

        ]
    },
];

export default routes;
```
创建 src/js/router.js 
```
//挂载vue-router
Vue.use(VueRouter);

import routes       from  './routes'

//定义路由
var router = new VueRouter({
    mode: 'hash',
    routes // （缩写）相当于 routes: routes
})

export default router
```
更新 src/view/Main.vue 
 //添加路由标签
```
<style> </style> <script> export default{ replace: true, name:"Main", data() { return { msg: 'Hello Vue!' } }, } </script>
```
# 第五步登录页面

## 登录页面
## 惰性加载
## 更新配置
## 登录授权
## 退出登录

# 第六步页面布局

## 配置webpack
## 配置gulp

