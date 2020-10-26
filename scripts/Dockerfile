FROM ubuntu:20.04

ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Europe/London

ENV MIPS_GCC_ROOT=/opt/mips64-elf

ENV N64_TOOLCHAIN=$MIPS_GCC_ROOT/bin
ENV N64_LIBGCCDIR=$MIPS_GCC_ROOT/lib/gcc/mips64-elf/10.2.0/
ENV N64_NEWLIBDIR=$MIPS_GCC_ROOT/mips64-elf/lib
ENV N64_NEWLIBINCDIR=$MIPS_GCC_ROOT/mips64-elf/include

ENV ROOT=/etc/n64

ENV PATH=$N64_TOOLCHAIN:${PATH}

WORKDIR /opt/local

ADD build-n64-toolchain.sh /opt/mips64-elf/build-n64-toolchain.sh

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y install build-essential git wget libmpfr-dev libmpc-dev libgmp-dev flex bison m4 && \
    apt-get clean && \
    /opt/mips64-elf/build-n64-toolchain.sh && \
    echo "deb [trusted=yes] https://coneyislanddiscopalace.xyz/apt ./" > /etc/apt/sources.list.d/coneyisland.list && \
    apt update && \
    apt-get -y install n64sdk libnusys makemask root-compatibility-enviroment cmake