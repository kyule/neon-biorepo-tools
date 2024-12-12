#!/bin/bash
# Watches a folder structure for new files and moves the files to another location to be ingested by the Symbiota image processing system
# This script is being used to watch for files arriving via the Globus interface

# This script has been customized for the the NEON Biorepository.  This original script can be found at
# https://github.com/BioKIC/SymbiotaTools/blob/main/Cron%20jobs/symbiota_image_watch.bash


# Variables
SOURCE_ROOT_PATH='/mnt/storage/globus/NEON'
ALLOWED_EXTENSIONS=('.jpg' '.jpeg' '.tiff' '.tif' '.png')
LOG_PATH='/var/log'
LOG_NAME="NEON_image_watch_$(date +%Y-%m-%d).log"
DESTINATION_ROOT_PATH='/mnt/storage/image_processing/cron/NEON'
EXIT_STATUS=0
LAST_WATCH_FILE='.image_watch.date'
LAST_WATCH_TIMESTAMP=''
START_DATE=$(date)
TEMPFILE=".$(date +%Y_%d_%m_%H_%M_%S).temp"
MODE=''
MOVED_COUNT=0
declare -A COLL_COUNTS

# handle stdout and stderr
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"$LOG_PATH/$LOG_NAME" 2>&1
# Everything below will go to the file 'NEON_image_watch_yyyy-mm-dd.log':

echo "started at $START_DATE"

#functions
move () {
    local mystatus=0
    if  [ -z "$3"]
    then
        if mv "$1" "$2"
        then
            mystatus=1
            echo "Moved $1 -> $2"
        fi
    else
        if mv -f "$1" "$2"
        then
            mystatus=1
            echo "Overwrote existing file at destination. Move $1 -> $2"
        fi
    fi

    if (( $mystatus > 0 ))
    then
        MOVED_COUNT=$((MOVED_COUNT+1))
        return 0
    else
        return 1
    fi
}

date_validate () {
    local testdate
    testdate=$( date -d "$1" )
    if [ ! -z "$1" ] && [ "$testdate" = "$1" ]
    then
      return 0
    else
      return 1
    fi
}

count_coll () {
    (( COLL_COUNTS[$1]++ ))
    return 0
}

# Sanity check

if [ ! -d "$SOURCE_ROOT_PATH" ]
then
    echo "Source directory $SOURCE_ROOT_PATH DOES NOT exists." >&2
    exit 2
fi


# set local context to source path
cd "$SOURCE_ROOT_PATH"

#check for undeleted temp files
if ls -l .*.temp &>/dev/null
then
    echo "previous temp file detected. Aborting"
    EXIT_STATUS=2
fi

if [ ! -f "$SOURCE_ROOT_PATH/$LAST_WATCH_FILE" ]
then
    #no record of previous run, mv all files found.
    MODE='ALL'
else
    LAST_WATCH_TIMESTAMP=$( head -n 1 "$LAST_WATCH_FILE" )
    if date_validate "$LAST_WATCH_TIMESTAMP"
    then
      MODE='NEW'
    else
      echo "Failed to load timestamp of last run from $SOURCE_ROOT_PATH/$LAST_WATCH_FILE"
      MODE='ALL'
    fi
fi

if [ ! -d "$DESTINATION_ROOT_PATH" ]
then
    echo "Destination directory $DESTINATION_ROOT_PATH DOES NOT exists." >&2
    EXIT_STATUS=2
fi

if (( $EXIT_STATUS > 0 ))
then
    exit $EXIT_STATUS
fi

#store timestamp for future run comparison
echo "$START_DATE" > "$LAST_WATCH_FILE"

