#!/bin/sh
set -e
trap ontrap 0

# input env
export VIM_BUILD_PREFIX=$(pwd)
export INSTALL_PREFIX="$VIM_BUILD_PREFIX/install"
export BUILD_PREFIX="$VIM_BUILD_PREFIX/src"
export PYTHON_VERSION="3.9.6"
export RUBY_VERSION="3.0.2"

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

    # ruby
    export RUBY_FILE="ruby-$RUBY_VERSION.tar.gz"
    export RUBY_FOLDER="ruby-$RUBY_VERSION"
    RUBY_VERSION_SPLIT0=$(echo "$RUBY_VERSION" | cut -d "." -f1)
    RUBY_VERSION_SPLIT1=$(echo "$RUBY_VERSION" | cut -d "." -f2)
    export RUBY_URL="https://cache.ruby-lang.org/pub/ruby/$RUBY_VERSION_SPLIT0.$RUBY_VERSION_SPLIT1/$RUBY_FILE"
}

download_sources()
{
    cd "$BUILD_PREFIX"

    # python
    if [ ! -f "$PYTHON_FILE" ]; then
        wget "$PYTHON_URL"
    fi
    rm -rf "$PYTHON_FOLDER"
    tar -xzf "$PYTHON_FILE"

    # ruby
    if [ ! -f "$RUBY_FILE" ]; then
        wget "$RUBY_URL"
    fi
    rm -rf "$RUBY_FOLDER"
    tar -xzf "$RUBY_FILE"
}

cleanup()
{
    cd "$BUILD_PREFIX"

    # python
    rm "$PYTHON_FILE"
    rm -r "$PYTHON_FOLDER"

    # ruby
    rm "$RUBY_FILE"
    rm -r "$RUBY_FOLDER"
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
cd "$PYTHON_FOLDER"
mkdir build
cd build
../configure --enable-shared --enable-optimizations --prefix="$INSTALL_PREFIX"
make -j $(nproc)
make install

# build ruby
cd "$BUILD_PREFIX"
cd "$RUBY_FOLDER"
mkdir build
cd build
../configure --prefix="$INSTALL_PREFIX"
make -j $(nproc)
make install

# cleanup
cleanup

