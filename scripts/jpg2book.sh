#! /bin/bash -ue

source "$HOME/.bash_functions"

usage() {
    echo "Syntax error"
    echo "Usage "
    echo "  $0 <dir>"
    echo "Convert a directory containing jpg images to a single pdf"
    echo "The images filenames are in the form of 1.jpg, 10.jpg or 112.jpg"
    echo "If the images filenames are not in this format, the order of the "
    echo "pages is not guaranteed"
    echo "The pages order is based on alphabetical order"
}

if [ $# -ne 1 ]
then
    usage
    exit 1
fi

dir="$1"

cd "$dir"


regex_mv.sh '^\(.\).jpg' '0\1.jpg' -r
regex_mv.sh '^\(..\).jpg' '0\1.jpg' -r

echo "Converting jpg to pdf"
for j in *.jpg
do
    p=${j%.jpg}.pdf;
    convert "$j"  -resize 1240x1753 -extent 1240x1753 -gravity center -units PixelsPerInch -density 150x150  "$p"
done

merge_pdf *.pdf "../$dir.pdf"
