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
    apt_packages+=( php )
    apt_packages+=( libapache2-mod-php  )
    apt_packages+=( php-mysql )
    apt_packages+=( php-curl php-gd php-intl php-json php-mbstring php-xml php-zip )
}
