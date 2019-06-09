# CIFS filesystem (freebox disk mount), ssh, ocr, cpupower, ...
apt_packages+=(net-tools cuneiform linux-tools-common)
apt_packages+=(linux-tools-4.15.0-20-generic)


# some tools
apt_packages+=(tree ttyrec calibre smplayer mplayer backintime-gnome pstack)
apt_packages+=(lftp gimp)
apt_packages+=(npm)
apt_packages+=(docker.io)
apt_packages+=(exfat-fuse exfat-utils)

# maybe
apt_packages+=(apt-file pandoc soundconverter mp3info vlc mkvtoolnix gparted keepass2 libimage-exiftool-perl)

add_package_source "https://dl-ssl.google.com/linux/linux_signing_key.pub" \
                   "google-chrome" \
                   "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" \
                   "google-chrome-stable"

# Oracle Java PPA
$DO sudo add-apt-repository -y ppa:webupd8team/java
apt_packages+=(oracle-java8-installer)
