#! /bin/sh

module_directory=~/script/ansible/roles
directory_length=0
ls ${module_directory} | while read directory;
do
	full_directory="${module_directory}/${directory}"
	if [ ${#full_directory} -gt ${directory_length} ]
	then
		directory_length=${#full_directory}
	fi
done

ls ${module_directory} | while read directory;
do
	cd ${module_directory}/${directory}
	result=$(git status)
	if echo ${result} | grep -q "HEAD detached at"
	then
		git_detached=1
	else
		git_detached=0
	fi
	if echo ${result} | grep -q "nothing to commit, working tree clean"
	then
		git_clean=1
	else
		git_clean=0
	fi

	if [ ${git_detached} -eq 1 -a ${git_clean} -eq 1 ]
	then
		printf "%${directory_length}s: %1s\n" "${module_directory}/${directory}" "Detached head and clean repository: fixing..."
		git checkout main
	elif [ ${git_detached} -eq 1 -a ${git_clean} -eq 0 ]
	then
		printf "%${directory_length}s: %1s\n" "${module_directory}/${directory}" "Detached head but no clean repository: manual fix needed..."
	else
		printf "%${directory_length}s: %1s\n" "${module_directory}/${directory}" "Clean Git repository, nothing to do..."
	fi

	cd - >/dev/null
done