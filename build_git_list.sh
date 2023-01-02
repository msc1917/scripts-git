#! /bin/sh
list_directory=repository_list
list_file_markup=repositories.md
list_file_json=repositories.json


# ------------------------------- | ------------------------------- | ------------------------------- | -------------------------------
# assignableUsers                 | codeOfConduct                   | contactLinks                    | createdAt
# defaultBranchRef                | deleteBranchOnMerge             | description                     | diskUsage
# forkCount                       | fundingLinks                    | hasIssuesEnabled                | hasProjectsEnabled
# hasWikiEnabled                  | homepageUrl                     | id                              | isArchived 
# isBlankIssuesEnabled            | isEmpty                         | isFork                          | isInOrganization 
# isMirror                        | isPrivate                       | isSecurityPolicyEnabled         | isTemplate
# isUserConfigurationRepository   | issueTemplates                  | issues                          | labels
# languages                       | latestRelease                   | licenseInfo                     | mentionableUsers
# mergeCommitAllowed              | milestones                      | mirrorUrl                       | name
# nameWithOwner                   | openGraphImageUrl               | owner                           | parent
# primaryLanguage                 | projects                        | pullRequestTemplates            | pullRequests
# pushedAt                        | rebaseMergeAllowed              | repositoryTopics                | securityPolicyUrl
# squashMergeAllowed              | sshUrl                          | stargazerCount                  | templateRepository
# updatedAt                       | url                             | usesCustomOpenGraphImage        | viewerCanAdminister
# viewerDefaultCommitEmail        | viewerDefaultMergeMethod        | viewerHasStarred                | viewerPermission
# viewerPossibleCommitEmails      | viewerSubscription              | watchers                        |
# ------------------------------- | ------------------------------- | ------------------------------- | -------------------------------

gh repo list --json name,isPrivate -L 200 > ${list_directory}/${list_file_json}
repository_name_length=0

for repository in $(cat ${list_directory}/${list_file_json} | jq '.[].name')
do
	# echo "${repository} ... ${#repository}/${repository_name_length}"
	if [ ${repository_name_length} -le ${#repository} ]
	then
		repository_name_length=${#repository}
	fi
done

# repository_name_length=${repository_name_length} + 1

if [ ! -d ${list_directory} ]
then
	echo "Erstelle ${list_directory}."
	mkdir ${list_directory}
fi

if [ ! -f ${list_directory}/${list_file_markup} ]
then
	printf "%-${repository_name_length}s | %-10s | %-20s \n" "Repository" "Modus" "Beschreibung" >> ${list_directory}/${list_file_markup}
	printf "%-${repository_name_length}s | %-10s | %-20s \n" "---" "---" "---" >> ${list_directory}/${list_file_markup}
fi

for repository in $(cat ${list_directory}/${list_file_json} | jq -r '.[].name')
do
	if grep -q "^${repository} *|" ${list_directory}/${list_file_markup}
	then
		echo "${repository} ist in ${list_directory}/${list_file_markup}"
	else
		if $(cat ${list_directory}/${list_file_json} | jq -r ".[]|select(.name==\"${repository}\").isPrivate")
		then
			repository_mode="Private"
		else
			repository_mode="Public"
		fi
		printf "%-${repository_name_length}s | %-10s | \n" "${repository}" "${repository_mode}" >> ${list_directory}/${list_file_markup}
	fi
done