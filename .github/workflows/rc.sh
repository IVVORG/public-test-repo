#!/bin/bash

# Check if the parameter is provided and valid
if [[ $# -ne 2 ]] ; then
    echo "Error: Invalid argument. Please provide 'org' and 'repo' as an argument."
    exit 1
fi

git clone https://github.com/$org/$repo repo
cd repo

# Set branch names based on parameter
new_branch="rc"
source_branch="main"
git clone https://github.com/voedger/voedger vg

# Ensure the source branch exists before attempting to copy
if ! git show-ref --verify --quiet refs/heads/$source_branch; then
    echo "Source branch '$source_branch' does not exist."
    exit 1
fi

# Delete the old branch if it exists
if git branch -r | grep -qE "origin/$new_branch$"; then
    git push origin --delete $new_branch
    echo "Deleted branch '$new_branch'."
fi

# Create new branch from the source branch
git fetch origin
git checkout $sha
git switch -c $new_branch
git push -u origin $new_branch
cd ..

echo "Branch 'github.com/$org/$repo $new_branch' has been created from 'github.com/$org/$repo $source_branch' and pushed to origin."
