draw_chars()
{
	local char=""
	local char_start=0
	local char_length=${1}
	local char_type=${2:--}
	until [ ${char_start} -eq ${char_length} ]
	do
		char="${char}${char_type}"
		char_start=$(expr ${char_start} + 1 )
	done
	printf "%s" "${char}"
}

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
		if echo "${git_status}" | grep -qE "^Your branch is behind of '[^'][^']*' by [0-9]*[1-9] commits?.$"
		then 
			for LINE in "$(echo "${git_status}" | grep -E "^Your branch is behind of '[^'][^']*' by [0-9]*[1-9] commits?.$" | sed "s/^Your branch is behind of '\([^'][^']*\)' by \([0-9]*[1-9]\) commits\?.$/\1[-\2]/")"
			do
				remote_repository_status="${remote_repository_status}${LINE}\n"
			done
		fi
		# Your branch is behind of 'origin/main' by 2 commits.
		if echo "${git_status}" | grep -qE "^Your branch is ahead of '[^'][^']*' by [0-9]*[1-9] commits?.$"
		then
			for LINE in "$(echo "${git_status}" | grep -E "^Your branch is ahead of '[^'][^']*' by [0-9]*[1-9] commits?.$" | sed "s/^Your branch is ahead of '\([^'][^']*\)' by \([0-9]*[1-9]\) commits\?.$/\1[+\2]/")"
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

render_git_repository()
{
	local git_repository_list="$(echo "${1}" | grep -E "^(git_repository|git_submodule):[^:][^:]*:[^:][^:]*:[^:][^:]*:[^:][^:]*$")"
	local headline_directory="Verzeichnis"
	local headline_local_branch="Branch"
	local headline_repository_status="Status"
	local headline_remote_branch="Remote"

	local length_directory=${#headline_directory}
	local length_local_branch=${#headline_local_branch}
	local length_repository_status=${#headline_repository_status}
	local length_remote_branch=${#headline_remote_branch}
	# local length_sync_status=0
	local submodule_marker="  ==> "
	for LINE in ${git_repository_list}
	do
		local type="$(echo "${LINE}" | cut -f 1 -d ":")"
		local directory="$(echo "${LINE}" | cut -f 2 -d ":")"
		local local_branch="$(echo "${LINE}" | cut -f 3 -d ":")"
		local repository_status="$(echo "${LINE}" | cut -f 4 -d ":")"
		local remote_branch="$(echo "${LINE}" | cut -f 5 -d ":")"

		if [ "${type}" = "git_repository" ]
		then
			length_this_directory=${#directory}
		else
			length_this_directory=$(expr ${#directory} + ${#submodule_marker})
		fi

		if [ ${length_directory} -lt ${length_this_directory} ]
		then
			length_directory=${length_this_directory}
		fi

		if [ ${length_local_branch} -lt ${#local_branch} ]
		then
			length_local_branch=${#local_branch}
		fi

		if [ ${length_repository_status} -lt ${#repository_status} ]
		then
			length_repository_status=${#repository_status}
		fi

		if [ ${length_remote_branch} -lt ${#remote_branch} ]
		then
			length_remote_branch=${#remote_branch}
		fi
	done

	printf "%-${length_directory}s %-${length_local_branch}s %-${length_repository_status}s %-${length_remote_branch}s\n" "${headline_directory}" "${headline_local_branch}" "${headline_repository_status}" "${headline_remote_branch}"
	printf "%-${length_directory}s %-${length_local_branch}s %-${length_repository_status}s %-${length_remote_branch}s\n" "$(draw_chars ${length_directory})" "$(draw_chars ${length_local_branch})" "$(draw_chars ${length_repository_status})" "$(draw_chars ${length_remote_branch})"

	echo "${git_repository_list}" | grep "^git_repository" | sort | while read LINE
	do
		local type="$(echo "${LINE}" | cut -f 1 -d ":")"
		local directory="$(echo "${LINE}" | cut -f 2 -d ":")"
		local local_branch="$(echo "${LINE}" | cut -f 3 -d ":")"
		local repository_status="$(echo "${LINE}" | cut -f 4 -d ":")"
		local remote_branch="$(echo "${LINE}" | cut -f 5 -d ":")"
		printf "%-${length_directory}s %-${length_local_branch}s %-${length_repository_status}s %-${length_remote_branch}s\n" "${directory}" "${local_branch}" "${repository_status}" "${remote_branch}"
		if echo "${git_repository_list}" | grep -q "^git_submodule:${directory}"
		then
			echo "${git_repository_list}" | grep "^git_submodule:${directory}" | sort | while read submodule_line
			do
				local type="$(echo "${submodule_line}" | cut -f 1 -d ":")"
				local directory="$(echo "${submodule_line}" | cut -f 2 -d ":")"
				local local_branch="$(echo "${submodule_line}" | cut -f 3 -d ":")"
				local repository_status="$(echo "${submodule_line}" | cut -f 4 -d ":")"
				local remote_branch="$(echo "${submodule_line}" | cut -f 5 -d ":")"
				printf "%-${length_directory}s %-${length_local_branch}s %-${length_repository_status}s %-${length_remote_branch}s\n" "${submodule_marker}${directory}" "${local_branch}" "${repository_status}" "${remote_branch}"
			done
		fi
	done
}