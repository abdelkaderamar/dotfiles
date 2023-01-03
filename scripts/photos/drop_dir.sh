#! /bin/bash -u

source $HOME/.bash_logging

check_backup_drive()
{
    success=false
    # Check drive is set and is a directory
    [[ -z ${PHOTO_DRIVE+x} ]] && return 1
    [[ ! -d "${PHOTO_DRIVE}" ]] && return 1
    success=true
}

create_directories()
{
    RAW_DIR="${PHOTO_DRIVE}/Photos/Photos - Raw"
    PROCESSING_DIR1="${PHOTO_DRIVE}/Photos/Photos To Process1"
    PROCESSING_DIR2="${PHOTO_DRIVE}/Photos/Photos To Process2"

    mkdir -pv "$RAW_DIR"
    mkdir -pv "$PROCESSING_DIR1"
    mkdir -pv "$PROCESSING_DIR2"
    
}

check_target_dir_dont_exist()
{
    success=false
    target_dir_raw="$RAW_DIR"/"$1"

    if [ -d "$target_dir_raw" ]
    then
	e_error "Directory $dir already exists in $target_dir_raw"
	return 1
    fi

    target_dir_processing1="$PROCESSING_DIR1"/"$1"
    if [ -d "$target_dir_processing1" ]
    then
	e_error "Directory $dir already exists in $target_dir_processing1"
	return 1
    fi

    target_dir_processing2="$PROCESSING_DIR2"/"$1"
    if [ -d "$target_dir_processing2" ]
    then
	e_error "Directory $dir already exists in $target_dir_processing2"
	return 1
    fi
    
    success=true
}

check_backup_drive

if ( ! $success )
then
    echo_and_exit 1 "Check PHOTO_DRIVE variable is set to the directory where photos are stored"
fi

create_directories

dirs=("$@")

e_header "Start processing ${dir[@]} ..."

for dir in "${dirs[@]}"
do
    if [ ! -d "$dir" ]
    then
	e_warn "[$dir] doesn't exist";
	continue;
    fi
    base_dir=`basename "$dir"`
    check_target_dir_dont_exist "$dir"

    if ( $success )
    then
	e_arrow processing "$dir"
	e_arrow "Target directory (raw) = $target_dir_raw"
	e_arrow "Target directory (processing1) = $target_dir_processing1"
	e_arrow "Target directory (processing2) = $target_dir_processing2"

	e_header "Starting rsync with raw directory ...."
	rsync -aXS --relative "$dir" "$RAW_DIR" 
	e_success "Rsync done"

	e_header "Checking differences between $dir $target_dir_raw ..."  
	diff -r "$dir" "$target_dir_raw"
	if [ $? -ne 0 ]
	then
	    echo_and_exit 1 "Error when checking [$dir] vs [$target_dir_raw]"
	fi
	e_success "Rsync done"
		
	e_header "Starting rsync with first processing directory ...."
	rsync -aXS --relative "$dir" "$PROCESSING_DIR1"
	e_success "Rsync done"

	diff -r "$target_dir_raw" "$target_dir_processing1"
	if [ $? -ne 0 ]
	then
	    echo_and_exit 1 "Error when checking [$target_dir_raw] vs [$target_dir_processing1]"
	fi
	e_success "Diff done"

	e_header "Starting rsync with second processing directory ...."
	rsync -aXS --relative --remove-source-files "$dir" "$PROCESSING_DIR2"
	e_success "Rsync done"

	diff -r "$target_dir_raw" "$target_dir_processing2"
	if [ $? -ne 0 ]
	then
	    echo_and_exit 1 "Error when checking [$target_dir_raw] vs [$target_dir_processing2]"
	fi
	e_success "Diff done"

	find "$dir" -type d -empty -delete
    else
	exit 1
    fi
done

e_header "... done"
