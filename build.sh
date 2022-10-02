#!/bin/sh

set -ex

if ! command -v apk; then
	echo "This script should be run in an Alpine container"
	exit 1
fi

cd "$(dirname "$0")"

apk update
apk add \
	alpine-sdk \
	autoconf \
	automake \
	binutils \
	file \
	libtool \
	strace \
	util-linux

# Build squashfuse.
apk add zstd-dev zstd-static zlib-dev zlib-static fuse-dev fuse-static
squashfuse_version="0.1.105"
rm -rf squashfuse*
wget -c -q "https://github.com/vasi/squashfuse/archive/refs/tags/${squashfuse_version}.tar.gz"
tar xf "${squashfuse_version}.tar.gz"
rm "${squashfuse_version}.tar.gz"
mv "squashfuse-${squashfuse_version}" squashfuse
cd squashfuse

# We need to make sure only one version of fuse is installed so squashfuse sets the correct FUSE_USE_VERSION.
# See https://github.com/vasi/squashfuse/blob/d1d7dd/m4/squashfuse_fuse.m4#L146-L165
# Let's build both fuse2 and fuse3 variants of squashfuse and then wrap the symbols so we can choose at runtime.
# See https://stackoverflow.com/a/6940389/5559867

# Build fuse2 variant of static squashfuse
apk del fuse3-dev fuse3-static
./autogen.sh
./configure --disable-demo CFLAGS=-no-pie LDFLAGS=-static
make -j
make install
objcopy --prefix-symbols f2_ \
	--strip-all --keep-symbol=f2_sqfs_ll_mount --keep-symbol=f2_sqfs_ll_unmount \
	/usr/local/lib/libsquashfuse_ll.a /usr/local/lib/libf2_squashfuse_ll.a
ranlib /usr/local/lib/libf2_squashfuse_ll.a

# Build fuse3 variant of static squashfuse
apk add fuse3-dev fuse3-static
./autogen.sh
./configure --disable-demo CFLAGS=-no-pie LDFLAGS=-static
make -j
make install
/usr/bin/install -c -m 644 fuseprivate.h /usr/local/include/squashfuse

cd -
# rm -rf squashfuse

# Build static AppImage runtime
export GIT_COMMIT=$(cat src/runtime/version)
cd src/runtime
make clean
make -j
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
mv src/runtime/runtime out/runtime-"${appimage_arch}"
