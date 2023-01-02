#! /bin/sh
list_directory=repository_list
list_file=repositories.txt

if [ ! -d ${list_directory} ]
then
	mkdir ${list_directory}
fi

for repository in $(gh repo list -L 200 | cut -f 1)
do
	if grep "^${repository} " ${list_directory}/${list_file}
	then
		echo "${repository} ist in ${list_directory}/${list_file}"
	else
		echo "${repository}    " >> ${list_directory}/${list_file}
	fi