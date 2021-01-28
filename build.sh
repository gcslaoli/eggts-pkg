set -e 
# 编译ts为js
npm run tsc
# 编译生成二进制文件
pkg .  --out-path ./dist
# 清理临时js文件
npm run clean