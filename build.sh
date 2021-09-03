#!/usr/bin/env bash
set -e
trap ontrap 0

# input env
export VIM_BUILD_PREFIX=$(pwd)
export INSTALL_PREFIX="$VIM_BUILD_PREFIX/install"
export BUILD_PREFIX="$VIM_BUILD_PREFIX/src"

ontrap()
{
    cd "$VIM_BUILD_PREFIX"
    exec /bin/sh -i
}

# versions
export ZLIB_VERSION="1.2.11"
export LIBFFI_VERSION="3.4.2"
export PYTHON_VERSION="3.9.6"
export RUBY_VERSION="3.0.2"
export VIM_VERSION="8.2.3384"

setup_env()
{
    # base env
    PATH="$INSTALL_PREFIX/bin${PATH:+:${PATH}}"; export PATH
    MANPATH="$INSTALL_PREFIX/share/man${MANPATH:+:${MANPATH}}"; export MANPATH
    LD_RUN_PATH="$INSTALL_PREFIX/lib:$INSTALL_PREFIX/lib64${LD_RUN_PATH:+:${LD_RUN_PATH}}"; export LD_RUN_PATH

    # zlib
    export ZLIB_FILE="zlib-$ZLIB_VERSION.tar.gz"
    export ZLIB_FOLDER="zlib-$ZLIB_VERSION"
    export ZLIB_URL="https://github.com/madler/zlib/archive/refs/tags/v$ZLIB_VERSION.tar.gz"

    # libffi
    export LIBFFI_FILE="libffi-$LIBFFI_VERSION.tar.gz"
    export LIBFFI_FOLDER="libffi-$LIBFFI_VERSION"
    export LIBFFI_URL="https://github.com/libffi/libffi/releases/download/v$LIBFFI_VERSION/libffi-$LIBFFI_VERSION.tar.gz"

    # python
    export PYTHON_FILE="Python-$PYTHON_VERSION.tgz"
    export PYTHON_FOLDER="Python-$PYTHON_VERSION"
    export PYTHON_URL="https://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_FILE"

    # ruby
    export RUBY_FILE="ruby-$RUBY_VERSION.tar.gz"
    export RUBY_FOLDER="ruby-$RUBY_VERSION"
    RUBY_VERSION_SPLIT0=$(echo "$RUBY_VERSION" | cut -d "." -f1)
    RUBY_VERSION_SPLIT1=$(echo "$RUBY_VERSION" | cut -d "." -f2)
    export RUBY_URL="https://cache.ruby-lang.org/pub/ruby/$RUBY_VERSION_SPLIT0.$RUBY_VERSION_SPLIT1/$RUBY_FILE"

    # vim
    export VIM_FILE="vim-$VIM_VERSION.tar.gz"
    export VIM_FOLDER="vim-$VIM_VERSION"
    export VIM_URL="https://github.com/vim/vim/archive/refs/tags/v$VIM_VERSION.tar.gz"
}

download_and_extract_targz()
{
    PREFIX="$1"
    FILE_NAME="${PREFIX}_FILE"
    FOLDER_NAME="${PREFIX}_FOLDER"
    URL_NAME="${PREFIX}_URL"

    eval FILE="\$${FILE_NAME}"
    eval FOLDER="\$${FOLDER_NAME}"
    eval URL="\$${URL_NAME}"

    cd "$BUILD_PREFIX"
    if [ ! -f "$$FILE" ]; then
        wget -O "$FILE" "$URL"
    fi
    rm -rf "$FOLDER"
    tar -xzf "$FILE"
}

download_sources()
{
    download_and_extract_targz "ZLIB"
    download_and_extract_targz "LIBFFI"
    download_and_extract_targz "PYTHON"
    download_and_extract_targz "RUBY"
    download_and_extract_targz "VIM"
}

cleanup_file_and_folder()
{
    PREFIX="$1"
    FILE_NAME="${PREFIX}_FILE"
    FOLDER_NAME="${PREFIX}_FOLDER"

    eval FILE="\$${FILE_NAME}"
    eval FOLDER="\$${FOLDER_NAME}"

    cd "$BUILD_PREFIX"
    rm "$FILE"
    rm -r "$FOLDER"
}

cleanup()
{
    cleanup_file_and_folder "ZLIB"
    cleanup_file_and_folder "LIBFFI"
    cleanup_file_and_folder "PYTHON"
    cleanup_file_and_folder "RUBY"
    cleanup_file_and_folder "VIM"
}

build_with_configure_and_make()
{
    PREFIX="$1"
    FOLDER_NAME="${PREFIX}_FOLDER"
    eval FOLDER="\$${FOLDER_NAME}"

    args=("$@")
    args[0]="--prefix=${INSTALL_PREFIX}"

    cd "$BUILD_PREFIX"
    cd "$FOLDER"
    echo $FOLDER
    echo $(pwd)
    ./configure "${args[@]}"
    make -j $(nproc)
    make install
}

build()
{
    build_with_configure_and_make "ZLIB"

    build_with_configure_and_make "LIBFFI"

    build_with_configure_and_make "PYTHON" \
        --enable-shared \
        --enable-optimizations

    build_with_configure_and_make "RUBY"

    build_with_configure_and_make "VIM" \
        --with-features=huge \
        --enable-multibyte \
        --enable-rubyinterp=yes \
        --enable-python3interp=yes \
        --with-python3-config-dir=$(python3-config --configdir) \
        --enable-perlinterp=no \
        --enable-luainterp=no \
        --enable-gui=no \
        --enable-cscope
}

# run stuff
cd "$VIM_BUILD_PREFIX"
mkdir -p "$INSTALL_PREFIX"
mkdir -p "$BUILD_PREFIX"
setup_env
download_sources
build

# cleanup
cleanup

