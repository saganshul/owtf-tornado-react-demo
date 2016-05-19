#!/usr/bin/env sh
# Description: This script grabs all the excellent CMS Explorer dictionaries, updates them and converts them into DirBuster format (much faster than CMS Explorer)


# bring in the variables: `normal`, `info`, `warning`, `danger`, `reset`, `user-agent`
. "$(dirname "$(readlink -f "$0")")/utils.sh"

RootDir=$1
SOURCE_DIR="$RootDir/tools/restricted/cms-explorer"

if [ ! -d "$SOURCE_DIR" ]; then
  wget --user-agent="${user_agent}" --tries=3 http://cms-explorer.googlecode.com/files/cms-explorer-1.0.tar.bz2; bunzip2 *; tar xvf *; rm -f *.tar 2> /dev/null
fi

CMS_EXPLORER_DIR="$RootDir/tools/restricted/cms-explorer/cms-explorer-1.0"
CMS_EXPLORER_UPDATE_SCRIPT="$RootDir/scripts/update_cms_explorer_lists.py"
CMS_DICTIONARIES_DIR="$RootDir/dictionaries/restricted/cms"
mkdir -p ${CMS_DICTIONARIES_DIR}

DICTIONARIES="$CMS_EXPLORER_DIR/drupal_plugins.txt
$CMS_EXPLORER_DIR/joomla_themes.txt
$CMS_EXPLORER_DIR/wp_plugins.txt
$CMS_EXPLORER_DIR/drupal_themes.txt
$CMS_EXPLORER_DIR/wp_themes.txt
$CMS_EXPLORER_DIR/joomla_plugins.txt"

echo "${info}[*] Going into directory: $CMS_EXPLORER_DIR${reset}"
cd ${CMS_EXPLORER_DIR}

echo "${normal}[*] Updating cms-explorer dictionaries..${reset}"
./cms-explorer.pl -update
python $CMS_EXPLORER_UPDATE_SCRIPT

echo "${info}[*] Merging old and new lists...${reset}"
for list in $(echo ${DICTIONARIES}); do
    cat "$list.new" >> $list 2> /dev/null;
    rm "$list.new" 2> /dev/null;
    cat $list | sort -u > "$list.tmp" # Remove duplicates, just in case;
    mv "$list.tmp" $list;
done

# leaving the directory in order to copy the lists from dict_root
cd ../../

echo "${info}[*] Copying updated dictionaries from $CMS_EXPLORER_DIR to $CMS_DICTIONARIES_DIR${reset}"
for i in $(echo ${DICTIONARIES}); do
	cp ${i} ${CMS_DICTIONARIES_DIR} # echo "[*] Copying $i .."
done

cd ${CMS_DICTIONARIES_DIR}

DIRBUSTER_PREFIX="dir_buster"
for cms in $(echo "drupal joomla wp"); do
	mkdir -p ${cms} # Create CMS specific directory
	rm -f ${cms}/* # Remove previous dictionaries
	mv ${cms}* ${cms} 2> /dev/null # Move relevant dictionaries to directory, getting rid of "cannot move to myself" error, which is ok
	cd ${cms} # Enter directory
	for dict in $(ls); do # Now process each CMS-specific dictionary and convert it
		cat ${dict} | tr '/' "\n" | sort -u > ${DIRBUSTER_PREFIX}.${dict} # Convert to DirBuster format (i.e. get rid of the "/" and duplicate parent directories)
		rm -f ${dict} # Remove since this only works with CMS explorer
	done
	# Create all-in-one CMS-specific dictionaries:
	cat ${DIRBUSTER_PREFIX}* > ${DIRBUSTER_PREFIX}.all.${cms}.txt
	cd ..
done

echo "${normal}[*] Creating all-in-one CMS dictionaries for DirBuster and CMS Explorer${reset}"
for bruteforcer in $(echo "$DIRBUSTER_PREFIX"); do
	ALLINONE_DICT="$bruteforcer.all_in_one.txt"
	rm -f ${ALLINONE_DICT} # Remove previous, potentially outdated all-in-one dict
	for all_dict in $(find . -name *all*.txt | grep ${bruteforcer}); do
		cat ${all_dict} >> ${ALLINONE_DICT}
	done
	cat ${ALLINONE_DICT} | sort -u > ${ALLINONE_DICT}.tmp # Remove duplicates, just in case
	mv ${ALLINONE_DICT}.tmp ${ALLINONE_DICT}
done
