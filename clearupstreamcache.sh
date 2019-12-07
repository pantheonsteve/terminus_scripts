#!/bin/bash

# Exit on error
set -e

# login to terminus
terminus auth:login --machine-token=UuXuPBy6NlMovqCIXsvLEbnyYM3Sqp9nIpETZlX9BuXSu

# Stash org UUID
ORG_UUID="f6b78a1f-1a0b-f932-7552-c7721730b717"

# TAG
TAG=$1

# Environment
ENV=$2

# Stash list of all Pantheon sites in the org with the tag "Princeton"
PANTHEON_SITES="$(terminus org:site:list -n ${ORG_UUID} --tag=${TAG} --field=Name)"

#Loop over the site names
while read -r PANTHEON_SITE_NAME; do

	#clear caches for upstream updates
	terminus site:upstream:clear-cache ${PANTHEON_SITE_NAME}
	echo 'Cache cleared for '.${PANTHEON_SITE_NAME}

done <<< "$PANTHEON_SITES"
