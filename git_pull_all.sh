#! /bin/sh

homedir=~

. ./base_functions.sh
. ./presets.sh

search_path=""
for directory in ${directories}
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
	echo "Kein Verzeichnis vorhanden (Gesucht wurde in$(echo " ${directories}" | sed "s/ / ~\//g"))."
	exit 1
fi