function add_package_source()
{
    apt_keys+=("$1")
    apt_sources["$2"]="$3"
    apt_packages+=("$4")
}


add_latex()
{
    apt_packages+=(texlive-publishers texlive-fonts-extra texlive-latex-base)
    apt_packages+=(texlive-latex-extra texlive-extra-utils)
    apt_packages+=(texlive-xetex texlive-lang-french)
}


add_virtualbox() 
{
    apt_packages+=(virtualbox-qt)
}


add_emacs()
{
    apt_packages+=(emacs)
}

add_docker()
{
    apt_packages+=(docker.io)
    apt_packages+=(docker-compose)
}

add_php()
{
    apt_package+=( php )
    apt_package+=( libapache2-mod-php  )
    apt_package+=( php-mysql )
    apt_package+=( php-curl php-gd php-intl php-json php-mbstring php-xml php-zip )
}

install_node()
{
    command -v node
    res1=$?
    
    command -v npm
    res2=$?

    if [ $res1 -eq 0 ] && [ $res2 -eq 0 ]
    then
	e_arrow "Node already installed"
	return
    fi

    e_arrow "Installing node"

    curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
    sudo apt-get install -y nodejs

}
