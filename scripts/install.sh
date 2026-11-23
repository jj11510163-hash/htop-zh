#!/bin/sh
#
# install.sh - 把中文版 htop 安装到系统
#
# 用法:
#   ./install.sh [可执行文件]      默认找 ../htop-3.4.1/htop
#   PREFIX=/usr ./install.sh       自定义安装前缀（默认 /usr/local）
#
set -e

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
SRC=${1:-"$ROOT/htop-3.4.1/htop"}
PREFIX=${PREFIX:-/usr/local}
BIN="$PREFIX/bin/htop-zh"

if [ ! -f "$SRC" ]; then
   echo "找不到可执行文件: $SRC" >&2
   echo "请先运行 scripts/build.sh，或把二进制路径作为参数传入" >&2
   exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
   SUDO=""
else
   SUDO="sudo"
fi

echo "== 安装到 $BIN =="
$SUDO install -d "$PREFIX/bin"
$SUDO install -m 755 "$SRC" "$BIN"

echo "== 生成 htopzh 启动命令 =="
$SUDO sh -c "printf '#!/bin/sh\nHTOP_LANG=zh exec %s \"\$@\"\n' > $PREFIX/bin/htopzh"
$SUDO chmod 755 "$PREFIX/bin/htopzh"

echo
echo "安装完成："
echo "  htop-zh       中文界面"
echo "  htopzh        同上（强制中文）"
echo "  HTOP_LANG=en htop-zh   英文界面"
