#! /bin/sh
list_directory=repository_list
list_file_markup=repositories.md
list_file_json=repositories.json
repository_owner=msc1917
github_data="name,isPrivate,isArchived,repositoryTopics,description,hasIssuesEnabled,hasProjectsEnabled,hasWikiEnabled"
entries_markupfile=$(expr $(wc -l ${list_directory}/${list_file_markup} | cut -f 1 -d " ") - 2)

cat ${list_directory}/${list_file_markup} | tail -${entries_markupfile} | while read LINE;
do
	git_repository="$(echo "${LINE}" | cut -f 1 -d "|" | sed "s/^ *\([^ ].*[^ ]\) *$/\1/")"
	git_mode="$(echo "${LINE}" | cut -f 2 -d "|" | sed "s/^ *\([^ ].*[^ ]\) *$/\1/")"
	git_issue_state="$(echo "${LINE}" | cut -f 3 -d "|" | sed "s/^ *\([^ ].*[^ ]\) *$/\1/")"
	git_project_state="$(echo "${LINE}" | cut -f 4 -d "|" | sed "s/^ *\([^ ].*[^ ]\) *$/\1/")"
	git_wiki_state="$(echo "${LINE}" | cut -f 5 -d "|" | sed "s/^ *\([^ ].*[^ ]\) *$/\1/")"
	git_state="$(echo "${LINE}" | cut -f 6 -d "|" | sed "s/^ *\([^ ].*[^ ]\) *$/\1/")"
	git_label="$(echo "${LINE}" | cut -f 7 -d "|" | sed "s/,/ /g" | sed "s/^ *\([^ ].*[^ ]\) *$/\1/")"
	git_description="$(echo "${LINE}" | cut -f 8 -d "|" | sed "s/^ *\([^ ].*[^ ]\) *$/\1/")"

	case "${git_mode}" in
		"Private" ) git_mode="true";;
		"Public" )  git_mode="false";;
		* ) git_mode="ERROR";;
	esac
	case "${git_state}" in
		"Archived" ) git_state="true";;
		"Open" )  git_state="false";;
		* ) git_state="ERROR";;
	esac
	case "${git_issue_state}" in
		"Yes" ) git_issue_state="true";;
		"No" ) git_issue_state="false";;
		* ) git_issue_state="ERROR";;
	esac
	case "${git_project_state}" in
		"Yes" ) git_project_state="true";;
		"No" ) git_project_state="false";;
		* ) git_project_state="ERROR";;
	esac
	case "${git_wiki_state}" in
		"Yes" ) git_wiki_state="true";;
		"No" ) git_wiki_state="false";;
		* ) git_wiki_state="ERROR";;
	esac
	
#	echo "gh repo view ${git_repository} --json ${github_data}"
	git_result_json="$(gh repo view ${git_repository} --json ${github_data})"

	# {
	#   "description": "",
	#   "isArchived": false,
	#   "isPrivate": false,
	#   "name": "ansible_module_service_git",
	#   "repositoryTopics": null
	# }

	git_result_mode=$(echo "${git_result_json}" | jq '.isPrivate')
	git_result_state=$(echo "${git_result_json}" | jq '.isArchived')
	git_result_label=$(echo "${git_result_json}" | jq -rM 'try .repositoryTopics[]|map(.name)|join(" ")')
	git_result_description=$(echo "${git_result_json}" | jq '.description' | sed "s/^ *\"\([^ ].*[^ ]\)\" *$/\1/" )
	git_result_wiki_state=$(echo "${git_result_json}" | jq '.hasWikiEnabled')
	git_result_issue_state=$(echo "${git_result_json}" | jq '.hasIssuesEnabled')
	git_result_project_state=$(echo "${git_result_json}" | jq '.hasProjectsEnabled')

	echo "${git_repository}:"

	if [ "${git_mode}" != "${git_result_mode}" ]
	then
		echo "  => Aenderung bei git_mode ${git_mode} (war \"${git_result_mode}\")"
	fi
	if [ "${git_state}" != "${git_result_state}" ]
	then
		echo "  => Aenderung bei git_state ${git_state} (war \"${git_result_state}\")"
	fi
	if [ "${git_issue_state}" != "${git_result_issue_state}" ]
	then
		if [ "${git_issue_state}" = "true" ]
		then
			gh repo edit ${repository_owner}/${git_repository} --enable-issues=true
		else
			gh repo edit ${repository_owner}/${git_repository} --enable-issues=false
		fi
		echo "  => Aenderung bei git_issue_state ${git_issue_state} (war \"${git_result_issue_state}\")"
	fi
	if [ "${git_project_state}" != "${git_result_project_state}" ]
	then
		if [ "${git_project_state}" = "true" ]
		then
			gh repo edit ${repository_owner}/${git_repository} --enable-projects=true
		else
			gh repo edit ${repository_owner}/${git_repository} --enable-projects=false
		fi
		echo "  => Aenderung bei git_project_state ${git_project_state} (war \"${git_result_project_state}\")"
	fi
	if [ "${git_wiki_state}" != "${git_result_wiki_state}" ]
	then
		if [ "${git_project_state}" = "true" ]
		then
			gh repo edit ${repository_owner}/${git_repository} --enable-wiki=true
		else
			gh repo edit ${repository_owner}/${git_repository} --enable-wiki=false
		fi
		echo "  => Aenderung bei git_wiki_state ${git_wiki_state} (war \"${git_result_wiki_state}\")"
	fi

	# Add labels
	for label in ${git_label}
	do
		if echo " ${git_result_label} " | grep -vq " ${label} "
		then
			gh repo edit ${repository_owner}/${git_repository} --add-topic "${label}"
			echo "  => Fuege Label \"${label}\" hinzu"
		fi
	done

	# Remove labels
	for label in ${git_result_label}
	do
		if echo " ${git_label} " | grep -vq " ${label} "
		then
			gh repo edit ${repository_owner}/${git_repository} --remove-topic "${label}"
			echo "  => Entferne Label \"${label}\""
		fi
	done

	if [ "${git_project_description}" != "${git_result_project_description}" ]
	then
		gh repo edit ${repository_owner}/${git_repository} --description "${git_project_description}"
		echo "  => Aenderung bei git_project_description ${git_project_description} (war \"${git_result_project_description}\")"
	fi

	# echo ""
	# echo "--------------------------"
	# echo "         git_repository => ${git_repository}"
	# echo "               git_mode => ${git_mode}: ${git_result_mode}"
	# echo "              git_state => ${git_state}: ${git_result_state}"
	# echo "        git_issue_state => ${git_issue_state}: ${git_result_issue_state}"
	# echo "      git_project_state => ${git_project_state}: ${git_result_project_state}"
	# echo " git_project_wiki_state => ${git_wiki_state}: ${git_result_wiki_state}"
	# echo "              git_label => ${git_label}: ${git_result_label}"
	# echo "        git_description => ${git_description}: ${git_result_description}"
	# echo "--------------------------"
done
