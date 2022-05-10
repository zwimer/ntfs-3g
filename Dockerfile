FROM aflplusplus/aflplusplus

RUN apt-get update && apt-get install -y libgcrypt-dev

WORKDIR /
RUN git clone https://github.com/tuxera/ntfs-3g.git

ENV AFL_USE_ASAN=1
WORKDIR /ntfs-3g
RUN ./autogen.sh && CC=afl-clang-lto CFLAGS="-O3" CXX=afl-clang-lto++ RANLIB=llvm-ranlib-12 AR=llvm-ar-12 ./configure --enable-shared=no
RUN make -j$(nproc)

RUN mkdir -p /fuzz/in
RUN mkdir -p /fuzz/out
RUN mkdir -p /fuzz/mount
COPY smol.img /fuzz/in

WORKDIR /fuzz
ENTRYPOINT ["afl-fuzz", "-i", "/fuzz/in", "-o", "/fuzz/out"]
CMD ["/ntfs-3g/src/ntfs-3g", "@@", "/fuzz/mount"]

