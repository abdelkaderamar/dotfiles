#! /bin/bash -u

source $HOME/.bash_logging

check_backup_drive()
{
    success=false
    
    # Check DRIVE is set and is a directory
    [[ -z ${DRIVE+x} ]] && return 1
    [[ ! -d "${DRIVE}" ]] && return 1

    # Check DRIVE_BACKUP is set and is a directory
    [[ -z ${DRIVE_BACKUP+x} ]] && return 1
    [[ ! -d "${DRIVE_BACKUP}" ]] && return 1

    success=true
}

check_directories()
{
    success=false
    
    DRIVE_BASE_DIR="${DRIVE}/Photos"
    RAW_DIR="${DRIVE_BASE_DIR}/Photos - Raw"
    PROCESSING_DIR1="${DRIVE_BASE_DIR}/Photos To Process1"
    PROCESSING_DIR2="${DRIVE_BASE_DIR}/Photos To Process2"

    BACKUP_DRIVE_BASE_DIR="${DRIVE_BACKUP}/Photos_Backup"
    BACKUP_RAW_DIR="${BACKUP_DRIVE_BASE_DIR}/Photos - Raw"

    for d in "$RAW_DIR" "$PROCESSING_DIR1" "$PROCESSING_DIR2" "$BACKUP_RAW_DIR"
    do
	if [ ! -d "$d" ]
	then
	    e_error "$d not found"
	    return 1
	fi
    done

    success=true
    
}

check_target_dir_dont_exist()
{
    target_dir_path=$1
    
    if [ -d "$target_dir_path" ]
    then
	e_error "Directory $target_dir_path already exists"
	return 1
    fi
    
}

check_all_target_dirs_dont_exist()
{
    success=false

    if ( ! check_target_dir_dont_exist "$target_dir_raw" )
    then
	return 1
    fi

    if ( ! check_target_dir_dont_exist "$target_dir_processing1" )
    then
	return 1
    fi

    if ( ! check_target_dir_dont_exist "$target_dir_processing2" )
    then
	return 1
    fi

    if ( ! check_target_dir_dont_exist "$backup_target_dir_raw" )
    then
	return 1
    fi
    
    success=true
}

################################################################
# Rsync two directories
################################################################
do_rsync()
{
    source_dir="$1"
    dest_dir="$2"
    target_dir="$dest_dir"/"$source_dir"
    
    e_header "Starting rsync [$source_dir] => [$dest_dir] ...."
    rsync -aXS  --relative "$source_dir" "$dest_dir"

    if [ $? -ne 0 ]
    then
	echo_and_exit 1 "rsync failed with error code $?"
	return 1
    fi
    
    e_success "Rsync done"

    e_arrow "Checking differences between $source_dir $target_dir ..."  
    diff -r "$source_dir" "$target_dir"
    if [ $? -ne 0 ]
    then
	echo_and_exit 1 "Error when checking [$source_dir] vs [$target_dir]"
    fi
    e_success "Diff done"
    
}

################################################################


check_backup_drive

if ( ! $success )
then
    echo_and_exit 1 "Check DRIVE and DRIVE_BACKUP variables is set to the directories where photos are stored"
fi

check_directories

if ( ! $success )
then
    echo_and_exit 1 "Check DRIVE and DRIVE_BACKUP contains all the required directories"
fi


dirs=("$@")

e_header "Start processing ${dir[@]} ..."

for dir in "${dirs[@]}"
do
    if [ ! -d "$dir" ]
    then
	e_warn "[$dir] doesn't exist";
	continue;
    fi
    
    target_dir_raw="${RAW_DIR}/${dir}"
    target_dir_processing1="${PROCESSING_DIR1}/${dir}"
    target_dir_processing2="${PROCESSING_DIR2}/${dir}"

    backup_target_dir_raw="${BACKUP_RAW_DIR}/${dir}"

    check_all_target_dirs_dont_exist 


    
    if ( $success )
    then
	
	e_arrow processing "$dir"
	e_arrow "Target directory (raw) = $target_dir_raw"
	e_arrow "Target directory (processing1) = $target_dir_processing1"
	e_arrow "Target directory (processing2) = $target_dir_processing2"

	echo 
	e_arrow "Target backup directory (raw) = $backup_target_dir_raw"

	do_rsync "$dir" "$RAW_DIR"
		
	do_rsync "$dir" "$PROCESSING_DIR1"

	do_rsync "$dir" "$PROCESSING_DIR2"
	
	e_header "Starting moving $dir with rsync to $backup_target_dir_raw"
	
	rsync -aXS --relative --remove-source-files "$dir" "$BACKUP_RAW_DIR"
	
	if [ $? -ne 0 ]
	then
	    echo_and_exit 1 "rsync failed with error code $?"
	    return 1
	fi
	
	e_success "Rsync done"

	e_arrow "Checking if any differences between target_dir_raw and $backup_target_dir_raw"
	
	diff -r "$target_dir_raw" "$backup_target_dir_raw"
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
