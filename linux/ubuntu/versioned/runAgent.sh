#!/bin/bash
set -e

env_exclude=("ActionsRunner_TOKEN" "ActionsRunner_ENV_EXCLUDE" "ActionsRunner_ENV_INCLUDE" "ActionsRunner_ENV_IGNORE" )
env_include=( )

originalIFS=$IFS
IFS=','
if [ -n "$ActionsRunner_ENV_EXCLUDE" ]; then
  read -a external_exclude <<< ${ActionsRunner_ENV_EXCLUDE%','}
  env_exclude+=( ${external_exclude[@]} )
fi
if [ -n "$ActionsRunner_ENV_INCLUDE" ]; then
  read -a external_include <<< ${ActionsRunner_ENV_INCLUDE%','}
  env_include+=( ${external_include[@]} )
fi
IFS=$originalIFS

if [ -z "$ActionsRunner_URL" ]; then
  echo 1>&2 error: missing ActionsRunner_URL environment variable
  exit 1
fi

if [ -n "$ActionsRunner_AGENT" ]; then
  ActionsRunner_AGENT="$(eval echo "$ActionsRunner_AGENT")"
  export ActionsRunner_AGENT
fi

if [ -n "$ActionsRunner_WORK" ]; then
  ActionsRunner_WORK="$(eval echo "$ActionsRunner_WORK")"
  export ActionsRunner_WORK=
  mkdir -p "$ActionsRunner_WORK"
fi

arg_pool=
if [ -n "$ActionsRunner_POOL" ]; then
  arg_pool="--runnergroup "${ActionsRunner_POOL}""
fi

arg_labels=
if [ -n "$ActionsRunner_LABELS" ]; then
  arg_labels="--labels "${ActionsRunner_LABELS}""
fi

arg_agent_once=
if [ "$ActionsRunner_DISPOSE" = true ]; then
  env_include+=( "Agent.RunOnce=true" )
  arg_agent_once="--ephemeral"
fi

cd /actions-runner/agent

cleanup() {
  # some shells will call EXIT after the INT handler
  trap '' EXIT
  ./bin/Runner.Listener remove --unattended \
    --token "$ActionsRunner_TOKEN"
}

print_message() {
  lightcyan='\033[1;36m'
  nocolor='\033[0m'
  echo -e "${lightcyan}$1${nocolor}"
}

# When there is a old configuration perform a cleanup
if [ -e .agent ]; then
  echo "Removing existing ActionsRunner configuration..."
  cleanup
fi

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
trap 'cleanup; exit 0' EXIT

RUNNER_AGENT_IGNORE=_,MAIL,OLDPWD,PATH,PWD,RUNNER_AGENT_IGNORE,ActionsRunner_AGENT,ActionsRunner_URL,ActionsRunner_TOKEN,ActionsRunner_POOL,ActionsRunner_WORK,ActionsRunner_DISPOSE,ActionsRunner_ENV_IGNORE,DOTNET_CLI_TELEMETRY_OPTOUT,RUNNER_ALLOW_RUNASROOT,DEBIAN_FRONTEND

if [ -n "$ActionsRunner_ENV_IGNORE" ]; then
  RUNNER_AGENT_IGNORE+=",$ActionsRunner_ENV_IGNORE"
fi

export RUNNER_AGENT_IGNORE
export RUNNER_ALLOW_RUNASROOT="1"

print_message "Configure Agent ..."

./config.sh --unattended \
  --name ${ActionsRunner_AGENT:-Agent_$(hostname)} \
  --url $ActionsRunner_URL \
  --token $ActionsRunner_TOKEN \
  ${arg_pool} \
  --work ${ActionsRunner_WORK:-_work} \
  ${arg_agent_once} \
  ${arg_labels} \
  --replace & wait $!

print_message "    Done."

print_message "Starting Agent ..."

# echo "Exclude: ${env_exclude[@]/#/--unset=}"
# echo "Include: ${env_include[@]}"

env ${env_exclude[@]/#/--unset=} "${env_include[@]}" ./run.sh & wait $!
