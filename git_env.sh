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

git_settings_repo="git@github.com:msc1917/settings_git_repo.git"
my_git_repos="github.com:msc1917"

for library_file in git_library.sh visuals_library.sh
do
	. ${default_functions_dir}/${library_file}
	done
###

intend()
{
	while read LINE;
	do
		echo "${col_act}      ${LINE}${col_off}"
	done
}

if which tput > /dev/null
then
	echo "tput-mode"
	export col_act=$(tput setaf 3)
	export col_inact=$(tput setaf 6)
	export col_err=$(tput setaf 1)
	export col_bold=$(tput bold)
	export col_off=$(tput sgr0)
fi

printf "${col_act}${col_bold}\nPreparing...\n${col_off}"
if [ ! -d ${default_config_dir}/git_list.d ]
then
	printf "${col_act}  ==> Getting settings from Github (${git_settings_repo})\n${col_off}"
	git clone ${git_settings_repo} ${default_config_dir}/git_list.d 2>&1 | intend
else
	if [ -d ${default_config_dir}/git_list.d/.git -a -f ${default_config_dir}/git_list.d/.git/FETCH_HEAD ]
	then
		if [ $(expr $(date "+%s") - 600) -gt $(stat -c %Y ${default_config_dir}/git_list.d/.git/FETCH_HEAD) ]
		then
			printf "${col_act}  ==> Actualize settings from Github (${git_settings_repo})${col_off}\n"
			git -C ${default_config_dir}/git_list.d push 2>&1 | intend
			git -C ${default_config_dir}/git_list.d pull 2>&1 | intend
			touch ${default_config_dir}/git_list.d/.git/FETCH_HEAD
		else
			echo "${col_inact}  ==> Last pull least 10 Min ago Github (${git_settings_repo})${col_off}"
		fi
	else
		echo "${col_err}  ==> [Error]: ${default_config_dir}/git_list.d seems to be no git repository for ${git_settings_repo}${col_off}"
	fi
fi

# find ${default_config_dir}/git_list.d/ -type f -name *.list | while read filename;
for filename in $(find ${default_config_dir}/git_list.d/ -type f -name *.list)
do
ignore=true
	cat ${filename} | grep -v "^ *$" | grep -v "^ *#" | while read LINE;
	do
		if echo ${LINE} | grep -q "^ *\[[^]][^]]*\].*"
		then
			git_category="$(echo "${LINE}" | sed "s/^ *\[\([^]][^]]*\)\].*$/\1/g")"
			if [ "${#}" -gt 0 ]
			then
				line_in_parameters=false
				for item in ${*}
				do
					# echo "${git_category} ${item}"
					if echo "${git_category}" |grep -q ${item}
					then
						line_in_parameters=true
					fi
				done
				if ${line_in_parameters}
				then
					ignore=false
					echo "${col_act}${col_bold}\nKathegorie: \"${git_category}\"${col_off}"
				else
					ignore=true
					echo "${col_inact}${col_bold}\nKathegorie: \"${git_category}\" (Wird ignoriert)${col_off}"
				fi
			else
				ignore=false
				echo "${col_act}${col_bold}\nKathegorie: \"${git_category}\"${col_off}"
			fi
		else
			git_branch=[]
			github_address="$(echo ${LINE} | cut -f 1 -d " ")"
			target_path="$(echo ${LINE} | cut -f 2 -d " ")"
			git_branch="$(echo ${LINE} | cut -f 3 -d " ")"
			if [ "${git_branch}" != "" ]
			then
				git_branch="[${git_branch}]"
			fi
			if ${ignore}
			then
				echo "${col_inact}  ==> ${github_address}${git_branch} -> ${target_path} (Wird ignoriert)${col_off}"
			else
				if [ ! -d "${target_path}" ]
				then
					if [ -d $(echo "${target_path}" | sed "s#^~#${HOME}#") ]
					then
						echo "${col_act}  ==> ${github_address}${git_branch} -> ${target_path} (Pull Repository)${col_off}"
						git -C $(echo "${target_path}" | sed "s#^~#${HOME}#") pull 2>&1 | intend

						if echo "${my_git_repos}" | grep -q "$(echo ${github_address} | sed "s#^[^@][^@]*@\([^/][^/]*\)/.*#\1#")"
						then
							git -C $(echo "${target_path}" | sed "s#^~#${HOME}#") push 2>&1 | intend
						else
							echo "${col_noact}No automatic push from ${github_address}...${col_off}" | intend
						fi
					else
						echo "${col_act}  ==> ${github_address}${git_branch} -> ${target_path} (Klone Repository)${col_off}"
						git clone ${github_address} $(echo "${target_path}" | sed "s#^~#${HOME}#") 2>&1 | intend
					fi

					# git clone ${github_address}${git_branch} $(echo "${target_path}" | sed "s#^~#${HOME}#")
				else
					echo "${col_inact}  ==> ${github_address}${git_branch} -> ${target_path} (Repository bereits Vorhanden)${col_off}"
				fi
			fi
		fi
	done
done

echo "${col_act}${col_bold}Fertig${col_off}"