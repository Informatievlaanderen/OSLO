#!/bin/bash

ROOTDIR=$1

# Fetch the content from the URL
content=$(curl -s "https://raw.githubusercontent.com/Informatievlaanderen/data.vlaanderen.be-statistics/production/aggr.stat")

echo "$content"

TOTAL_TERMS=$(echo "$content" | jq -r '.totalterms')

echo "$TOTAL_TERMS"

# Query certain keys and concatenate them into a JSON object
json=$(echo "$content" | jq -r '{uniqueContributors: (.authors | tonumber) + (.editors | tonumber) + (.contributors | tonumber) + (.participants | tonumber)}')
json=$(echo "$content" | jq -r '{: (totalorganisations | tonumber)}')
echo "$json"

# Store the result in statistics.json
echo "$json" >"$ROOTDIR/statistics.json"
