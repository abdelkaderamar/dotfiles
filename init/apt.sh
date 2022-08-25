# Ubuntu distro release name, eg. "xenial"
release_name=$(lsb_release -c | awk '{print $2}')

source init/apt_common.sh
source init/apt_functions.sh


e_header "Release name: $release_name"

if ( $pi3_profile )
then
    e_header "Raspberry 3 profile"
    source init/apt_pi3.sh
fi

if ( $pi4_profile )
then
    e_header "Raspberry 4 profile"
    source init/apt_pi4.sh
fi

if ( $server32_profile )
then
    e_header "Server x86 profile"
    source init/apt_server32.sh
fi

if ( $server64_profile )
then
    e_header "Server 64 profile"
    source init/apt_server64.sh
    source init/snap_server64.sh
fi

if ( $dev_profile )
then
    e_header "Dev profile"
    source init/apt_dev.sh
    source init/snap_dev.sh
fi

if ( $netbook32_profile )
then
    e_header "Netbook x86 profile"
    source init/apt_netbook32.sh
fi

if ( $ext_server_profile )
then
    e_header "External server profile"
    source init/apt_ext_server.sh
fi

for key in "${apt_keys[@]}"
do
    $DO wget -q -O - "$key" | $DO sudo apt-key add -
done

for source in "${!apt_sources[@]}"
do
    $DO sudo sh -c "echo '${apt_sources[$source]}' >  /etc/apt/sources.list.d/$source.list"
done

# Updating APT
e_header "Updating APT"
$DO sudo apt-get -qq update

# Install APT packages
e_header "Installing APT packages (${apt_packages[@]})"
for package in "${apt_packages[@]}"; do
    e_arrow "$package"
    $DO sudo apt-get -qq install "$package"
done