FIND_EXTENSTIONS=''
for ((cnt=0; cnt < ${#ALLOWED_EXTENSIONS[@]}; cnt++)); do
  FIND_EXTENSIONS+=" -iname \*${ALLOWED_EXTENSIONS[$cnt]} "
  nextcnt=$(($cnt + 1))
  if [ "$nextcnt" -lt "${#ALLOWED_EXTENSIONS[@]}" ];
    then
      FIND_EXTENSIONS+='-o'
  fi
done

CMD="find . -type f \(${FIND_EXTENSIONS}\)"

case "$MODE" in
    ALL)
        echo "Searching for files in $SOURCE_ROOT_PATH folders"
        ;;
    NEW)
        echo "Searching for files newer than $LAST_WATCH_TIMESTAMP in $SOURCE_ROOT_PATH folders"
        CMD+=" -newermt \"$LAST_WATCH_TIMESTAMP\""
        ;;
esac

#generate list of files to move out of watch folders to destination folder
CMD="$CMD  > $TEMPFILE"
echo "$CMD"
eval $CMD

while read LINE; do
    #INSTITUTION_DIR=$(echo "$LINE" | sed 's|[.]/\([^/]*\).*|\1|')
    #COLLECTION_DIR=$(echo "$LINE" | sed 's|[.]/[^/]*/\([^/]*\).*|\1|')
    #COLLECTION_DIR=$(echo "$LINE" | sed 's|[.]/\([^/]*\).*|\1|')
    LINE=$(echo "$LINE" | sed 's|^./\(.*\)$|\1|')
    FILENAME=$(echo "$LINE" | sed 's|.*/\([^/]*\)$|\1|')
    
    if [[ "$LINE" == General/* ]]; then
    SUBDIR_PATH=$(dirname "$LINE") # Extract subdirectory structure
    DEST_PATH="$DESTINATION_ROOT_PATH/$SUBDIR_PATH"
else
    COLLECTION_DIR=$(echo "$LINE" | sed 's|/.*$||') # Top-level collection directory
    DEST_PATH="$DESTINATION_ROOT_PATH/$COLLECTION_DIR"
fi

    #if [ ! -d "$DESTINATION_ROOT_PATH/$INSTITUTION_DIR/$COLLECTION_DIR" ]
    if [ ! -d "$DESTINATION_ROOT_PATH/$COLLECTION_DIR" ]
    then
       #mkdir -p "$DESTINATION_ROOT_PATH/$INSTITUTION_DIR/$COLLECTION_DIR"
       mkdir -p "$DESTINATION_ROOT_PATH/$COLLECTION_DIR"
    fi

    #if [ ! -f "$DESTINATION_ROOT_PATH/$INSTITUTION_DIR/$COLLECTION_DIR/$FILENAME" ]
    if [ ! -f "$DESTINATION_ROOT_PATH/$COLLECTION_DIR/$FILENAME" ]
    then
        #if move "$SOURCE_ROOT_PATH/$LINE" "$DESTINATION_ROOT_PATH/$INSTITUTION_DIR/$COLLECTION_DIR"
        if move "$SOURCE_ROOT_PATH/$LINE" "$DESTINATION_ROOT_PATH/$COLLECTION_DIR"
        then
            count_coll "$COLLECTION_DIR"
        fi
    else
        #if [ $(stat -c %s "$SOURCE_ROOT_PATH/$LINE") -ne 0 ] && [ "$SOURCE_ROOT_PATH/$LINE" -nt $DESTINATION_ROOT_PATH/$INSTITUTION_DIR/$COLLECTION_DIR/$FILENAME ]
        if [ $(stat -c %s "$SOURCE_ROOT_PATH/$LINE") -ne 0 ] && [ "$SOURCE_ROOT_PATH/$LINE" -nt $DESTINATION_ROOT_PATH/$COLLECTION_DIR/$FILENAME ]
        then
            #if move "$SOURCE_ROOT_PATH/$LINE" "$DESTINATION_ROOT_PATH/$INSTITUTION_DIR/$COLLECTION_DIR" "OVERWRITE"
            if move "$SOURCE_ROOT_PATH/$LINE" "$DESTINATION_ROOT_PATH/$COLLECTION_DIR" "OVERWRITE"
            then
                count_coll "$COLLECTION_DIR"
            fi
        else
            #echo "Did not move $SOURCE_ROOT_PATH/$LINE - Source files is either empty or modified prior to $DESTINATION_ROOT_PATH/$INSTITUTION_DIR/$COLLECTION_DIR/$FILENAME"
            echo "Did not move $SOURCE_ROOT_PATH/$LINE - Source files is either empty or modified prior to $DESTINATION_ROOT_PATH/$COLLECTION_DIR/$FILENAME"
        fi
    fi
done <"$TEMPFILE"

echo "Update file permissions"
chmod -R 777 "$DESTINATION_ROOT_PATH"

mysummary=""

mysumary=$'Total files moved by collection folder\n'
mysumary+=$'\n'
for key in "${!COLL_COUNTS[@]}"
do
    mysumary+="$key => ${COLL_COUNTS[$key]}"
    mysumary+=$'\n'
done

mysumary+=$'\n'
mysumary+="Total files remaining in source folder"
mysumary+=$'\n'
TEMP=$( find ${SOURCE_ROOT_PATH}/* -maxdepth 0 -type d | while read -r dir; do printf "%s:\t" "$dir"; find "$dir" -type f | wc -l; done | sed -E "/^.*0$/d" )
mysumary+="$TEMP"
mysumary+=$'\n'

mysumary+=$'\n'
mysumary+="Total files in destination folder"
mysumary+=$'\n'
TEMP=$( find ${DESTINATION_ROOT_PATH}/* -maxdepth 0 -type d | while read -r dir; do printf "%s:\t" "$dir"; find "$dir" -type f | wc -l; done | sed -E "/^.*0$/d" )
mysumary+="$TEMP"
mysumary+=$'\n'

echo "$mysummary"

mysumary+=$'\n'
mysumary+="Full run log can be found on Biokic5 in $LOG_PATH/$LOG_NAME"
mysumary+=$'\n'


#send email
subject="Summary of NEON Image watch cron job"
from="biokic5@asu.edu"
to="gpost2@asu.edu,kmyule@asu.edu,cearl4@asu.edu"
echo -e "Subject:${subject}\nTo:${to}\n\n${mysumary}\n\n" | /sbin/sendmail -f "${from}" -t

rm -f "$TEMPFILE"
echo "Completed at $(date)"
exit 0
