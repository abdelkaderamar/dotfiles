archi=$(uname -m)
# RClone installation
RCLONE_VERSION=v1.40
rclone_suffix=''
case "$archi" in
  "armv6l")  rclone_suffix=arm;;
  "i686")   rclone_suffix=386;;
  "x86_64") rclone_suffix=amd64;;
  *);;
esac

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
