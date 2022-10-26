#!/bin/bash

# https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
function join_by { local IFS="$1"; shift; echo "$*"; }
function first { echo $1; }

# get a map of folder names to ids
declare -A obsolete_mods
for a in `grep -iPl '"obsolete":\s+true' data/mods/*/modinfo.json|sed -r "s/data\/mods\/(.*?)\/modinfo\.json/\1/"` ; do 
	tmp=`grep -iPoh '(?<="id": ").*?(?=")' data/mods/$a/modinfo.json`
	obsolete_mods[$a]=`first $tmp`
	done

declare subst=`join_by \| ${obsolete_mods[*]}`
echo Obsolete mods found\:  ${obsolete_mods[*]}

mkdir -p mods
for a in ${!obsolete_mods[*]} ; do 
	echo Working on $a...
	
	# if an older version exists, remove it
	rm -dfr "mods/obsolete-$a"
	
	# copy mod from default mods to user mods
	mkdir "mods/obsolete-$a"
	for b in "data/mods/$a/*"; do 
		cp -ar $b "mods/obsolete-$a/"
		done
	
	declare modinfo="mods/obsolete-$a/modinfo.json"
	
	# change the obsolete flag to false
	sed -i '/obsolete/s/true/false/' $modinfo
	
	# change the name to inform user of obsolete status
	sed -ri '0,/\}/{s/"name": "(.*?)"/"name": "[OBSOLETE] \1"/}' $modinfo
	
	# change the ident to avoid conflicts with the default mod
	sed -i "/id/s/${obsolete_mods[$a]}/OBSOLETE_${obsolete_mods[$a]}/" $modinfo
	
	#change dependencies to refer to un-obsoleted user mods instead of obsolete default mods
	sed -ri "/dependencies/s/$subst/OBSOLETE_\0/g" $modinfo
	
	done
