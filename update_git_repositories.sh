#! /bin/sh
list_directory=repository_list
list_file_markup=repositories.md
list_file_json=repositories.json
entries_markupfile=$(expr $(wc -l ${list_directory}/${list_file_markup} | cut -f 1 -d " ") - 2)

cat ${list_directory}/${list_file_markup} | tail -${entries_markupfile} | while read LINE;
do
	git_repository="$(echo "${LINE}" | cut -f 1 -d "|")"
	git_mode="$(echo "${LINE}" | cut -f 2 -d "|")"
	git_state="$(echo "${LINE}" | cut -f 3 -d "|")"
	git_label="$(echo "${LINE}" | cut -f 4 -d "|")"
	git_description="$(echo "${LINE}" | cut -f 5 -d "|")"
done
