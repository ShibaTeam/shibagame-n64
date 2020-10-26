#!/bin/bash
set -eu

#
# tools/build-linux64-toolchain.sh: Linux toolchain build script.
#
# n64chain: A (free) open-source N64 development toolchain.
# Copyright 2014-16 Tyler J. Stachecki <stachecki.tyler@gmail.com>
#
# This file is subject to the terms and conditions defined in
# 'LICENSE', which is part of this source code package.
#

getnumproc() {
which getconf >/dev/null 2>/dev/null && {
	getconf _NPROCESSORS_ONLN 2>/dev/null || getconf NPROCESSORS_ONLN 2>/dev/null || echo 1;
} || echo 1;
};

numproc=`getnumproc`

BINUTILS="ftp://ftp.gnu.org/gnu/binutils/binutils-2.30.tar.bz2"
GCC="ftp://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.gz"
NEWLIB="ftp://sourceware.org/pub/newlib/newlib-3.3.0.tar.gz"


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${SCRIPT_DIR} && mkdir -p {stamps,tarballs}

export PATH="${PATH}:${SCRIPT_DIR}/bin"

if [ ! -f stamps/binutils-download ]; then
  wget "${BINUTILS}" -O "tarballs/$(basename ${BINUTILS})"
  touch stamps/binutils-download
fi

if [ ! -f stamps/binutils-extract ]; then
  mkdir -p binutils-{build,source}
  tar -xf tarballs/$(basename ${BINUTILS}) -C binutils-source --strip 1
  touch stamps/binutils-extract
fi

if [ ! -f stamps/binutils-configure ]; then
  pushd binutils-build
  ../binutils-source/configure \
    --prefix="${SCRIPT_DIR}" \
    --with-lib-path="${SCRIPT_DIR}/lib" \
    --target=mips64-elf --with-arch=vr4300 \
    --enable-64-bit-bfd \
    --enable-plugins \
    --enable-shared \
    --disable-gold \
    --disable-multilib \
    --disable-nls \
    --disable-rpath \
    --disable-static \
    --disable-werror
  popd

  touch stamps/binutils-configure
fi

if [ ! -f stamps/binutils-build ]; then
  pushd binutils-build
  make -j${numproc}
  popd

  touch stamps/binutils-build
fi

if [ ! -f stamps/binutils-install ]; then
  pushd binutils-build
  make install
  popd

  touch stamps/binutils-install
fi

if [ ! -f stamps/gcc-download ]; then
  wget "${GCC}" -O "tarballs/$(basename ${GCC})"
  touch stamps/gcc-download
fi

if [ ! -f stamps/gcc-extract ]; then
  mkdir -p gcc-{build,source}
  tar -xf tarballs/$(basename ${GCC}) -C gcc-source --strip 1
  touch stamps/gcc-extract
fi

if [ ! -f stamps/gcc-configure ]; then
  pushd gcc-build
  ../gcc-source/configure \
    --prefix="${SCRIPT_DIR}" \
    --target=mips64-elf --with-arch=vr4300 \
    --enable-languages=c,c++ --with-newlib \
    --with-gnu-as=${SCRIPT_DIR}/bin/mips64-elf-as \
    --with-gnu-ld=${SCRIPT_DIR}/bin/mips64-elf-ld \
    --enable-checking=release \
    --enable-shared \
    --enable-shared-libgcc \
    --disable-decimal-float \
    --disable-gold \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libitm \
    --disable-libquadmath \
    --disable-libquadmath-support \
    --disable-libsanitizer \
    --disable-libssp \
    --disable-libunwind-exceptions \
    --disable-libvtv \
    --disable-multilib \
    --disable-nls \
    --disable-rpath \
    --disable-threads \
    --disable-win32-registry \
    --enable-lto \
    --enable-plugin \
    --enable-static \
    --without-included-gettext
  popd

  touch stamps/gcc-configure
fi

if [ ! -f stamps/gcc-build ]; then
  pushd gcc-build
  make all-gcc -j${numproc}
  popd

  touch stamps/gcc-build
fi

if [ ! -f stamps/gcc-install ]; then
  pushd gcc-build
  make install-gcc
  popd

  # build-win32-toolchain.sh needs this; the cross-compiler build
  # will look for mips64-elf-cc and we only have mips64-elf-gcc.
  pushd "${SCRIPT_DIR}/bin"
  ln -sfv mips64-elf-{gcc,cc}
  popd

  touch stamps/gcc-install
fi

echo "" >> ./gcc-source/libgcc/config/mips/t-mips64


wget ftp://sourceware.org/pub/newlib/newlib-3.3.0.tar.gz

test -d newlib-3.3.0 || tar -xzf newlib-3.3.0.tar.gz

cd newlib-3.3.0
  CFLAGS_FOR_TARGET="-mabi=32 -march=vr4300 -mtune=vr4300 -mfix4300 -O2 -G 0 -fno-PIC" CXXFLAGS_FOR_TARGET="-mabi=32 -march=vr4300 -mtune=vr4300 -mfix4300 -O2 -G 0 -fno-PIC" ./configure --target=mips64-elf --prefix=${SCRIPT_DIR} --with-cpu=mips64vr4300 --disable-threads --disable-libssp --disable-werror
  make -j${numproc}
  make install
cd ..


cd gcc-build
  make CC_FOR_TARGET=${SCRIPT_DIR}/bin/mips64-elf-gcc CFLAGS_FOR_TARGET="-D_MIPS_SZLONG=32 -D_MIPS_SZINT=32 -mabi=32 -march=vr4300 -mtune=vr4300 -mfix4300 -G 0 -fno-PIC" CXXFLAGS_FOR_TARGET="-D_MIPS_SZLONG=32 -D_MIPS_SZINT=32 -mabi=32 -march=vr4300 -mtune=vr4300 -mfix4300 -G 0 -fno-PIC" -j${numproc}
  make install
cd ..

# Get checksum
wget https://raw.githubusercontent.com/tj90241/n64chain/master/tools/checksum.c
gcc checksum.c -o bin/checksum
rm checksum.c

rm -rf "${SCRIPT_DIR}"/tarballs
rm "newlib-3.3.0.tar.gz"
rm -rf newlib-3.3.0
rm -rf "${SCRIPT_DIR}"/*-source
rm -rf "${SCRIPT_DIR}"/*-build
rm -rf "${SCRIPT_DIR}"/stamps
exit 0

