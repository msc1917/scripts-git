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
		git_repository_list="${git_repository_list}\n$(parse_git_repository ${directory})"
	done

	render_git_repository "${git_repository_list}"
else
	echo "Kein Verzeichnis vorhanden (Gesucht wurde in$(echo " ${directories}" | sed "s/ / ~\//g"))."
	exit 1
fi