
apt_packages+=( snap snapd )

add_docker


apt_packages+=( composer )

apt_packages+=( apache2 )
apt_packages+=( mariadb-server )

add_php

apt_packages+=( imagemagick )


install_node

apt_packages+=( ufw fail2ban )

#apt_packages+=( mongodb )

#apt_packages+=( make )

#apt_packages+=( syncthing )

# For magento
#apt_packages+=( php-soap )

##############

#apt_packages+=( postgresql )

# For saleor
#apt_packages+=( build-essential python3-dev python3-pip python3-cffi libcairo2 libpango-1.0-0 libpangocairo-1.0-0 libgdk-pixbuf2.0-0 libffi-dev shared-mime-info )
#apt_packages+=( python3-venv )

##############
# Python 

apt_packages+=( python3-virtualenv python3-pip )

##############
# Apache

apt_packages+=( libapache2-mod-wsgi-py3 )


apt_packages+=( sqlite3 )



