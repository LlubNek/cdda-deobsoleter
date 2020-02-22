#!/bin/bash

# https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
function join_by { local IFS="$1"; shift; echo "$*"; }

# get a map of folder names to ids
declare -A obsolete_mods
for a in `grep -iPl '"obsolete":\s+true' data/mods/*/modinfo.json|sed -r "s/data\/mods\/(.*?)\/modinfo\.json/\1/"` ; do 
	obsolete_mods[$a]=`grep -iPoh '(?<="ident": ").*?(?=")' data/mods/$a/modinfo.json`
	done

declare subst=`join_by \| ${obsolete_mods[*]}`

mkdir -p mods
for a in ${!obsolete_mods[*]} ; do 
	echo Working on $a...
	
	# if an older version exists, remove it
	rm -dfr "mods/$a"
	
	# copy mod from default mods to user mods
	cp -r "data/mods/$a" mods
	
	# change the obsolete flag to false
	sed -i '/obsolete/s/true/false/g' "mods/$a/modinfo.json"
	
	# change the ident to avoid conflicts with the default mod
	sed -i "/ident/s/${obsolete_mods[$a]}/OBSOLETE_${obsolete_mods[$a]}/" "mods/$a/modinfo.json"
	
	#change dependencies to refer to un-obsoleted user mods instead of obsolete default mods
	sed -ri "/dependencies/s/$subst/OBSOLETE_\0/g" "mods/$a/modinfo.json"
	
	done
