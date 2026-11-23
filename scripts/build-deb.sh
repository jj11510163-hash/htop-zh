#!/bin/sh
#
# build-deb.sh - 把编译好的静态二进制打成 .deb 包
#
# 用法:
#   ./scripts/build-deb.sh [二进制] [版本]
#   ./scripts/build-deb.sh ../htop-3.4.1/htop 3.4.1-1
#
# 生成的包: dist/htop-zh_<版本>_amd64.deb
#
set -e

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
BIN=${1:-"$ROOT/htop-3.4.1/htop"}
VERSION=${2:-3.4.1-1}
OUT="$ROOT/dist"
PKG="$ROOT/dist/pkg"

if [ ! -f "$BIN" ]; then
   echo "找不到二进制: $BIN（先运行 scripts/build.sh --static）" >&2
   exit 1
fi
if ! command -v dpkg-deb >/dev/null 2>&1; then
   echo "需要 dpkg-deb（Debian/Ubuntu: apt install dpkg-dev；Alpine: apk add dpkg）" >&2
   exit 1
fi

rm -rf "$PKG"
mkdir -p "$PKG/DEBIAN" "$PKG/usr/bin"

install -m 755 "$BIN" "$PKG/usr/bin/htop-zh"

sed "s/^Version: .*/Version: $VERSION/" "$ROOT/packaging/control" > "$PKG/DEBIAN/control"
chmod 644 "$PKG/DEBIAN/control"

mkdir -p "$OUT"
dpkg-deb --build --root-owner-group "$PKG" "$OUT/htop-zh_${VERSION}_amd64.deb"

echo "已生成: $OUT/htop-zh_${VERSION}_amd64.deb"
dpkg-deb -c "$OUT/htop-zh_${VERSION}_amd64.deb"
