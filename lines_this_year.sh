#!/bin/bash

echo "Enter directory to recursively search"
read directory
cd "$library"
date=$(date +%Y-%m-%d)
curyr=$(echo "$date" | sed "s/\-.*//g")
curmo=$(echo "$date" | sed "s/....\-//g;s/\-..//g")

check_if_valid() {
    regexp=".*(venv|gitignore).*"
    if [[ $1 =~ regexp ]];then
        return 0
    else
        return 1
    fi
}

count_lines() {
    return $(sed "/^$/ d" "$1" | wc -l)
}

check_date() {
    filedate=$(stat -c '%y' $1 | sed "s/\s.*$//")
    fileyr=$(echo "$filedate" | sed "s/\-.*//g")
    filemo=$(echo "$filedate" | sed "s/....\-//g;s/\-..//g")
    fileage=$(( 12 * ($curyr - $fileyr) + ($curmo - $filemo) ))
    if (( fileage <= 12 ));then
        return
    fi
    false
}


### To avoid problems with wildcards, globbing, or spaces in file names
IFS=$'\n'; set -f

for f in $(find ./ -iregex ".*\.\(sh\|sql\|py\|js\)" -not -path "*gitignore*" -not -path "*venv*"); do
    check_date $f
    status=$?
    if (exit $status); then
        count_lines $f
        printf "%-10s | "$f"\n" "$?" >> ~/linecount.txt
    fi
done

### To avoid problems with wildcards, globbing, or spaces in file names
unset IFS; set +f
