#!/bin/bash

podman run -it -v $(pwd):/root/vim-build -w /root/vim-build --security-opt label=disable --rm \
    vim-build /bin/sh --login

