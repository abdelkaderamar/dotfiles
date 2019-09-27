apt_packages+=( rfkill )
apt_packages+=( wireless-tools )
apt_packages+=( wpasupplicant )
apt_packages+=( ifupdown )

add_docker
apt_packages+=( apache2 )
apt_packages+=( mariadb-server )
add_php

apt_packages+=( imagemagick )
