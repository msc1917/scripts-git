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
		echo "      ${LINE}"
	done
}

echo "\nPreparing..."
if [ ! -d ${default_config_dir}/git_list.d ]
then
	echo "  ==> Getting settings from Github (${git_settings_repo})"
	git clone ${git_settings_repo} ${default_config_dir}/git_list.d 2>&1 | intend
else
	if [ -d ${default_config_dir}/git_list.d/.git -a -f ${default_config_dir}/git_list.d/.git/FETCH_HEAD ]
	then
		if [ $(expr $(date "+%s") - 600) -gt $(stat -c %Y ${default_config_dir}/git_list.d/.git/FETCH_HEAD) ]
		then
			echo "  ==> Actualize settings from Github (${git_settings_repo})"
			git -C ${default_config_dir}/git_list.d push 2>&1 | intend
			git -C ${default_config_dir}/git_list.d pull 2>&1 | intend
			touch ${default_config_dir}/git_list.d/.git/FETCH_HEAD
		else
			echo "  ==> Last pull least 10 Min ago Github (${git_settings_repo})"
		fi
	else
		echo "  ==> [Error]: ${default_config_dir}/git_list.d seems to be no git repository for ${git_settings_repo}"
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
					echo "\nKathegorie: \"${git_category}\""
				else
					ignore=true
					echo "\nKathegorie: \"${git_category}\" (Wird ignoriert)"
				fi
			else
				ignore=false
				echo "\nKathegorie: \"${git_category}\""
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
				echo "  ==> ${github_address}${git_branch} -> ${target_path} (Wird ignoriert)"
			else
				if [ ! -d "${target_path}" ]
				then
					if [ -d $(echo "${target_path}" | sed "s#^~#${HOME}#") ]
					then
						echo "  ==> ${github_address}${git_branch} -> ${target_path} (Pull Repository)"
						if echo "${my_git_repos}" | grep -q "$(echo ${github_address} | sed "s#^[^@][^@]*@\([^/][^/]*\)/.*#\1#")"
						then
							git -C $(echo "${target_path}" | sed "s#^~#${HOME}#") push 2>&1 | intend
						else
							echo "No automatic push from ${github_address}..." | intend
						fi
						git -C $(echo "${target_path}" | sed "s#^~#${HOME}#") pull 2>&1 | intend
					else
						echo "  ==> ${github_address}${git_branch} -> ${target_path} (Klone Repository)"
						git clone ${github_address} $(echo "${target_path}" | sed "s#^~#${HOME}#") 2>&1 | intend
					fi

					# git clone ${github_address}${git_branch} $(echo "${target_path}" | sed "s#^~#${HOME}#")
				else
					echo "  ==> ${github_address}${git_branch} -> ${target_path} (Repository bereits Vorhanden)"
				fi
			fi
		fi
	done
done

echo "Fertig"