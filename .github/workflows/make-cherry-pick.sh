#!/bin/bash

# The input is a comma-separated list of commit hashes
echo "Starting checrry-pick..."
if [ -z "$branch" ];  then
  echo "Branch is not defined"
  exit 1
fi
git checkout -b $branch
commit_hashes_arr="$commit_list"
for word in $commit_hashes_arr; do
  # Append word to the list
  commit_hashes="$commit_hashes $word"
done
echo "commit_hashes: $commit_hashes"

echo $(git branch --show-current)
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

# Process each sorted commit hash separately
for commit in $sorted_commits; do
    echo "$commit"
done

# Now, you can use sorted_commits array as needed
echo "Sorted commits:"
printf "%s\n" "${sorted_commits[@]}"
# Loop through the array and cherry-pick each commit from the "main" branch
for commit_hash in "${sorted_commits[@]}"; do
    echo "Cherry-picking commit $commit_hash from main to rc..."
    echo $(git show -s --format=%ci $commit_hash) $commit_hash	
    commit_hash=$(echo $commit_hash | tr -d ' ')
    git cherry-pick "$commit_hash" || {
        echo "Error cherry-picking commit $commit_hash. Aborting."
        exit 1
    }
    git push origin $rc
done

echo "Cherry-pick completed successfully."
