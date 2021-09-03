FROM alpine:latest

RUN apk add --no-cache \
    bash git gcc g++ make cmake mandoc man-pages tmux \
    musl-dev libc-dev libc6-compat linux-headers \
    openssl-dev gdbm-dev readline-dev bzip2-dev xz-dev \
    libuuid util-linux-dev ncurses-dev ncurses-libs 

