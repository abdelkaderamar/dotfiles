prepare_chrome() {
  e_header "Adding Google Chrome apt source"
  $DO wget -O- -q https://dl-ssl.google.com/linux/linux_signing_key.pub | $DO sudo tee /etc/apt/trusted.gpg.d/google.pub > /dev/null
  $DO sudo sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
  apt_chrome=(google-chrome-stable)
}

prepare_edge() {
  e_header "Adding Microsoft Edge apt source"
  $DO curl -s https://packages.microsoft.com/keys/microsoft.asc | $DO gpg --dearmor > /tmp/microsoft.gpg
  $DO sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
  $DO sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
  $DO sudo rm /tmp/microsoft.gpg
  apt_edge=(microsoft-edge-stable)
}

apt_apache=( \
  apache2 \
)
