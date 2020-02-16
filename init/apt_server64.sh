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

