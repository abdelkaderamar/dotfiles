# Bash scripts
These are some script I am using for personal purposes.

## execute_then_sms.sh

This script executes a command then sends an SMS indicating the execution
status. It depends on [sms.sh](#sms) script described below.

**Syntax**
```bash
  execute_then_sms.sh <cmd> [{arguments}]
```

## fbox_mount.sh
This script can be used to mount a freebox drive.

**Syntax**
```
Usage:  fbox_mount.sh [-h|-u]

  -h : print help message
  -u : umount Freebox drive (if mounted)
```
Without argumnt, the script tries to mount the drive. If already mounted,
nothing is done

## rclone_mv.sh
The script is used to upload then remove files to a clound provider using *[rclone](http://www.rclone.org)*.

**Syntax**
```
Usage
    rclone_mv.sh ./rclone_mv.sh service base_dir {dirs|files}
```

## regex_mv.sh

The script applies two regular expressions to the files in the current
directory. If the `-r` option is set, the files are renamed.

**Syntax**
```
Usage regex_mv.sh <regexp1> <regexp2> [-r]

Where
  regexp1 is the regular expression to replace
  regexp2 is the replace regular expression
  -r is used to rename file. Otherwise only a preview if displayed
```

## sms

This script is used to text a message using *free mobile* service. The
variables FREE_USER and FREE_PASS must be set.

**Syntax**
```
Usage sms.sh <text>
```

## smv.sh

**Syntax**

```
Usage: smv.sh <HOST> [files]
```

## unrar_all.sh

This script can be used to extract all *rar* files in the current
directory. If the extraction succeed, the *rar* file is removed, otherwise the file is moved to `failed` directory (see option `-f`).

**Syntax**
```
-f     : defines a custom fail directory
-s     : defines a sleep time between two extractions
-del   : defines patterns to files to delete after earch extraction
-add   : add a suffix a extracted files
-nolog : no log are generated
```

## unzip_all.sh

This script can be used to extract all *zip* files in the current
directory. If the extraction succeed, the *zip* file is removed, otherwise the file is moved to `failed` directory (see option `-f`).

**Syntax**
```
-f     : defines a custom fail directory
-s     : defines a sleep time between two extractions
-del   : defines patterns to files to delete after earch extraction
-add   : add a suffix a extracted files
-nolog : no log are generated
```
