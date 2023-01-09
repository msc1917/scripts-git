#! /bin/sh

directories="script development"
homedir=~


check_git_repository()
{
	directory="${1}"
	old_dir="$(pwd)"
	if [ -d "${directory}" ]
	then
		cd $(dirname "${directory}") >/dev/null 2>/dev/null
		git_status="$(git status -v)"
		# On branch main
		git_local_branch="$(echo "${git_status}" | grep "^On branch [^ ][^ ]*$" | sed "s/On branch //")"

		# Your branch is up to date with 'origin/main'.
		echo "${git_status}" | grep "^Your branch is up to date with [^ ][^ ]*$"

# nothing to commit, working tree clean



# 	On branch main
# Your branch is up to date with 'origin/main'.

# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git restore <file>..." to discard changes in working directory)
#         modified:   tasks/main.yml

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)

}

check_git_dir()
{
	directory="${1}"
	old_dir="$(pwd)"
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
					git status -s
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