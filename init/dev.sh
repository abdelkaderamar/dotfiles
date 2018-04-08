archi=$(uname -m)

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
  if [ -d $SOFT_DIR/go-$GO_VERSION ]
  e_header "Installing Go language go-$GO_VERSION"
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
