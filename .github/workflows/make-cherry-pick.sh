#!/bin/bash

# The input is a comma-separated list of commit hashes
echo "Starting checrry-pick..."
if [ -z "$branch" ];  then
  echo "Branch is not defined"
  exit 1
fi
echo "https://github.com/$org/$repo"
git clone -b $branch "https://github.com/$org/$repo" chp || {
   echo "Something wnet wrong with clone branch"
   exit 1
}
cd chp

commit_hashes_arr="$commit_list"
for word in $commit_hashes_arr; do
  # Append word to the list
  commit_hashes="$commit_hashes $word"
done
echo "commit_hashes: $commit_hashes"

rc=$(git branch --show-current)
if [ -z "$rc" ];  then
    echo "Please go to git branch and run script from there"
    exit 1
fi
if [ "$rc" = "main" ];  then
    echo "Please go to git branch and run script from there. It does not in main."
    exit 1
fi

echo "Current branch: $rc"

# Check if commit hashes were provided
if [ -z "$commit_hashes" ]; then
    echo "Usage: $0 <comma-separated list of commit hashes>"
    exit 1
fi


# Initialize a space-separated string to hold sorted commit hashes
sorted_commits=""

# Loop through the hashes, get their commit dates, and sort them
# Capture the sorted hashes into a string variable
sorted_commits=$(for commit in $commit_hashes; do
    # Get the commit date using %ci, output with commit hash
    commit_info=$(git show -s --format=%ci $commit)
    echo "$commit_info $commit"
done | sort | awk '{print $4}')

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
echo "The script directory is: $SCRIPT_DIR"
# Process each sorted commit hash separately
for commit_hash in $sorted_commits; do
    echo "Cherry-picking commit $commit_hash from main to $branch..."
    echo $(git show -s --format=%ci $commit_hash) $commit_hash	
    commit_hash=$(echo $commit_hash | tr -d ' ')
    echo "commiting sha: $commit_hash"
    git cherry-pick "$commit_hash" || {
        echo "Error cherry-picking commit $commit_hash. Aborting."
        exit 1
    }
echo "3"
    git config --local user.email "v.istratenko@dev.untill.com"
echo "31"
    git config --local user.name "upload-robot"
echo "32"
    git push origin $rc
echo "33"
done

echo "Cherry-pick completed successfully."
