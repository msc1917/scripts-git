#! /bin/sh

directories="script development"
homedir=~


check_git_repository()
{
	local directory="${1}"
	local old_dir="$(pwd)"
	if [ -d "${directory}" ]
	then
		cd "${directory}" >/dev/null 2>/dev/null
		git_status="$(git status -v)"
		# On branch main
		git_local_branch="$(echo "${git_status}" | grep "^On branch [^ ][^ ]*$" | sed "s/On branch //")"

		local remote_repository_status=""
		# Your branch is up to date with 'origin/main'.
		if echo "${git_status}" | grep -q "^Your branch is up to date with '[^'][^']*'.$"
		then
			for LINE in $(echo "${git_status}" | grep "^Your branch is up to date with '[^'][^']*'.$" | sed "s/^Your branch is up to date with '\([^'][^']*\)'.$/\1\[sync]/")
			do
				remote_repository_status="${remote_repository_status}${LINE}\n"
			done
			fi
		# Your branch is ahead of 'origin/main' by 2 commits.
		if echo "${git_status}" | grep -q "^Your branch is behind of  '[^'][^']*' by [0-9]*[1-9] commits?.$"
		then
			for LINE in "$(echo "${git_status}" | grep "^Your branch is behind of  '[^'][^']*' by [0-9]*[1-9] commits?.$" | sed "s/^Your branch is behind of  '\([^'][^']*\)' by \([0-9]*[1-9]\) commits?.$/\1[+\2]/")"
			do
				remote_repository_status="${remote_repository_status}${LINE}\n"
			done
				fi
		# Your branch is behind of 'origin/main' by 2 commits.
		if echo "${git_status}" | grep -q "^Your branch is ahead of  '[^'][^']*' by [0-9]*[1-9] commits?.$"
		then
			for LINE in "$(echo "${git_status}" | grep "^Your branch is ahead of  '[^'][^']*' by [0-9]*[1-9] commits?.$" | sed "s/^Your branch is ahead of  '\([^'][^']*\)' by \([0-9]*[1-9]\) commits?.$/\1[-\2]/")"
	        do
				remote_repository_status="${remote_repository_status}${LINE}\n"
			done
				fi
		local remote_repository_status_output=""
		if [ "${remote_repository_status}" = "" ]
		then
			remote_repository_status_output="no_remote_repository"
		else
			for LINE in $(echo "${remote_repository_status}" | sort)
			do
				remote_repository_status_output="${remote_repository_status_output}${LINE},"
			done
			remote_repository_status_output="$(echo "${remote_repository_status_output}" | sed "s/,$//")"
		done

		local repository_status=""
		# nothing to commit, working tree clean
		if echo "${git_status}" | grep -q "^nothing to commit, working tree clean$"
		then
			repository_status="clean"
		else
			# Changes not staged for commit:
			if echo "${git_status}" | grep -q "^Changes not staged for commit:$"
			then
			fi
			# Untracked files:
			if echo "${git_status}" | grep -q "^Untracked files:$"
			then
			fi
		fi


	echo "${git_local_branch}:${remote_repository_status_output}"
	fi
	cd ${old_dir} >/dev/null 2>/dev/null
}

check_git_dir()
{
	local directory="${1}"
	local old_dir="$(pwd)"
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
					cd ${directory}/${submodule_directory} >/dev/null 2>/dev/null
					echo "git_submodule:${directory}/${submodule_directory}"
					check_git_repository ${directory}/${submodule_directory}
					#check_git_dir "$(dirname "${directory}")/${submodule_directory}"
				fi
			done
		fi

		cd ${old_dir} >/dev/null 2>/dev/null
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