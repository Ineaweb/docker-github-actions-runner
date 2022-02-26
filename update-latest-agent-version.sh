#!/bin/bash
set -e
echo "coucou" 
latest=$(cat ./latest-agent-version)
echo "$latest" 

shopt -s globstar
for file in ./linux/**/releases; do
    # overwrite target
    echo "$latest" > $file
    # appent to target
    # echo "$latest" > $file
done

for file in ./windows/**/releases; do
    # overwrite target
    echo "$latest" > $file
    # appent to target
    # echo "$latest" > $file
done

# Write the latest version number to the latest tag
sed -i -E "s/[0-9]*\.[0-9]*\.[0-9]*/$latest/g" ./linux/latest.tag