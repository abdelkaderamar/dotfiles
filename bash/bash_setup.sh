# Bash setup file

function do_link()
{
    file="$1"
    link="$2"
    $DO ln -sf "$1" "$2"
}

e_header "Creating links to bashrc and bash_aliases"

do_link "$DOTFILES_DIR/bash/bashrc" "$HOME/.bashrc"
do_link "$DOTFILES_DIR/bash/bash_aliases" "$HOME/.bash_aliases"

e_header "Creating link to function files"
do_link "$DOTFILES_DIR"/bash/functions "$HOME/.bash_functions"
do_link "$DOTFILES_DIR"/bash/bash_logging "$HOME/.bash_logging"
do_link "$DOTFILES_DIR"/bash/zik_functions.sh "$HOME/.zik_functions"

e_header "Creating links to scripts"
mkdir -p "$HOME"/share/bash
for s in "$DOTFILES_DIR"/scripts/*.sh
do
  name=$(basename "$s")
  do_link "$s" "$HOME"/share/bash/"$name"
done

e_header "Creating links to cmake files"
mkdir -p "$HOME"/share/cmake
for f in "$DOTFILES_DIR"/share/*.cmake
do
  name=$(basename "$f")
  do_link "$f" "$HOME"/share/cmake/"$name"
done
