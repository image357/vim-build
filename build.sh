#!/bin/sh
set -e
trap ontrap 0

# input env
export VIM_BUILD_PREFIX=$(pwd)
export INSTALL_PREFIX="$HOME/install"
export BUILD_PREFIX="$HOME/src"
export PYTHON_VERSION="3.9.6"

ontrap()
{
    cd "$VIM_BUILD_PREFIX"
    exec /bin/sh -i
}

setup_env()
{
    # python
    export PYTHON_FILE="Python-$PYTHON_VERSION.tgz"
    export PYTHON_FOLDER="Python-$PYTHON_VERSION"
    export PYTHON_URL="https://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_FILE"
}

download_sources()
{
    cd "$BUILD_PREFIX"

    # python
    if [ ! -f "$PYTHON_FILE" ]; then
        wget "$PYTHON_URL"
    fi
}

cleanup()
{
    cd "$BUILD_PREFIX"

    # python
    rm "$PYTHON_FILE"
    rm -r "$PYTHON_FOLDER"
}


# prepare env
cd "$VIM_BUILD_PREFIX"
. environment
mkdir -p "$INSTALL_PREFIX"
mkdir -p "$BUILD_PREFIX"
setup_env
download_sources

# build python
cd "$BUILD_PREFIX"
rm -rf "$PYTHON_FOLDER"
tar -xzf "$PYTHON_FILE"
cd "$PYTHON_FOLDER"
mkdir build
cd build
../configure --enable-shared --enable-optimizations --prefix="$INSTALL_PREFIX"
make -j $(nproc)
make install

# cleanup
cleanup

