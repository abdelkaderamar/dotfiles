prepare_chrome() {
  e_header "Adding Google Chrome apt source"
  wget -O- -q https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/trusted.gpg.d/google.pub > /dev/null
  sudo sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
  apt_chrome=(google-chrome-stable)
}

prepare_edge() {
  e_header "Adding Microsoft Edge apt source"
  curl -s https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
  sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
  sudo rm /tmp/microsoft.gpg
  apt_edge=(microsoft-edge-stable)
}

apt_apache=( \
  apache2 \
)