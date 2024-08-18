#!/bin/bash

# Check if the parameter is provided and valid
if [[ $# -ne 1 ]] || [[ ! "$1" =~ ^(rc|r)$ ]]; then
    echo "Error: Invalid argument. Please provide 'rc' or 'r' as an argument."
    exit 1
fi

# Set branch names based on parameter
if [ "$1" == "rc" ]; then
    old_branch="rc"
    new_branch="rc"
    source_branch="main"
    git clone https://github.com/IVVORG/public-test-repo vg
elif [ "$1" == "r" ]; then
    old_branch="release"
    new_branch="release"
    source_branch="rc"
    git clone -b rc https://github.com/IVVORG/public-test-repo vg
fi

# Navigate to your repository directory

cd vg

# Ensure the source branch exists before attempting to copy
if ! git show-ref --verify --quiet refs/heads/$source_branch; then
    echo "Source branch '$source_branch' does not exist."
    exit 1
fi

# Delete the old branch if it exists
if git show-ref --verify --quiet refs/heads/$old_branch; then
    git branch -D $old_branch
    echo "Deleted branch '$old_branch'."
else
    echo "Branch '$old_branch' does not exist. Skipping delete step."
fi

# Create new branch from the source branch
git fetch origin
git checkout $source_branch
git pull origin $source_branch
git checkout -b $new_branch
git push -u origin $new_branch

echo "Branch '$new_branch' has been created from '$source_branch' and pushed to origin."

