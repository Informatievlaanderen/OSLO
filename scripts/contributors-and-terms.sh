#!/bin/bash

ROOTDIR=$1

# Fetch the content from the URL
content=$(curl -s "https://raw.githubusercontent.com/Informatievlaanderen/data.vlaanderen.be-statistics/production/aggr.stat")

TOTAL_TERMS=$(echo "$content" | jq -r '.totalterms')

echo "$TOTAL_TERMS"

# Query certain keys and concatenate them into a JSON object
uniqueContributors=$(echo "$content" | jq -r '(.authors | tonumber) + (.editors | tonumber) + (.contributors | tonumber) + (.participants | tonumber)')
json=$(echo "$content" | jq -r --argjson uc "$uniqueContributors" '{uniqueContributors: $uc}')

uniqueAffiliations=$(echo "$content" | jq -r '.totalorganisations | tonumber')
json=$(echo "$json" | jq -r --argjson to "$uniqueAffiliations" '. + {uniqueAffiliations: $to}')


# Read the existing content of statistics.json into a variable
existingContent=$(cat "$ROOTDIR/statistics.json")

# Add the new keys to the existing content
updatedContent=$(echo "$existingContent" "$json" | jq -s add)

# Write the updated content back to statistics.json
echo "$updatedContent" >"$ROOTDIR/statistics.json"