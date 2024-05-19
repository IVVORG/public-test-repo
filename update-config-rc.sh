#!/bin/bash

repoHasRC() {
  # Get tag last value
  org="untillpro"
  repo=$2

  tagvalue=""
  header="Accept: application/vnd.github+json"
  repo_full_name="https://api.github.com/repos/${org}/${repo}/commits/main"
  TAGS=$(curl -s "$repo_full_name/tags" | jq -r '.[].name')
  # Filter tags with the specified prefix and postfix
  TAG_PREFIX="v0."
  TAG_POSTFIX=".1-rc"
  tagvalue=$(echo "$TAGS" | grep "^$TAG_PREFIX.*$TAG_POSTFIX$")

  if [ -z "$tagvalue" ]; then
    echo "Last release candidate tag for repo github.com/${org}/${repo} not found."
    exit 1
  else
    echo "Last release candidate tag for repo github.com/${org}/${repo} is tagvalue"
  fi
  # Remove prefix 'v0.' and postfix '.1-rc'
  stripped_tagvalue=${tagvalue#v0.}
  strdate=${stripped_tagvalue%.1-rc}

  # Print the result
  echo "The last rc tag date is: $strdate"
  reptag="created"

  pfound=0
  while read -r line; do
    i=$((i+1))
    if [ $pfound -eq 0 ]; then 
      if [[ $line =~ "pack: $pack" ]]; then
  	pfound=1	
      fi 
    else
       if [[ $line =~ "$reptag:" ]]; then
         # Extract the date using grep and sed
         curstrdate=$(echo "$line" | grep -oP '(?<=$reptag:\s*)\d+')
         curdt=$(date -d "${curstrdate:0:8} ${curstrdate:8:2}:${curstrdate:10:2}" +"%s")
         newdt=$(date -d "${strdate:0:8} ${strdate:8:2}:${strdate:10:2}" +"%s")
         if [ "$newdt" -gt "$curdt" ]; ; then 
           return $newdt
         fi
       fi
    fi
  done < ${stackfile}

  return "1"
}

updateSync() {
  reptag="created"
  packfound=0
  while read -r line; do
    i=$((i+1))
    if [ $packfound -eq 0 ]; then 
     if [[ $line =~ "pack: $pack" ]]; then
  	packfound=1	
     fi 
    else
       if [[ $line =~ "$reptag:" ]]; then
       # Extract the date using grep and sed
         sed -i "${i}s/.*$reptag.*/      $reptag: $tagvalue/" ${stackfile}
         break
       fi
    fi
  done < ${stackfile}
}

stack="rc"
stackfile="./airs-config-sync/stacks/$stack/stack.yml"
if [ ! -f "$stackfile"  ]
then
    echo "File $stackfile not found "
    exit 1
fi
bp3tag=$(repoHasRC "airs-bp3" "bp3")
if [[ $bp3tag == "1" ]]; then
    echo "New rc tag for airs-bp3 does not exist"
    exit 1
fi
botag=$(repoHasRC "airc-backoffice2" "resellerportal")
if [[ $botag == "1" ]]; then
    echo "New rc tag for airc-backoffice2 does not exist"
    exit 1
fi
portaltag=$(repoHasRC "web-portals" "resellerportal")
if [[ $portaltag == "1" ]]; then
    echo "New rc tag for resellerportal does not exist"
    exit 1
fi
portaltag=$(repoHasRC "web-portals" "paymentsportal")
if [[ $portaltag == "1" ]]; then
    echo "New rc tag for paymentsportal does not exist"
    exit 1
fi

updateSync $bp3tag
updateSync $botag
updateSync $portaltag


