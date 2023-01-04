#! /bin/sh

if [ "${1}" = "" ]
then
	base_directory=$(basename $(pwd))
else
	base_directory="${1}"
fi

git_namespace="msc1917"

gh repo create "${base_directory}" --private --disable-wiki
git remote add origin git@github.com:${git_namespace}/${base_directory}.git
git branch -M main
git push -u origin --repo=${git_namespace}/${base_directory}.git main