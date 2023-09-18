#!/bin/bash                    

  isNext( ) {
    # Convert the input date string to a Unix timestamp
    input_date=$(date -d "$1" +"%s")

    # Get the current date in Unix timestamp format
    current_date=$(date +"%s")    

    res=0 
    if [ $input_date -eq $current_date ]; then
      res=1
    fi
    echo $res
  }

  # Get milestone list
  milestones=$(gh api repos/${repo}/milestones --jq '.[] | .title')
  for milestone in $milestones; do
    goodml=$(isNext $milestone)
    if [ $goodml -eq 1 ]
#	gh issue edit issueNum --milestone ${milestone} --repo ${repo}
echo "Found: $milestone"
 	exit 0
    fi	
  done
