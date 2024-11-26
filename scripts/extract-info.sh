#!/bin/bash

ROOTDIR=$1
REGISTER=$2
REPODIR=$ROOTDIR/repositories
#FILENAME="/root/project/standaardenregister.json"

ls "$ROOTDIR"

## Constructing file names for description
while IFS= read -r line; do
  REPO_NAME=$(echo "$line" | cut -d ":" -f 1)

  cd "$REPODIR/$REPO_NAME"
  CONFIG_NAME=$(echo "$line" | cut -d ":" -f 2 | cut -d "." -f 1)
  SPEC_NAME=$(jq -r '.naam' "$CONFIG_NAME.json")

  ## Extract information about the files containing the description for the detail page
  DESCRIPTION_NAME=$(jq -r '.beschrijving' "$CONFIG_NAME.json")

  echo "$CONFIG_NAME:$DESCRIPTION_NAME" >>"$ROOTDIR/description-paths.txt"

  #### Constructing file name ####
  SPECIAL_CHARACTERS_REMOVED="${SPEC_NAME//[:&]/}"
  MULTI_SPACE_REMOVED="${SPECIAL_CHARACTERS_REMOVED//  /}"
  SPACE_REPLACED="${MULTI_SPACE_REMOVED// /-}"

  echo "$CONFIG_NAME:$SPACE_REPLACED" >>"$ROOTDIR/filenames.txt"
done <"$ROOTDIR/tmp-register.txt"

## Creating statistics config file
echo "Creating statistics configuration file"
touch "$ROOTDIR/statistics_config.json"
echo "[]" >"$ROOTDIR/statistics_config.json"

## Constructing statistics configuration file
if cat "$REGISTER" | jq -e . >/dev/null 2>&1; then
  for row in $(jq -r '.[] | @base64 ' "$2"); do
    _jq() {
      echo "${row}" | base64 --decode | jq -r "${1}"
    }

    REPOSITORY=$(_jq '.repository')
    THEME_NAME=$(echo "$REPOSITORY" | cut -d '/' -f 5)
    CONFIG=$(_jq '.configuration')

    if [ ! -d "$REPODIR/$THEME_NAME" ]; then
      git clone "$REPOSITORY" "$REPODIR/$THEME_NAME"
    fi

    cd "$REPODIR/$THEME_NAME"
    git checkout standaardenregister

    NAME=$(cat "$CONFIG" | jq -r '.title')
    PUB_DATE=$(cat "$CONFIG" | jq -r ".publicationDate")
    STATUS=$(cat "$CONFIG" | jq -r ".status")

    jq --arg REPOSITORY "$THEME_NAME" --arg NAAM "$NAME" --arg STATUS "$STATUS" --arg PUB_DATE "$PUB_DATE" '. += [{"name": $NAAM, "repository": $REPOSITORY, "status" : $STATUS, "publicationDate" : $PUB_DATE}]' "$ROOTDIR/statistics_config.json" >"$ROOTDIR/statistics_config.json.tmp" && mv "$ROOTDIR/statistics_config.json.tmp" "$ROOTDIR/statistics_config.json"
  done
fi

echo "Done creating statistics configuration file"
cat "$ROOTDIR/statistics_config.json"
