# eggts-pkg

一个使用 pkg 打包 eggjs(ts 版本)的示例

## 初始化项目

### 1.0.0-使用脚手架初始化 eggjs 项目

```shell
npm init egg --type=ts
```

### 1.0.1-安装依赖

```shell
npm i
```

### 1.0.2-测试运行

```shell
npm run dev
```

### 1.0.3 创建测试用静态文件并配置 egg-etag

```shell
npm install egg-etag
```

在`plugin.ts`中增加配置启用`egg-etag`

```ts
  etag: {
    package: 'egg-etag',
  },
```

## 增加 pkg 相关配置 1.0.4

在项目根目录创建`pkg-entry.js`

```js
"use strict";
const fs = require("fs");

// 如果是egg的ts项目，由于egg-script会给ts项目通过-r引入sourcemap的注入文件，但是pkg的spawn不支持，所以把项目标识为飞ts
// 如果不是ts项目忽略一下两行
const pkgInfo = require("./package");
pkgInfo.egg.typescript = false; // 防止egg-script识别为 typescript 自动添加soucemap支持（--require 在pkg的spawn中不支持）

// 由于egg-script是默认以当前执行proccess.cwd() 路径为默认项目的，打包后需要每次输入 /snapshot/${项目文件夹名} 作为指定目录
// 所以，以下为修改参数，自动嵌入“/snapshot/${项目文件夹名}”
const baseDir = "/snapshot/" + fs.readdirSync("/snapshot")[0];
// 当 start 的时候，自动嵌入bashDir为 /snapshot/${项目文件夹名}
// 如果要传入自定义启动参数也可以在这里处理,如指定是否后台运行，指定端口号等
const startIndex = process.argv.indexOf("start");
if (startIndex > -1) {
  process.argv = [].concat(
    process.argv.slice(0, startIndex + 1),
    baseDir,
    process.argv.slice(startIndex + 1)
  );
}

// 然后直接调起egg-scripts执行
require("./node_modules/egg-scripts/bin/egg-scripts.js");
```

在`.eslintignore`中增加忽略`pkg-entry.js`

在`package.json`中增加以下内容

```json
  "bin": "pkg-entry.js",
  "pkg": {
    "scripts": [
      "./app/**/*.js",
      "./config/**/*.js"
    ],
    "assets": [
      "./app/public/**/*",
      "./node_modules/nanoid/**/*.js"
    ]
  },
```

在项目根目录创建编译脚本`build.sh`

```shell
set -e
# 编译ts为js
npm run tsc
# 编译生成二进制文件
pkg .  --out-path ./dist
# 清理临时js文件
npm run clean
```

将`dist/`目录加入`.gitgnore`

`config.prod.ts`中的可选配置

```ts
// 配置运行时相关文件存储路径
config.rundir = process.cwd() + "/run";

// 配置日志目录
config.logger = {
  dir: process.cwd() + "/logs",
};

// 配置静态资源路径
config.static = {
  prefix: "/public",
  dir: process.cwd() + "/public",
};
```

## 填坑

`.gitignore`中增加 `!pkg-entry.js`

## QuickStart

### Development

```bash
$ npm i
$ npm run dev
$ open http://localhost:7001/
```

Don't tsc compile at development mode, if you had run `tsc` then you need to `npm run clean` before `npm run dev`.

### Deploy

```bash
$ npm run tsc
$ npm start
```

### Npm Scripts

- Use `npm run lint` to check code style
- Use `npm test` to run unit test
- se `npm run clean` to clean compiled js at development mode once

### Requirement

- Node.js 8.x
- Typescript 2.8+
