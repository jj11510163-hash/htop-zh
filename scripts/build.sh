#!/bin/sh
#
# build.sh - 构建中文版 htop
#
# 用法:
#   ./build.sh                 下载 htop 3.4.1 并编译（动态链接）
#   ./build.sh --static        编译静态二进制
#   ./build.sh --source DIR    使用已有的 htop 源码目录
#   ./build.sh --tarball FILE  使用本地源码压缩包（离线）
#
set -e

VERSION=3.4.1
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
PATCH="$ROOT/patch/htop-${VERSION}-zh.patch"

STATIC=""
SRCDIR="$ROOT/htop-${VERSION}"
TARBALL=""

while [ $# -gt 0 ]; do
   case "$1" in
      --static)  STATIC="-static" ;;
      --source)  SRCDIR="$2"; shift ;;
      --tarball) TARBALL="$2"; shift ;;
      -h|--help)
         sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
         exit 0 ;;
      *) echo "未知参数: $1" >&2; exit 1 ;;
   esac
   shift
done

if [ ! -f "$PATCH" ]; then
   echo "找不到补丁: $PATCH" >&2
   exit 1
fi

if [ ! -d "$SRCDIR" ]; then
   if [ -z "$TARBALL" ]; then
      TARBALL="$ROOT/htop-${VERSION}.tar.gz"
   fi
   if [ ! -f "$TARBALL" ]; then
      echo "== 下载 htop ${VERSION} 源码 =="
      curl -fL -o "$TARBALL" \
         "https://codeload.github.com/htop-dev/htop/tar.gz/refs/tags/${VERSION}" \
      || { echo "下载失败，请手动下载后用 --tarball 指定" >&2; exit 1; }
   fi
   echo "== 解压 =="
   mkdir -p "$SRCDIR"
   tar xzf "$TARBALL" -C "$SRCDIR" --strip-components=1
fi

echo "== 应用中文补丁 =="
( cd "$SRCDIR" && patch -p1 --forward < "$PATCH" )

cd "$SRCDIR"
if [ ! -x ./configure ]; then
   echo "== 生成 configure =="
   sh autogen.sh
fi

echo "== 配置与编译 =="
./configure --enable-unicode ${STATIC:+LDFLAGS=-static}
make -j"$(nproc 2>/dev/null || echo 2)"

if [ -n "$STATIC" ]; then
   strip htop 2>/dev/null || true
fi

echo
echo "构建完成: $SRCDIR/htop"
echo "运行:     LANG=zh_CN.UTF-8 $SRCDIR/htop"
