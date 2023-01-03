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

# JSON for Modern C++ (nlohmann)
build_and_install_json_cpp() {
    local JSON_CPP_VERSION="$1"
    if [ -f /usr/local/include/nlohmann/json.hpp ]
    then
        e_arrow "JSON for Modern C++ is already installed"
    else
        create_tmp_and_download "JSON(nlohmann)" "https://github.com/nlohmann/json/archive/v${JSON_CPP_VERSION}.tar.gz"
        if [ $? -eq 0 ]
        then
            e_arrow building .. && \
                cd json-${JSON_CPP_VERSION} && \
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
}
# End JSON for Modern C++ (nlohmann)
