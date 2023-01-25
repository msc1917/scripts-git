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



find ${default_config_dir}/git_list.d/ -type f -name *.list | while read filename;
do cat ${filename} | grep -v "^ *$" | while read LINE;
	do
		if echo ${LINE} | grep -q "^\[[^]][^]]*\].*"
		then
			git_category="$(echo ${LINE} | sed "s/^\[\([^]][^]]*\)\].*$/\1/g")"
			echo "Kathegorie: >${git_category}<"
		else
			github_address=$(echo ${LINE} | cut -f 1 -d " ")
			target_path=$(echo ${LINE} | cut -f 2 -d " ")
			git_branch=$(echo ${LINE} | cut -f 3 -d " ")
			echo "  ==> ${github_address}[${git_branch}] -> ${target_path}"
		fi
	done
done