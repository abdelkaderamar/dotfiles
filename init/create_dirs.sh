### Cloud provider directory

e_header "Creating cloud providers directory"

CLOUD_DIR=${HOME}/cloud
mkdir -p "$CLOUD_DIR"/gdrive

### Software directory
e_header "Creating software directory"

SOFT_DIR=${HOME}/software
mkdir -p "$SOFT_DIR"/bin

### Development directory

#if ( $OPT_DEV_SETUP )
#then
#  e_header "Creating development directory"
#
#  DEV_DIR=${HOME}/Dev
#  mkdir -p "${DEV_DIR}"/Android \
#    "${DEV_DIR}"/Bash \
#    "${DEV_DIR}"/C++ \
#    "${DEV_DIR}"/Java \
#    "${DEV_DIR}"/Python \
#    "${DEV_DIR}"/Scala \
#    "${DEV_DIR}"/Javascript \
#    "${DEV_DIR}"/tools
#fi
