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

source=$1
dest=$2
  test -d ${dest} &&  sleep 0 || mkdir $dest
cd $source
IFS=$'\n'
files=0
for f in $(find .  -name "$3")
do
  let files++
  filename=$(basename -- "$f")
  extension="${filename##*.}"
  source_filename="${filename%.*}"
  source_dir=$(cd $(dirname $f); pwd)
  #make target if doesn't exist
  test -d ${dest}$(dirname ${f}) &&  sleep 0 || mkdir $dest$(dirname $f)
  target_dir=$(cd $dest$(dirname $f); pwd)
  target_filename=$source_filename
  if [[ -e $target_dir/$source_filename.$extension ]] ; then
    i=1
    while [[ -e $target_dir/${source_filename}_$i.$extension ]] ; do
        let i++
    done
    target_filename=${source_filename}_$i
  fi
  #echo "$f \n    dir:$source_dir \n    filename:$filename\n   extension:$extension \n    targ:$target_dir \n    targ_file:$target_filename"
  echo "move '$source_dir/$source_filename.$extension' '$target_dir/$target_filename.$extension'"

  #Uncomment next line to make the moves...otherwise, this script just shows what it would move.
  #mv -n $source_dir/$source_filename.$extension $target_dir/$target_filename.$extension

done

echo "Processed Files: $files"

# Pruning empty directories...just a thought, but not implemented fully
#[ ! -z "$source_dir" ] && echo "find $source_dir -type d -exec rmdir {} + 2>/dev/null"
