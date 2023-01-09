#! /bin/sh

directories="script development"
homedir=~


parse_git_repository_status()
{
	local directory="${1}"
	local old_dir="$(pwd)"
	if [ -d "${directory}" ]
	then
		cd "${directory}" >/dev/null 2>/dev/null
		git_status="$(git status -v)"


		# -----------
		# Local Repository Status
		# -----------
		# On branch main
		if echo "${git_status}" | grep -q "^On branch [^ ][^ ]*$"
		then
			git_local_branch="$(echo "${git_status}" | grep "^On branch [^ ][^ ]*$" | sed "s/On branch //")"
		elif echo "${git_status}" | grep -q "^HEAD detached at [0-9a-f][0-9a-f]*"
		then
			git_local_branch="[DETACHED_HEAD]"
		else
			git_local_branch="[ERROR]"
		fi

		# -----------
		# Remote Repository Status
		# -----------
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
		fi

		# -----------
		# Repository Status
		# -----------
		local repository_status=""
		# nothing to commit, working tree clean
		if echo "${git_status}" | grep -q "^nothing to commit, working tree clean$"
		then
			repository_status="clean"
		else
			# Changes not staged for commit:
			if echo "${git_status}" | grep -q "^Changes not staged for commit:$"
			then
				repository_status="${repository_status}unstaged_files,"
			fi
			# Untracked files:
			if echo "${git_status}" | grep -q "^Untracked files:$"
			then
				repository_status="${repository_status}untracked_files,"
			fi
			repository_status="$(echo "${repository_status}" | sed "s/,$//")"
		fi


	echo "${git_local_branch}:${repository_status}:${remote_repository_status_output}"
	fi
	cd ${old_dir} >/dev/null 2>/dev/null
}

parse_git_repository()
{
	local directory="${1}"
	local old_dir="$(pwd)"
	if [ -d "${directory}" ]
	then
		cd $(dirname "${directory}") >/dev/null 2>/dev/null
		directory="$(git rev-parse --show-toplevel)"
		echo "git_repository:${directory}:$(parse_git_repository_status ${directory})"
		if [ -f ${directory}/.gitmodules ]
		then
			for submodule_directory in $(cat ${directory}/.gitmodules | grep " *path = " | cut -f 2 -d "=")
			do
				if [ -f "${directory}/${submodule_directory}/.git" ]
				then
					cd ${directory}/${submodule_directory} >/dev/null 2>/dev/null
					echo "git_submodule:${directory}/${submodule_directory}:$(parse_git_repository_status ${directory}/${submodule_directory})"
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
		parse_git_repository ${directory}
	done
else
	echo "Kein Verzeichnis vorhanden (Gesucht wurde in$(echo " ${directories}" | sed "s/ / ~\//g"))."
	exit 1
fi