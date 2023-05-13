# Ubuntu distro release name, eg. "xenial"
release_name=$(lsb_release -c | awk '{print $2}')

source apt/packages/apt_common.sh
source apt/packages/apt_dev.sh
source apt/packages/apt_net.sh
source apt/packages/apt_office.sh
source apt/packages/apt_sys.sh
source apt/packages/apt_tools.sh


e_header "Release name: $release_name"

if ( $pi3_profile )
then
    e_header "Raspberry 3 profile"
    source apt/apt_pi3.sh
fi

if ( $pi4_profile )
then
    e_header "Raspberry 4 profile"
    source apt/apt_pi4.sh
fi

if ( $laptop_profile )
then
    e_header "Laptop profile"
    prepare_vs_code
    prepare_chrome
    prepare_edge
    source apt/apt_laptop.sh
fi

if ( $desktop_profile )
then
    e_header "Desktop profile"
    prepare_vs_code
    prepare_chrome
    prepare_edge
    source apt/apt_desktop.sh
fi

if ( $homelab_profile )
then
    e_header "Homelab profile"
    source init/apt_homelab.sh
fi

if ( $homelab2_profile )
then
    e_header "Secondary homelab profile"
    source apt/apt_homelab2.sh
fi

if ( $ext_homelab_profile )
then
    e_header "External homelab profile"
    source apt/apt_ext_homelab.sh
    source init/snap_dev.sh
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
    if [ -z "$DO" ]
    then
        $DO sudo apt-get -qq install "$package" > /dev/null
    else
        $DO sudo apt-get -qq install "$package"     
    fi
done
