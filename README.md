# cdda-deobsoleter
## deobsolete.sh
This script copies obsolete Cataclysm: DDA mods from the data folder to the user mods folder, toggles the obsolete tag, and fixes identifiers so that these mods can once again be used.
This does not wipe out your other user mods, nor change anything in the default mods.
## deobsolete-inplace.sh
This script toggles the deobsolete flag on obsolete Cataclysm: DDA mods and changes the name to indicate that the mod was deobsoleted, but doesn't change the mod id or copy/move the mod.
This does change the default mods but doesn't touch user mods.  This should be more compatible with off-repo mods that expect the default mod id.