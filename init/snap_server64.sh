snap_packages=()

snap_packages+=( )
snap_classic_packages+=( go )

for package in "${snap_packages[@]}"; do
    e_arrow "Installing snap package: $package"
    $DO sudo snap install "$package"
done

for package in "${snap_classic_packages[@]}"; do
    e_arrow "Installing snap package: $package"
    $DO sudo snap install --classic "$package"
done
