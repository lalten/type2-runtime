#!/bin/sh

set -ex

if ! command -v apk; then
	echo "This script should be run in an Alpine container"
	exit 1
fi

cd "$(dirname "$0")"

apk update
apk add alpine-sdk util-linux strace file autoconf automake libtool

# Build static squashfuse
apk add fuse3-static fuse3-dev zstd-dev zstd-static zlib-dev zlib-static
squashfuse_version="0.1.105"
wget -c -q "https://github.com/vasi/squashfuse/archive/refs/tags/${squashfuse_version}.tar.gz"
tar xf "${squashfuse_version}.tar.gz"
rm "${squashfuse_version}.tar.gz"
cd "squashfuse-${squashfuse_version}"
./autogen.sh
./configure --disable-demo CFLAGS=-no-pie LDFLAGS=-static
make -j
make install
/usr/bin/install -c -m 644 fuseprivate.h /usr/local/include/squashfuse
cd -
rm -rf "squashfuse-${squashfuse_version}"

# Build static AppImage runtime
export GIT_COMMIT=$(cat src/runtime/version)
cd src/runtime
make runtime -j
file runtime
strip runtime
ls -lh runtime
echo -ne 'AI\x02' | dd of=runtime bs=1 count=3 seek=8 conv=notrunc # magic bytes, always do AFTER strip
cd -

# Use the same architecture names as https://github.com/AppImage/AppImageKit/releases/
appimage_arch="$(apk --print-arch)"
appimage_arch="${appimage_arch/armv*/armhf}" # replaces "armv7l" with "armhf"
if [ "$appimage_arch" = "x86" ]; then appimage_arch=i686; fi

mkdir -p out
mv src/runtime/runtime "out/runtime-${appimage_arch}"
