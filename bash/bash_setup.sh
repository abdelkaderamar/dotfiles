# Bash setup file

function do_link()
{
    file="$1"
    link="$2"
    $DO ln -sf "$1" "$2"
}

e_header "Creating link to bashrc and bash_aliases"

do_link "$DOTFILES_DIR/bash/bashrc" "$HOME/.bashrc"
do_link "$DOTFILES_DIR/bash/bash_aliases" "$HOME/.bash_aliases"
