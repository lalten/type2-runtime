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
apk add fuse-dev fuse-static zstd-dev zstd-static zlib-dev zlib-static # fuse3-static fuse3-dev
wget -c -q "https://github.com/vasi/squashfuse/archive/e51978c.tar.gz"
tar xf e51978c.tar.gz
rm e51978c.tar.gz
cd squashfuse-*/
./autogen.sh
./configure --help
./configure CFLAGS=-no-pie LDFLAGS=-static
make -j$(nproc)
make install
/usr/bin/install -c -m 644 fuseprivate.h /usr/local/include/squashfuse
cd -
rm -rf squashfuse-*

# Build static AppImage runtime
export GIT_COMMIT=$(cat src/runtime/version)
cd src/runtime
make runtime-fuse2 -j$(nproc)
file runtime-fuse2
strip runtime-fuse2
ls -lh runtime-fuse2
echo -ne 'AI\x02' | dd of=runtime-fuse2 bs=1 count=3 seek=8 conv=notrunc # magic bytes, always do AFTER strip
cd -

# Use the same architecture names as https://github.com/AppImage/AppImageKit/releases/
appimage_arch="$(apk --print-arch)"
appimage_arch="${appimage_arch/armv*/armhf}" # replaces "armv7l" with "armhf"
if [ "$appimage_arch" = "x86" ]; then appimage_arch=i686; fi

mkdir -p out
mv src/runtime/runtime-fuse2 "out/runtime-fuse2-${appimage_arch}"
