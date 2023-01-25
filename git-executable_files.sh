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

filetypes=".sh .bash .py"

search_path=""
for directory in ${git_repository_base_directories}
do
	if [ -d ${homedir}/${directory} ]
	then
		search_path="${search_path} ${homedir}/${directory}/"
	fi
done

if [ "${search_path}" != "" ]
then
	for directory in $(find ${search_path} -type d -name .git | sort)
	do
		parse_git_repository ${directory} | grep "^git_repository:" | cut -f 2 -d ":" | while read repository_directory
		do
			for filetype in $(echo ${filetypes} | sed "s/\.//g" )
			do
				find ${repository_directory} -type f -name "*.${filetype}" | while read script_file
				do
					echo "${script_file}"
					script_first_line=$(head -1 ${script_file})
					script_chmod_state=$(stat -c %a ${script_file})
					if echo "${script_first_line}" | grep -q "^#! *"
					then
						script_interpreter=$(echo "${script_first_line}" | sed "s/^#! *//")
						echo "Script-File ${script_interpreter} ${script_chmod_state}"
						if [ -f "${script_interpreter}" -a $(echo "${script_chmod_state}" | cut -c 1) -ne 7 ]
						then
							echo "Aendere File:"
							echo "git update-index --chmod=+x ${script_file}"
							echo "chmod +x ${script_file}"
						fi
					else
						echo "Something else"
					fi
				done
			done
		done
	done
fi