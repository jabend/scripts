#!/bin/bash

#------------------------------------
# Move files of a given match from one parent directory to another target directory while perserving the relative path.
#------------------------------------
#
# tested on OSX
# mv_path.sh source_dir target_dir 'pattern'
#
#   mv_path.sh ~/all_files ~/movie_files
#
#------------------------------------

abspath() {
    local thePath
    if [[ ! "$1" =~ ^/ ]]
    then
        thePath="$PWD/$1"
    else
        thePath="$1"
    fi
    echo "$thePath"|(
        IFS=/
        read -a parr
        declare -a outp
        for i in "${parr[@]}"
        do
            case "$i" in
            ''|.)
                continue
                ;;
            ..)
                len=${#outp[@]}
                if ((len == 0))
                then
                    continue
                else
                    unset outp[$((len-1))]
                fi
                ;;
            *)
                len=${#outp[@]}
                outp[$len]="$i"
                ;;
            esac
        done
        echo /"${outp[*]}"
    )
}

#expand relative paths
source=$(abspath "$1")
if [[ ! -d "$source" ]]
then
	echo "Source not found...exiting."
	exit 1
fi
#test -d "$source" && sleep 0 || (echo "Source Not Found"; exit 1)
dest=$(abspath "$2")

#create target if it doesn't exist
test -d "$dest" &&  sleep 0 || mkdir "$dest"
cd "$source"
IFS=$'\n'
files=0
for f in $(find .  -iname "$3")
do
  let files++
  filename=$(basename -- "$f")
  extension="${filename##*.}"
  source_filename="${filename%.*}"
  source_dir=$(cd $(dirname $f); pwd)

  target_dir=$(abspath "$dest/$(dirname $f)")
  target_filename="$source_filename"

  if [[ -e "$target_dir/$source_filename.$extension" ]] ; then
    i=1
    while [[ -e "$target_dir/${source_filename}_$i.$extension" ]] ; do
        let i++
    done
    target_filename="${source_filename}_$i"
  fi
  #echo "$f \n    dir:[$source_dir] \n    filename:[$filename]\n   extension:[$extension] \n    targ:[$target_dir] \n    targ_file:[$target_filename]"
  echo "move '$source_dir/$source_filename.$extension' '$target_dir/$target_filename.$extension'"

  #Uncomment next 2 lines to make the moves...otherwise, this script just shows what it would move.
  #test -d "${dest}/$(dirname ${f})" &&  sleep 0 || mkdir "$dest/$(dirname $f)"
  #mv -n $source_dir/$source_filename.$extension $target_dir/$target_filename.$extension

done

echo "Processed Files: $files"

# Pruning empty directories...just a thought, but not implemented fully
#[ ! -z "$source_dir" ] && echo "find $source_dir -type d -exec rmdir {} + 2>/dev/null"
