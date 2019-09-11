#! /bin/bash -u

source $HOME/.bash_logging

check_backup_drive()
{
    success=false
    # Check drive is set and is a directory
    [[ -z ${DRIVE+x} ]] && return 1
    [[ ! -d "${DRIVE}" ]] && return 1
    success=true
}

create_directories()
{
    RAW_DIR="${DRIVE}/Photos/Photos - Raw"
    PROCESSING_DIR="${DRIVE}/Photos/Photos To Process"

    mkdir -pv "$RAW_DIR"
    mkdir -pv "$PROCESSING_DIR"
    
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

    target_dir_processing="$PROCESSING_DIR"/"$1"
    if [ -d "$target_dir_processing" ]
    then
	e_error "Directory $dir already exists in $target_dir_processing"
	return 1
    fi

    success=true
}

check_backup_drive

if ( ! $success )
then
    echo_and_exit 1 "Check DRIVE variable is set to the directory where photos are stored"
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
	e_info processing "$dir"
	e_info "Target directory (raw) = $target_dir_raw"
	e_info "Target directory (processing) = $target_dir_processing"

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
		
	e_header "Starting rsync with processing directory ...."
	rsync -aXS --relative --remove-source-files "$dir" "$PROCESSING_DIR"
	e_success "Rsync done"

	diff -r "$target_dir_raw" "$target_dir_processing"
	if [ $? -ne 0 ]
	then
	    echo_and_exit 1 "Error when checking [$target_dir_raw] vs [$target_dir_processing]"
	fi
	e_success "Diff done"

	find "$dir" -type d -empty -delete
    else
	exit 1
    fi
done

e_header "... done"
