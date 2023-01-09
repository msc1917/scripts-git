#! /bin/sh
list_directory=repository_list
list_file_markup=repositories.md
list_file_json=repositories.json

# Moegliche Datenfelder in Github-CLI
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

github_data="name,isPrivate,isArchived,repositoryTopics,description,hasIssuesEnabled,hasProjectsEnabled,hasWikiEnabled"

gh repo list --json ${github_data} -L 200 > ${list_directory}/${list_file_json}
repository_name_length=10
repository_label_length=10

for repository in $(cat ${list_directory}/${list_file_json} | jq '.[].name')
do
	# echo "${repository} ... ${#repository}/${repository_name_length}"
	if [ ${repository_name_length} -le ${#repository} ]
	then
		repository_name_length=${#repository}
	fi
done

for repository in $(cat ${list_directory}/${list_file_json} | jq -rM ".[] | select(.repositoryTopics!=null).repositoryTopics|map(.name)|join(\",,\")")
do
	# echo "${repository} ... ${#repository}/${repository_label_length}"
	if [ ${repository_label_length} -le ${#repository} ]
	then
		repository_label_length=${#repository}
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
	printf "%-${repository_name_length}s | %-8s | %-8s | %-8s | %-8s | %-8s | %-${repository_label_length}s | %s \n" "Repository" "Modus" "Issue" "Project" "Wiki" "Status" "Labels" "Beschreibung" >> ${list_directory}/${list_file_markup}
	printf "%-${repository_name_length}s | %-8s | %-8s | %-8s | %-8s | %-8s | %-${repository_label_length}s | %s \n" "---" "---" "---" "---" "---" "---" "---" "---" >> ${list_directory}/${list_file_markup}
fi

for repository in $(cat ${list_directory}/${list_file_json} | jq -rM '.[].name')
do
	if grep -q "^${repository} *|" ${list_directory}/${list_file_markup}
	then
		echo "${repository} ist in ${list_directory}/${list_file_markup}"
	else
		repository_json="$(cat ${list_directory}/${list_file_json} | jq -rM ".[]|select(.name==\"${repository}\")")"

		repository_description="$(echo "${repository_json}" | jq -rM ".description")"
		if [ "$(echo "${repository_json}" | jq -rM ".repositoryTopics")" != "null" ]
		then
			repository_labels=$(echo "${repository_json}" | jq -rM '.repositoryTopics|map(.name)|join(", ")')
		else
			repository_labels=""
		fi
		if $(echo "${repository_json}" | jq -rM ".isPrivate")
		then
			repository_mode="Private"
		else
			repository_mode="Public"
		fi
		if $(echo "${repository_json}" | jq -rM ".isArchived")
		then
			repository_state="Archived"
		else
			repository_state="Open"
		fi
		if $(echo "${repository_json}" | jq -rM ".hasIssuesEnabled")
		then
			github_issues_state="Yes"
		else
			github_issues_state="No"
		fi
		if $(echo "${repository_json}" | jq -rM ".hasProjectsEnabled")
		then
			github_project_state="Yes"
		else
			github_project_state="No"
		fi
		if $(echo "${repository_json}" | jq -rM ".hasWikiEnabled")
		then
			github_wiki_state="Yes"
		else
			github_wiki_state="No"
		fi

		printf "%-${repository_name_length}s | %-8s | %-8s | %-8s | %-8s | %-8s | %-${repository_label_length}s | %s\n" "${repository}" "${repository_mode}" "${github_issues_state}" "${github_project_state}" "${github_wiki_state}" "${repository_state}" "${repository_labels}" "${repository_description}" >> ${list_directory}/${list_file_markup}
	fi
done