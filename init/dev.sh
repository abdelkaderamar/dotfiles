archi=$(uname -m)

if [ -z ${LD_LIBRARY_PATH+x} ]
then
  export LD_LIBRARY_PATH=/usr/local/lib
fi

function create_tmp_and_clone()
{
  local LIBRARY_NAME=$1
  local DOWNLOAD_URL=$2
  e_header "Installing $LIBRARY_NAME library (master branch)"
  tmp_dir=$(mktemp -d)
  cd $tmp_dir && e_arrow downloading ... && \
  git clone "$DOWNLOAD_URL" && \
  return 0

  e_error "Failed to download $LIBRARY_NAME"
  return 1
}

function create_tmp_and_download()
{
  local LIBRARY_NAME=$1
  local DOWNLOAD_URL=$2
  local FILENAME=${DOWNLOAD_URL##*/}
  e_header "Installing $LIBRARY_NAME library (master branch)"
  tmp_dir=$(mktemp -d)
  cd $tmp_dir && e_arrow downloading ... && \
  wget -q "$DOWNLOAD_URL" && \
  tar xf ${FILENAME}
  return 0

  e_error "Failed to download $LIBRARY_NAME"
  return 1
}

function build_with_cmake()
{
  local SRC_DIR="$1"
  local SOFT_NAME="$2"
  e_arrow building .. && \
  cd "$SRC_DIR" && \
  mkdir build && \
  cd build && \
  cmake .. -DCMAKE_BUILD_TYPE=RELEASE && \
  make -j 2 > /tmp/"$SOFT_NAME"_make.log 2>&1 && \
  e_arrow installing ... && \
  sudo make install > /tmp/"$SOFT_NAME"_install.log && rm -fr $tmp_dir
  res=$?
  if [ $res -ne 0 ]
  then
    e_error "$SOFT_NAME installaton done with error code $res"
    e_arrow Check log files /tmp/"$SOFT_NAME"_*
    return 0
  else
    e_arrow "$SOFT_NAME installaton done with error code $res"
    return 1
  fi
}

# Go language
GO_VERSION=1.10.1
go_suffix=''
case "$archi" in
  "armv6l") go_suffix=arm;;
  "i686")   go_suffix=386;;
  "x86_64") go_suffix=amd64;;
  *);;
esac

if [ ! -z "$go_suffix" ]
then
  e_header "Installing Go language go-$GO_VERSION"
  if [ -d $SOFT_DIR/go-$GO_VERSION ]
  then
    e_arrow "An existing Go directory exists [$SOFT_DIR/go-$GO_VERSION]"
  else
    go_dir=go${GO_VERSION}-linux-${go_suffix}
    go_filename=go${GO_VERSION}.linux-${go_suffix}.tar.gz
    go_url=https://dl.google.com/go/${go_filename}
    tmp_dir=$(mktemp -d)
    cd $tmp_dir && wget -q "$go_url" && tar xf $go_filename  && \
      mv -i go $SOFT_DIR/go-$GO_VERSION && \
      cd $SOFT_DIR && ln -sf go-$GO_VERSION go &&  \
      rm -fr "${tmp_dir}"
    e_arrow "Go installaton done"
  fi
else
  e_warn "Unknwon architecture [$go_suffix]=> GO will not be installed"
fi
# End Go installation


# Google-test installation
GTEST_VERSION=1.8.0
e_header "Installing google-test library $GTEST_VERSION"
if [ -f /usr/local/include/gtest/gtest.h -a -f /usr/local/lib/libgtest.a ]
then
  e_arrow "Gtest is already installed"
else
  gtest_filename=release-${GTEST_VERSION}.tar.gz
  gtest_url=https://github.com/google/googletest/archive/${gtest_filename}
  tmp_dir=$(mktemp -d)
  CXX_PATH=$(which g++)
  cd $tmp_dir && e_arrow downloading ... && \
    wget -q "$gtest_url" && tar xf $gtest_filename  && \
    mkdir build && cd build && \
    cmake ../googletest-release-${GTEST_VERSION} \
          -DCMAKE_CXX_COMPILER=${CXX_PATH} > /tmp/gtest_cmake.log && \
    e_arrow building ... && \
    make -j 2 > /tmp/gtest_make.log && \
    e_arrow installing ... && \
    sudo make install > /tmp/gtest_install.log && \
    rm -fr "${tmp_dir}"
