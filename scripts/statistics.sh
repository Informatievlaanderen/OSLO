#!/bin/bash

ROOTDIR=$1

# Fetch the content from the URL
content=$(curl -s "https://raw.githubusercontent.com/Informatievlaanderen/data.vlaanderen.be-statistics/dev4.0/root.stat")

TOTAL_TERMS=$(echo "$content" | jq -r '.totalterms')

echo "$TOTAL_TERMS"

# Query certain keys and concatenate them into a JSON object
uniqueContributors=$(echo "$content" | jq -r '(.authors | tonumber) + (.editors | tonumber) + (.contributors | tonumber) + (.participants | tonumber)')
json=$(echo "$content" | jq -r --argjson uc "$uniqueContributors" '{uniqueContributors: $uc}')

uniqueAffiliations=$(echo "$content" | jq -r '.totalorganisations | tonumber')
json=$(echo "$json" | jq -r --argjson to "$uniqueAffiliations" '. + {uniqueAffiliations: $to}')

# Add other keys
classes=$(echo "$content" | jq -r '.classes | tonumber')
json=$(echo "$json" | jq -r --argjson cl "$classes" '. + {classes: $cl}')

properties=$(echo "$content" | jq -r '.properties | tonumber')
json=$(echo "$json" | jq -r --argjson pr "$properties" '. + {properties: $pr}')

externalClasses=$(echo "$content" | jq -r '.externalclasses | tonumber')
json=$(echo "$json" | jq -r --argjson ec "$externalClasses" '. + {externalClasses: $ec}')

externalProperties=$(echo "$content" | jq -r '.externalproperties | tonumber')
json=$(echo "$json" | jq -r --argjson ep "$externalProperties" '. + {externalProperties: $ep}')

totalTerms=$(echo "$content" | jq -r '.totalterms | tonumber')
json=$(echo "$json" | jq -r --argjson tt "$totalTerms" '. + {totalTerms: $tt}')

# Use jq to count the standards based on their status
totalKandidaat=$(echo "$content" | jq '[.specifications[] | select(.status == "https://data.vlaanderen.be/id/concept/StandaardStatus/KandidaatStandaard") | .specifications] | add // 0')
totalOntwerp=$(echo "$content" | jq '[.specifications[] | select(.status == "https://data.vlaanderen.be/id/concept/StandaardStatus/OntwerpStandaard") | .specifications] | add // 0')
totalErkend=$(echo "$content" | jq '[.specifications[] | select(.status == "https://data.vlaanderen.be/id/concept/StandaardStatus/ErkendeStandaard") | .specifications] | add // 0')
totalZonder=$(echo "$content" | jq '[.specifications[] | select(.status == "https://data.vlaanderen.be/id/concept/StandaardStatus/ZonderStatus") | .specifications] | add // 0')

# Print the counts
echo "KandidaatStandaard: $totalKandidaat"
echo "OntwerpStandaard: $totalOntwerp"
echo "ErkendeStandaard: $totalErkend"
echo "ZonderStatus: $totalZonder"

# Add the counts to the JSON
json=$(echo "$json" | jq -r --argjson tk "$totalKandidaat" '. + {totalKandidaat: $tk}')
json=$(echo "$json" | jq -r --argjson to "$totalOntwerp" '. + {totalOntwerp: $to}')
json=$(echo "$json" | jq -r --argjson te "$totalErkend" '. + {totalErkend: $te}')
json=$(echo "$json" | jq -r --argjson tz "$totalZonder" '. + {totalZonder: $tz}')

# Output the final JSON
echo "$json"

# Output the final JSON to statistics.json
echo "$json" >"$ROOTDIR/statistics.json"
