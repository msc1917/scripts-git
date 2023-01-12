#! /bin/sh

### Loader fuer base-libraries
homedir=~
base_configuration_directory=~/etc/base_configuration
if [ -d ${base_configuration_directory} ]
then
	. ${base_configuration_directory}/base_presets.sh
	. ${base_configuration_directory}/git_presets.sh
else
. ./base_functions.sh
. ./presets.sh
fi

for library_file in git_library.sh visuals_library.sh
do
	. ${default_functions_dir}/${library_file}
	done
###


search_path=""
for directory in ${git_repository_base_directories}
do
	if [ -d ~/${directory} ]
	then
		search_path="${search_path} ${homedir}/${directory}/"
	fi
done

if [ "${search_path}" != "" ]
then
	git_repository_list=""
	for directory in $(find ${search_path} -type d -name .git | sort)
	do
		parse_git_repository ${directory} | while read repository_line
		do
			repo_directory="$(echo "${repository_line}" | cut -f 2 -d ":")"
			repo_state="$(echo "${repository_line}" | cut -f 4 -d ":")"
			if [ "${repo_state}" = "clean" ]
			then
				echo "Fuehre Git-Pull fuer Repository im Verzeichnis ${repo_directory} durch."
				git -C ${repo_directory} pull
			else
				echo "Repository im Verzeichnis ${repo_directory} ist nicht \"clean\"."
			fi
		done
	done

else
	echo "Kein Verzeichnis vorhanden (Gesucht wurde in$(echo " ${git_repository_base_directories}" | sed "s/ / ~\//g"))."
	exit 1
fi