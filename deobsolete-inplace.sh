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

for a in ${!obsolete_mods[*]} ; do 
	echo Working on $a...
	
	declare modinfo="data/mods/$a/modinfo.json"
	
	# change the obsolete flag to false
	sed -i '/obsolete/s/true/false/' $modinfo
	
	# change the name to inform user of obsolete status
	sed -ri '0,/\}/{s/"name": "(.*?)"/"name": "[DEOBSOLETED] \1"/}' $modinfo
	
	done
