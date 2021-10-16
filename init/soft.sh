echo

function find_program()
{
  program=$1
  path=`which $program 2> /dev/null`

  if [ -z $path ]; then return 1; fi

  return 0
}

function is_number()
{
  number="$1"
  re='^[0-9]+$'

  [[ $number =~ $re ]] && return 0

  return 1
}

function get_rclone_suffix()
{
  rclone_suffix=''

  archi=$(uname -m)
  case "$archi" in
    "armv6l")  rclone_suffix=arm;;
    "i686")   rclone_suffix=386;;
    "x86_64") rclone_suffix=amd64;;
    *);;
  esac
}

function install_rclone()
{
  if [ ! -z "$rclone_suffix" ]
  then
    rclone_dir=rclone-${RCLONE_VERSION}-linux-${rclone_suffix}
    rclone_filename=rclone-${RCLONE_VERSION}-linux-${rclone_suffix}.zip
    rclone_url=https://downloads.rclone.org/${RCLONE_VERSION}/${rclone_filename}
    tmp_dir=$(mktemp -d)
    cd $tmp_dir && wget "$rclone_url" && unzip $rclone_filename && \
      mv -vi $rclone_dir/rclone $SOFT_DIR/bin
    rm -fr "${tmp_dir}"
  else
    e_warn "Unknwon architecture [$rclone_suffix]=> rclone will not be installed"
  fi
}


### RClone installation
RCLONE_VERSION=v1.46

get_rclone_suffix

if ( find_program rclone )
then
  rclone_version=$(rclone --version | grep rclone | sed 's/^rclone v//' | sed 's/\.//')
  rclone_to_install_version=`echo $RCLONE_VERSION | sed 's/[v\.]//g'`

  if [ $rclone_version -lt $rclone_to_install_version ]
  then
    e_warn A new version of rclone is available
    install_rclone
  else
    e_arrow Rclone is already installed
  fi
else
  install_rclone
fi

##
# Install youtube-dl
##

function install_youtube-dl() {
  sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
  sudo chmod a+rx /usr/local/bin/youtube-dl

}
