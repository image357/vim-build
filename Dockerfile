FROM alpine:latest

RUN mkdir /root/install
RUN mkdir /root/src
RUN apk add --no-cache git gcc g++ make mandoc man-pages tmux libc-dev libffi-dev zlib-dev openssl-dev gdbm-dev readline-dev bzip2-dev

