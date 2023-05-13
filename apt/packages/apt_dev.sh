apt_cpp=( \
   gcc \
   clang \
   # to build gcc from sources
   libgmp-dev libmpc-dev libmpfr-dev gcc-multilib g++-multilib libc6-dev-i386 \
   # to run gcc tests
   autogen \
   # cmake
   cmake cmake-curses-gui \
)

apt_python=( \
  python3-virtualenv \
)

prepare_vs_code() {
  e_header "Adding VS Code apt source"
  $DO curl -s https://packages.microsoft.com/keys/microsoft.asc | $DO gpg --dearmor > /tmp/microsoft.gpg 
  $DO sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
  $DO sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  apt_vs_code=(apt-transport-https code)
}
