#!/bin/bash
# 通用 SPK 打包：修改 build.conf 后直接运行
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "$ROOT/build.conf"

: "${PKG_NAME:?PKG_NAME is required}"
: "${VERSION:?VERSION is required}"
: "${ARCH:=noarch}"
: "${OS_MIN:=7.0-40120}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
STAGE="$WORK/stage"
mkdir -p "$STAGE" "$ROOT/dist"

# 1) package.tgz：pkg/ 下的内容原样进入 SYNOPKG_PKGDEST
cp -a "$ROOT/pkg/." "$STAGE/"
find "$STAGE" -type f -name '*.sh' -exec chmod 755 {} \;
tar czf "$WORK/package.tgz" -C "$STAGE" .

CHECKSUM="$(md5sum "$WORK/package.tgz" | cut -d' ' -f1)"

# 2) scripts / conf / WIZARD_UIFILES
mkdir -p "$WORK/scripts" "$WORK/conf" "$WORK/WIZARD_UIFILES"
cp -a "$ROOT/spk/scripts/." "$WORK/scripts/"
chmod 755 "$WORK/scripts/"*

sed "s|@PKG_NAME@|$PKG_NAME|g" "$ROOT/spk/conf/privilege" > "$WORK/conf/privilege"

for f in "$ROOT"/spk/WIZARD_UIFILES/*; do
    sed -e "s|@PKG_NAME@|$PKG_NAME|g" \
        -e "s|@DISPLAY_NAME@|${DISPLAY_NAME:-$PKG_NAME}|g" \
        "$f" > "$WORK/WIZARD_UIFILES/$(basename "$f")"
done

# 3) INFO（只能 key="value"，不能有空行/注释）
sed -e "s|@PKG_NAME@|$PKG_NAME|g" \
    -e "s|@VERSION@|$VERSION|g" \
    -e "s|@DISPLAY_NAME@|${DISPLAY_NAME:-$PKG_NAME}|g" \
    -e "s|@DESCRIPTION@|${DESCRIPTION:-}|g" \
    -e "s|@DESCRIPTION_CHS@|${DESCRIPTION_CHS:-}|g" \
    -e "s|@DESCRIPTION_CHT@|${DESCRIPTION_CHT:-}|g" \
    -e "s|@ARCH@|$ARCH|g" \
    -e "s|@OS_MIN@|$OS_MIN|g" \
    -e "s|@MAINTAINER@|${MAINTAINER:-}|g" \
    -e "s|@MAINTAINER_URL@|${MAINTAINER_URL:-}|g" \
    -e "s|@CHECKSUM@|$CHECKSUM|g" \
    "$ROOT/spk/INFO.template" > "$WORK/INFO"

if grep -Evq '^[A-Za-z_]+=".*"$' "$WORK/INFO"; then
    echo "ERROR: INFO contains invalid lines:" >&2
    grep -Env '^[A-Za-z_]+=".*"$' "$WORK/INFO" >&2
    exit 1
fi

# 4) 图标 / LICENSE（存在才带）
EXTRA=()
for f in PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG LICENSE; do
    if [ -f "$ROOT/$f" ]; then
        cp "$ROOT/$f" "$WORK/$f"
        EXTRA+=("$f")
    fi
done

# 5) 打包 .spk（未压缩 tar）
SPK="$ROOT/dist/${PKG_NAME}_${ARCH}-dsm7_${VERSION}.spk"
rm -f "$SPK"
( cd "$WORK" && tar cpf "$SPK" INFO package.tgz scripts conf WIZARD_UIFILES "${EXTRA[@]}" )
echo "==> $SPK"
tar tf "$SPK" | head -20
