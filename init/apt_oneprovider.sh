add_docker
apt_packages+=( composer )

apt_packages+=( apache2 )
apt_packages+=( mariadb-server )
add_php

apt_packages+=( imagemagick )

apt_packages+=( mongodb )

install_node

apt_packages+=( make )

apt_packages+=( syncthing )

# For magento
apt_packages+=( php-soap )
