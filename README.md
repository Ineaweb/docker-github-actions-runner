# Github Actions Runner Docker Container

[![Downloads from Docker Hub](https://img.shields.io/docker/pulls/pmorisseau/githubactions-runner.svg)](https://hub.docker.com/r/pmorisseau/githubactions-runner)
[![Stars on Docker Hub](https://img.shields.io/docker/stars/pmorisseau/githubactions-runner.svg)](https://hub.docker.com/r/pmorisseau/githubactions-runner)
[![](https://images.microbadger.com/badges/image/pmorisseau/githubactions-runner.svg)](https://microbadger.com/images/pmorisseau/githubactions-runner)
[![](https://images.microbadger.com/badges/version/pmorisseau/githubactions-runner.svg)](https://microbadger.com/images/pmorisseau/githubactions-runner)

Based on Ubuntu :

[![Build Status](https://dev.azure.com/pmorisseau/ActionsRunnerEphemeralAgentBuilder/_apis/build/status/Ineaweb.docker-github-actions-runner.linux?branchName=main)](https://dev.azure.com/pmorisseau/ActionsRunnerEphemeralAgentBuilder/_build/latest?definitionId=84&branchName=main)

Based on Windows : 

[![Build Status](https://dev.azure.com/pmorisseau/ActionsRunnerEphemeralAgentBuilder/_apis/build/status/Ineaweb.docker-github-actions-runner.windows?branchName=main)](https://dev.azure.com/pmorisseau/ActionsRunnerEphemeralAgentBuilder/_build/latest?definitionId=85&branchName=main)

This is a Docker based project for automatically generating docker images for Github Actions Runner with specified Versions. The resulting Docker images should be used as a base for project specific agents that are customized to the needs for the pipeline in your project.

## How to use these images

Actions Runner agents must be started with account connection information, which is provided through environment variables listet below.

To run the default Actions Runner image for a specific Github repository:

```bash
docker run \
  -e ActionsRunner_URL=<url> \
  -e ActionsRunner_TOKEN=<pat> \
  -it pmorisseau/githubactions-runner
```

Agents can be further configured with additional environment variables:

-   `ActionsRunner_AGENT`: the name of the agent (default: `"$(hostname)"`)
-   `ActionsRunner_POOL`: the name of the agent pool (default: `"Default"`)
-   `ActionsRunner_WORK`: the agent work folder (default: `"_work"`)

The `ActionsRunner_AGENT` and `ActionsRunner_WORK` values are evaluated inside the container as an expression so they can use shell expansions. The `ActionsRunner_AGENT` value is evaluated first, so the `ActionsRunner_WORK` value may reference the expanded `ctionsRunner_AGENT` value.

To run a Github Actions Runner on Ubuntu 18.04 for a specific account with a custom agent name, pool and a volume mapped agent work folder:

```bash
docker run \
  -e ActionsRunner_URL=<url> \
  -e ActionsRunner_TOKEN=<pat> \
  -e ActionsRunner_AGENT='$(hostname)-agent' \
  -e ActionsRunner_POOL=mypool \
  -e ActionsRunner_WORK='/var/azdo/$AZDO_AGENT' \
  -v /var/actionsrunner:/var/actionsrunner \
  -it pmorisseau/githubactions-runner:ubuntu-18.04
```

## Configuration

All the variables below will be ignored by the agent by default and will not be visible as capabilities of the agent

### Required

`ActionsRunner_URL`

The complete url of the Github Repository (e.g. `"https://github.com/Ineaweb/docker-github-actions-runner"`).

#### Authentification with Token (recommended)

`ActionsRunner_TOKEN`

A token for the Github repository that has been given at this scope.

### Optional

#### Environment

`ActionsRunner_AGENT`

The Name of the Agent as it will appear in the agent pool view of Github Actions runners

`ActionsRunner_WORK`

If you want the agent to use an other forlder for his jobs you can specify it here. The default is: `/azdo/agent/_work/`

`ActionsRunner_ENV_IGNORE`

This is a `,` seperated list of environment variables which will be ignored by the agent while scanning for capabilities. This may be usefull if you have avariable used in your dokerfile but do not want it to show up in the capabilities list-

`ActionsRunner_ENV_EXCLUDE`

This is a `,` seperated list of environment variables which will be excludes from the environment the agent is running in. This is usefull for variables with secrets that are not necessary at the runtime of the agent.

`ActionsRunner_ENV_INCLUDE`

This is a `,` seperated list of environment variables which will be added to the environment the agent is running in. For example you can add something like that: `"Agent.Project=Sample Project"`. With this you can use this value in the demands of your job.

#### Behaviour

`ActionsRunner_DISPOSE`

The agent will take only one job and than shut down and deregister itself.

## Development

### Getting Started

> Notice: The preferred Development Environment is Windows with the integrated WSL Bash.

1.  [Download and Install Docker](https://docs.docker.com/docker-for-windows/install/)
2.  If you are on Windows install the Ubuntu Bash ([Windows-Store](https://www.microsoft.com/en-us/p/ubuntu/9nblggh4msv6))
3.  Happy Coding!

### Build

The `update.sh` script generates Dockerfiles from  `*.templates` files.  
In order to build your Dockerimages from the Dockerfiles run `build.sh`.

### Run

To run a container and register it in Azure DevOps run `run.sh`.

Example:

```bash
./run.sh pmorisseau/githubactions-runner:ubuntu-18.04-actionrunners -s https://github.com/Ineaweb/docker-github-actions-runner -n TestAgent01 -p DockerSamples -c -d -i
```

### Contribute

Build your own DockerFiles/Images based on Linux or Windows:

1.  Add a Template File for your variation. In order to do so create a dockerfile.template and a versions file.
2.  Register your Template in `update.sh`, run it in order to generate a Dockerfile
3.  Run `build.sh` to build a dockerimage from all dockerfiles.

## Authors

-   **Kirsten Kluge** - _Initial work_ - [kirkone](https://github.com/kirkone)

See also the list of [contributors](https://github.com/codez-one/docker-azure-pipelines-agent/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

Based on this:

-   [Github Documentation](https://docs.github.com/en/actions/hosting-your-own-runners/adding-self-hosted-runners)
