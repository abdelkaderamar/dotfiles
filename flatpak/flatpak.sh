flatpak_packages=( \
  md.obsidian.Obsidian
)

for package in "${flatpak_packages[@]}"
do
  flatpak install "$package"
done