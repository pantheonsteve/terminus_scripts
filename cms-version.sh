#!/bin/bash
#example command: ./applyupdates.sh <tag> <environment>

# Exit on error
set -e

# login to terminus
terminus auth:login --machine-token=UuXuPBy6NlMovqCIXsvLEbnyYM3Sqp9nIpETZlX9BuXSu

# Stash org UUID
ORG_UUID="1b50534e-d6d6-458a-9095-878e32b52a33"

# Environment - argument 2
ENV='dev'

# Stash list of all Pantheon sites in the org
PANTHEON_SITES="$(terminus org:site:list -n ${ORG_UUID} --field=Name)"

#Loop over the site names
while read -r PANTHEON_SITE_NAME; do

	#print name of framework and apply as tag
	FRAMEWORK="$(terminus site:info ${PANTHEON_SITE_NAME} --fields=Framework --format=list)"

	#If the site is WordPress
	if [[ ${FRAMEWORK} = "wordpress" ]]
	then
		VERSION="$(terminus remote:wp ${PANTHEON_SITE_NAME}.dev core version)"
		echo "${PANTHEON_SITE_NAME} wordpress ${VERSION}"
			#stash core version
		#VERSION="$(terminus remote:wp ${PANTHEON_SITE_NAME}.dev core version)"

			#tag site with name of framework and core version
	#	terminus tag:add ${PANTHEON_SITE_NAME} ${ORG_UUID} "${FRAMEWORK} ${VERSION}"

	#else if framework is Drupal 8
	elif [[ ${FRAMEWORK} = "drupal8" ]]
	then
		VERSION="$(terminus remote:drush ${PANTHEON_SITE_NAME}.dev -- core:status --field='Drupal version')"
		echo "${PANTHEON_SITE_NAME} drupal ${VERSION}"
		#stash core version
	#	VERSION="$(terminus remote:drush ${PANTHEON_SITE_NAME}.dev -- core:status --field='Drupal version')"
		#tag site with name of framework and core version
	#	terminus tag:add ${PANTHEON_SITE_NAME} ${ORG_UUID} "Drupal ${VERSION}"
	else
		echo 'no framework found'
	fi

done <<< "$PANTHEON_SITES"
