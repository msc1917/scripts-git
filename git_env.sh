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
		ignore=true
		if echo ${LINE} | grep -q "^\[[^]][^]]*\].*"
		then
			git_category="$(echo ${LINE} | sed "s/^\[\([^]][^]]*\)\].*$/\1/g")"
			if echo "${git_category}" |grep -q ${1}
			then
				ignore=false
				echo "Kathegorie: >${git_category}<"
			else
				ignore=true
				echo "Kathegorie: \"${git_category}\" (Wird ignoriert)"
			fi
		else
			github_address=$(echo ${LINE} | cut -f 1 -d " ")
			target_path=$(echo ${LINE} | cut -f 2 -d " ")
			git_branch="["$(echo ${LINE} | cut -f 3 -d " ")"]"
			if ${ignore}
			then
				echo "  ==> ${github_address}${git_branch} -> ${target_path} (Wird ignoriert)"
			else
				if [ ! -d "${target_path}" ]
				then
					echo "  ==> ${github_address}${git_branch} -> ${target_path} (Klone Repository)"
					# git clone ${github_address}${git_branch} ${target_path}
				else
					echo "  ==> ${github_address}${git_branch} -> ${target_path} (Repository bereits Vorhanden)"
				fi
			fi
		fi
	done
done