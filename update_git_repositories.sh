#! /bin/sh
list_directory=repository_list
list_file_markup=repositories.md
list_file_json=repositories.json
github_data="name,isPrivate,isArchived,repositoryTopics,description"
entries_markupfile=$(expr $(wc -l ${list_directory}/${list_file_markup} | cut -f 1 -d " ") - 2)

cat ${list_directory}/${list_file_markup} | tail -${entries_markupfile} | while read LINE;
do
	git_repository="$(echo "${LINE}" | cut -f 1 -d "|")"
	git_mode="$(echo "${LINE}" | cut -f 2 -d "|")"
	git_state="$(echo "${LINE}" | cut -f 3 -d "|")"
	git_label="$(echo "${LINE}" | cut -f 4 -d "|" | sed "s/,/ /g")"
	git_description="$(echo "${LINE}" | cut -f 5 -d "|")"

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
done
