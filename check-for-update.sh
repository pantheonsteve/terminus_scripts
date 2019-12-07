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

	#clear caches for upstream updates - required to see if an upstream update is available to apply
	terminus site:upstream:clear-cache ${PANTHEON_SITE_NAME}

done <<< "$PANTHEON_SITES"

#Loop over the site names
while read -r PANTHEON_SITE_NAME; do

  #stash a list of tags for a particular site
  TAGS="$(terminus tag:list ${PANTHEON_SITE_NAME} ${ORG_UUID})"

  #Loop over tags
  while read -r PANTHEON_SITE_TAG; do
    #If site is tagged with "No Updates" or "Updates Available," remove those tags

      case ${PANTHEON_SITE_TAG} in

        'No Updates')
          terminus tag:remove ${PANTHEON_SITE_NAME} ${ORG_UUID} 'No Updates'
        ;;

        'Updates Available')
          terminus tag:remove ${PANTHEON_SITE_NAME} ${ORG_UUID} 'Updates Available'
        ;;

      esac

  done <<< "$TAGS"

	#Check Update Status for Upstream updates - is there an update available?
	STATUS=$(terminus upstream:updates:status ${PANTHEON_SITE_NAME}.${ENV})

	#If there are updates available, apply them
	if [[ ${STATUS} = "outdated" ]]
	then
		terminus tag:add ${PANTHEON_SITE_NAME} ${ORG_UUID} 'Updates Available'
	else
		terminus tag:add ${PANTHEON_SITE_NAME} ${ORG_UUID} 'No Updates'
	fi

done <<< "$PANTHEON_SITES"
