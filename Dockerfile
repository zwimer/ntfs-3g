FROM aflplusplus/aflplusplus as builder

RUN apt-get update && apt-get install -y libgcrypt-dev

WORKDIR /
RUN git clone https://github.com/tuxera/ntfs-3g.git

ENV AFL_USE_ASAN=1
WORKDIR /ntfs-3g
RUN ./autogen.sh && CC=afl-clang-lto CFLAGS="-O3" CXX=afl-clang-lto++ RANLIB=llvm-ranlib-14 AR=llvm-ar-14 ./configure --enable-shared=no
RUN make -j$(nproc)

FROM ubuntu:22.04
COPY --from=builder /ntfs-3g/src/ntfs-3g /
RUN mkdir /mount
