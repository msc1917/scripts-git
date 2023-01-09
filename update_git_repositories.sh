#! /bin/sh
list_directory=repository_list
list_file_markup=repositories.md
list_file_json=repositories.json
github_data="name,isPrivate,isArchived,repositoryTopics,description,hasIssuesEnabled,hasProjectsEnabled,hasWikiEnabled"
entries_markupfile=$(expr $(wc -l ${list_directory}/${list_file_markup} | cut -f 1 -d " ") - 2)

cat ${list_directory}/${list_file_markup} | tail -${entries_markupfile} | while read LINE;
do
	git_repository="$(echo "${LINE}" | cut -f 1 -d "|")"
	git_mode="$(echo "${LINE}" | cut -f 2 -d "|")"
	git_state="$(echo "${LINE}" | cut -f 3 -d "|")"
	git_issue_state="$(echo "${LINE}" | cut -f 4 -d "|")"
	git_project_state="$(echo "${LINE}" | cut -f 5 -d "|")"
	git_wiki_state="$(echo "${LINE}" | cut -f 6 -d "|")"
	git_label="$(echo "${LINE}" | cut -f 7 -d "|" | sed "s/,/ /g")"
	git_description="$(echo "${LINE}" | cut -f 8 -d "|")"

	git_result_json="$(gh repo view ${git_repository} --json ${github_data})"

	# {
	#   "description": "",
	#   "isArchived": false,
	#   "isPrivate": false,
	#   "name": "ansible_module_service_git",
	#   "repositoryTopics": null
	# }

	git_result_mode=%(echo "${git_result_json}" | jq '.isPrivate')
	git_result_state=%(echo "${git_result_json}" | jq '.isArchived')
	git_result_label=%(echo "${git_result_json}" | jq -rM '.repositoryTopics.name'
	git_result_description=%(echo "${git_result_json}" | jq '.description')
	git_result_wiki_state=%(echo "${git_result_json}" | jq '.hasWikiEnabled')
	git_result_issue_state=%(echo "${git_result_json}" | jq '.hasIssuesEnabled')
	git_result_project_state=%(echo "${git_result_json}" | jq '.hasProjectsEnabled')
done