fi
e_arrow "Gtest installaton done with error code $?"
# End Google-test installation

# Quickfix installation
if [ -f /usr/local/include/quickfix/Message.h -a -f /usr/local/lib/libquickfix.so ]
then
  e_arrow "Quickfix is already installed"
else
  e_header "Installing quickfix library (master branch)"
  tmp_dir=$(mktemp -d)
  cd $tmp_dir && e_arrow downloading ... && \
  git clone https://github.com/quickfix/quickfix.git && \
  cd quickfix && \
  e_arrow building ... && \
  ./bootstrap  > /tmp/quickfix_bootstrap.log 2>&1 && \
  ./configure  > /tmp/quickfix_configure.log 2>&1 && \
  make -j 2 > /tmp/quickfix_make.log 2>&1 && \
  e_arrow installing ... && \
  sudo make install > /tmp/quickfix_install.log && rm -fr $tmp_dir
  res=$?
  if [ $res -ne 0 ]
  then
    e_error "quickfix installaton done with error code $res"
    e_arrow Check log files /tmp/quickfix_*
  else
    e_arrow "quickfix installaton done with error code $res"
  fi
fi
# End Quickfix installation

# Google Benchmark library
if [ -f /usr/local/include/benchmark/benchmark.h ]
then
  e_arrow "Benchmark is already installed"
else
  e_header "Installing benchmark library (master branch)"
  create_tmp_and_clone "benchmark" "https://github.com/google/benchmark.git"
  if [ $? -eq 0 ]
  then
    e_arrow building .. && \
    cd benchmark && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=RELEASE && \
    make -j 2 > /tmp/benchmark_make.log 2>&1 && \
    e_arrow installing ... && \
    sudo make install > /tmp/benchmark_install.log && rm -fr $tmp_dir
    res=$?
    if [ $res -ne 0 ]
    then
      e_error "benchmark installaton done with error code $res"
      e_arrow Check log files /tmp/benchmark_*
    else
      e_arrow "benchmark installaton done with error code $res"
    fi
  fi
fi
# End Google Benchmark installation

# JSON for Modern C++ (nlohmann)
if [ -f /usr/local/include/nlohmann/json.hpp ]
then
  e_arrow "JSON for Modern C++ is already installed"
else
  create_tmp_and_download "JSON(nlohmann)" "https://github.com/nlohmann/json/archive/v3.1.2.tar.gz"
  if [ $? -eq 0 ]
  then
    e_arrow building .. && \
    cd json-3.1.2 && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=RELEASE && \
    make -j 2 > /tmp/json_make.log 2>&1 && \
    e_arrow installing ... && \
    sudo make install > /tmp/json_install.log && rm -fr $tmp_dir
    res=$?
    if [ $res -ne 0 ]
    then
      e_error "JSON(nlohmann) installaton done with error code $res"
      e_arrow Check log files /tmp/json_*
    else
      e_arrow "JSON(nlohman) installaton done with error code $res"
    fi
  fi
fi
# End JSON for Modern C++ (nlohmann)

# Emscripten SDK
create_tmp_and_clone "Emscripten SDK" "https://github.com/juj/emsdk.git"
if [ $? -eq 0 ]
then
  e_arrow installing .. && \
  cd emsdk && \
  ./emsdk install latest && \
  e_arrow activating .. && \
  ./emsdk activate latest
  res=$?
  if [ $res -ne 0 ]
  then
    e_error "Emscripten SDK installaton done with error code $res"
  else
    cd ..
    mv emsdk $SOFT_DIR/ 
    e_success "Emscripten SDK installaton done with error code $res"
  fi
else
  e_warn "Error when cloning git repository $?d "
fi
# End Emscripten SDK
