apt_packages+=( rfkill )
apt_packages+=( wireless-tools )
apt_packages+=( wpasupplicant )
apt_packages+=( ifupdown )

add_docker

apt_packages+=( apache2 )
apt_packages+=( mariadb-server )
add_php

apt_packages+=( imagemagick )

apt_packages+=( mongodb )

install_node

# For piwigo
apt_packages+=( libimage-exiftool-perl )
apt_packages+=( ffmpeg )
apt_packages+=( libjpeg-progs )
apt_packages+=( poppler-utils )

############

apt_packages+=( make )
apt_packages+=( composer )

# Paperless
apt_packages+=( python-pip python3-pip virtualenv gnupg2 tesseract-ocr unpaper libpoppler-cpp-dev optipng )
apt_packages+=( ghostscript libmagic1 )

apt_packages+=( lxc )
apt_packages+=( syncthing )

apt_packages+=( nfs-kernel-server )

# Searx
#apt_packages+=( libxslt-dev python-virtualenv python-babel zlib1g-dev )
#apt_packages+=( libffi-dev libssl-dev )
#apt_packages+=( uwsgi uwsgi-plugin-python libapache2-mod-uwsgi )
# needed by searx but already installed 
#apt_packages+=( git build-essential python-dev )

# Some network/wifi tools
apt_packages+=( ifmetric )
apt_packages+=( iperf iftop vnstat cbm nload nethogs speedtest-cli )

apt_packages+=(html-xml-utils jq)

