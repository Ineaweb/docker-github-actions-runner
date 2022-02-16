#!/bin/bash
set -e

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.

registry=pmorisseau
name=githubactions-runner

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -r|--registry)
            if [ "$2" ]; then
                registry=$2
                echo "Registry: '$registry'"
                shift
            else
                die 'ERROR: "--registry" requires a non-empty option argument.'
            fi
            ;;
        -n|--name)
            if [ "$2" ]; then
                name=$2
                echo "Name: '$name'"
                shift
            else
                die 'ERROR: "--name" requires a non-empty option argument.'
            fi
            ;;
        --)                     # End of all options.
            shift
            break
            ;;
        *)                      # unknown option
            POSITIONAL+=("$1")  # save it in an array for later
            shift               # past argument
            ;;
    esac

    shift
done
set -- "${POSITIONAL[@]}"       # restore positional parameters

cd "$(dirname "$0")"

while read -r dir; do
  docker push "$registry/$name:${dir//\//-}"
done < <(./dirs.sh)

# Push latest tagged image if available 
if [ -n "$(docker images -f reference="$registry/$name:latest" -q)" ]; then
  docker push "$registry/$name:latest"
fi
