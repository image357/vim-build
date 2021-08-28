FROM alpine:latest

RUN apk add --no-cache \
    git gcc g++ make cmake mandoc man-pages tmux \
    libc-dev libffi-dev zlib-dev openssl-dev gdbm-dev readline-dev bzip2-dev \
    xz-dev libuuid util-linux-dev ncurses-dev ncurses-libs libc6-compat

