# Stage 1: Build the i386-elf cross-compiler toolchain
FROM ubuntu:22.04 AS toolchain

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential bison flex libgmp-dev libmpc-dev \
    libmpfr-dev texinfo wget ca-certificates xz-utils && \
    rm -rf /var/lib/apt/lists/*

ENV PREFIX=/opt/cross
ENV TARGET=i386-elf
ENV PATH="$PREFIX/bin:$PATH"

WORKDIR /tmp/build

# Build binutils
RUN wget -q https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz && \
    tar xf binutils-2.41.tar.xz && \
    mkdir build-binutils && cd build-binutils && \
    ../binutils-2.41/configure --target=$TARGET --prefix=$PREFIX \
        --with-sysroot --disable-nls --disable-werror && \
    make -j$(nproc) && make install && \
    cd /tmp/build && rm -rf binutils-2.41 build-binutils binutils-2.41.tar.xz

# Build GCC (C only, freestanding)
RUN wget -q https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz && \
    tar xf gcc-13.2.0.tar.xz && \
    mkdir build-gcc && cd build-gcc && \
    ../gcc-13.2.0/configure --target=$TARGET --prefix=$PREFIX \
        --disable-nls --enable-languages=c --without-headers && \
    make -j$(nproc) all-gcc all-target-libgcc && \
    make install-gcc install-target-libgcc && \
    cd /tmp/build && rm -rf gcc-13.2.0 build-gcc gcc-13.2.0.tar.xz

# Stage 2: Build + run environment
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    nasm make qemu-system-x86 libncursesw5 \
    libgmp10 libmpc3 libmpfr6 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=toolchain /opt/cross /opt/cross
ENV PATH="/opt/cross/bin:$PATH"

WORKDIR /boota
