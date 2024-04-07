#!/bin/bash

# Check if a commit hash list was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <comma-separated list of commit hashes>"
    exit 1
fi

# Split the comma-separated list into an array of commit hashes
IFS=',' read -r -a commit_hashes <<< "$1"

# Checkout the "rc" branch
git checkout rc || exit

# Loop through the array and cherry-pick each commit from the "main" branch
for commit_hash in "${commit_hashes[@]}"; do
    echo "Cherry-picking commit $commit_hash from main to rc..."
    git cherry-pick "$commit_hash" || {
        echo "Error cherry-picking commit $commit_hash. Aborting."
        exit 1
    }
done

echo "Cherry-pick completed successfully."
