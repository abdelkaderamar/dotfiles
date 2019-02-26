snap_packages=()

snap_packages+=(hugo)

for package in "${snap_packages[@]}"; do
    e_arrow "Installing snap package: $package"
    $DO sudo snap install "$package"
done

