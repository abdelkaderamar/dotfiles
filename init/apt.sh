# For ccmake

# CIFS filesystem (freebox disk mount), ssh, ocr, cpupower, ...
apt_packages+=(openssh-server net-tools cifs-utils cuneiform linux-tools-common)
apt_packages+=(linux-tools-4.15.0-20-generic)

# virtualbox
apt_packages+=(virtualbox-qt)

# vim, emacs, latex
apt_packages+=(vim emacs)
apt_packages+=(texlive-publishers texlive-fonts-extra texlive-latex-base texlive-latex-extra texlive-extra-utils)
# some tools
apt_packages+=(tree ttyrec calibre curl unrar smplayer)

# Ubuntu distro release name, eg. "xenial"
release_name=$(lsb_release -c | awk '{print $2}')

e_header "Release name: $release_name"

function add_package_source()
{
    apt_keys+=("$1")
    apt_sources["$2"]="$3"
    apt_packages+=("$4")
}

add_package_source "https://dl-ssl.google.com/linux/linux_signing_key.pub" \
                   "google-chrome" \
                   "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" \
                   "google-chrome-stable"


for key in "${apt_keys[@]}"
do
    $DO wget -q -O - "$key" | sudo apt-key add -
done

for source in "${!apt_sources[@]}"
do
    $DO sudo sh -c "echo '${apt_sources[$source]}' >  /etc/apt/sources.list.d/$source.list"
done

# Oracle Java PPA
sudo add-apt-repository -y ppa:webupd8team/java
apt_packages+=(oracle-java8-installer)

# Updating APT
e_header "Updating APT"
$DO sudo apt-get -qq update

# Install APT packages
e_header "Installing APT packages (${apt_packages[@]})"
for package in "${apt_packages[@]}"; do
    e_arrow "$package"
    $DO sudo apt-get -qq install "$package"
done
