#!/bin/bash                    

prlist=$(gh pr list --state open --json number | jq -r '.[].number')
for pr_number in ${prlist}
do
  echo "prname: $prname"
  gh pr merge https://github.com/${repo}/pull/$pr_number --squash --admin
done

