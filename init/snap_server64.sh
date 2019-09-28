snap_packages=()

snap_packages+=( go )
snap_classic_packages+=( )

for package in "${snap_packages[@]}"; do
    e_arrow "Installing snap package: $package"
    $DO sudo snap install "$package"
done

for package in "${snap_classic_packages[@]}"; do
    e_arrow "Installing snap package: $package"
    $DO sudo snap install --classic "$package"
done
