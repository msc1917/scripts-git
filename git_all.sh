#! /bin/sh

directories="script development"
homedir=~

check_git_dir()
{
	directory="${1}"
	if [ -d "${directory}" ]
	then
		cd $(dirname "${directory}") >/dev/null 2>/dev/null
		directory="$(git rev-parse --show-toplevel)"
		echo "git_repository:${directory}"
		if [ -f ${directory}/.gitmodules ]
		then
			for submodule_directory in $(cat ${directory}/.gitmodules | grep " *path = " | cut -f 2 -d "=")
			do
				if [ -f "${directory}/${submodule_directory}/.git" ]
				then
					echo "git_submodule:${directory}/${submodule_directory}"
					#check_git_dir "$(dirname "${directory}")/${submodule_directory}"
				fi
			done
		fi

		cd - >/dev/null 2>/dev/null
	fi
}

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
	for directory in $(find ${search_path} -type d -name .git | sort)
	do
		check_git_dir ${directory}
	done
else
	echo "Kein Verzeichnis vorhanden (Gesucht wurde in$(echo " ${directories}" | sed "s/ / ~\//g"))."
	exit 1
fi