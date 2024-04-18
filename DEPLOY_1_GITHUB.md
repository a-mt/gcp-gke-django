Configuration file: .github/workflows/cicd.yml

## Setup Github

- Create secrets  
  Settings > Security: Secrets and variables > Actions > 

  - Secrets: New repository secret

    ```
    DOCKER_CREDENTIALS={  "type": "service_account...

    KUBE_CA_DATA=-----BEGIN ...
    KUBE_TOKEN=ya29.c.c0A...
    ```

  - Variables: New repository variable

    ```
    DOCKER_REGISTRY=us-west1-docker.pkg.dev
    DOCKER_REPOSITORY=test-gke-419405/test-gke-repo

    KUBE_CLUSTER=https://35.203.177.212
    ```

---

## Using a local Github runner

* Settings > actions > runners > new self-hosted runner

  ![](https://i.imgur.com/aG51mlB.png)

* Create the Dockerfile  
  Note we're setting up the container to use docker-in-docker with the host's Docker  
  Alternative: [install docker in the image](https://github.com/myoung34/docker-github-actions-runner)

  ``` bash
  $ mkdir runner-github
  $ cd runner-github

  # Create docker-compose.yml with the appropriate version
  # Copy the command in Github's "download" section
  $ curl="curl -o actions-runner-linux-x64-2.315.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.315.0/actions-runner-linux-x64-2.315.0.tar.gz"

  $ version=$([[ "${curl##*-}" =~ (\.?[0-9])* ]] && echo $BASH_REMATCH)
  $ echo $version
  2.315.0

  $ docker_group=$(getent group docker | cut -d: -f3)
  $ echo $docker_group
  998

  cat <<EOT > docker-compose.yml
  version: '3'

  services:
    runner:
      build:
        context: .
        dockerfile: Dockerfile
        args:
          RUNNER_VERSION: ${version}
          DOCKER_GROUP: ${docker_group}
      restart: "no"
      volumes:
        - volume_runner:/home/runner/actions-runner
        - /usr/bin/docker:/usr/bin/docker
        - /var/run/docker.sock:/var/run/docker.sock
      privileged: true

  volumes:
    volume_runner:
  EOT

  # Create Dockerfile as-is
  cat <<'EOT' > Dockerfile
  # Source: https://dev.to/pwd9000/create-a-docker-based-self-hosted-github-runner-linux-container-48dh
  FROM ubuntu:20.04

  #input GitHub runner version argument
  ARG RUNNER_VERSION
  ARG DOCKER_GROUP

  LABEL RunnerVersion=${RUNNER_VERSION}
  LABEL DockerGroup=${DOCKER_GROUP}

  ENV DEBIAN_FRONTEND=noninteractive

  # Install dependencies
  RUN apt-get update -y \
      && apt-get upgrade -y \
      && apt-get install -y --no-install-recommends \
      curl nodejs wget unzip vim git  build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

  # Add non-sudo user
  RUN groupadd docker -g ${DOCKER_GROUP} \
      && useradd -m runner -G docker -s /bin/bash

  WORKDIR /home/runner/actions-runner

  # Download & install runner
  RUN curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
      && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
      && rm ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
  RUN /home/runner/actions-runner/bin/installdependencies.sh

  # Set up runtime
  RUN chown -R runner: /home/runner
  USER runner

  CMD ["./run.sh"]
  EOT
  ```

* Build and launch

  ``` bash
  # Build the image
  docker-compose build

  # Copy the command in Github's "configure" section
  docker-compose run runner ./config.sh --url https://github.com/a-mt/gcp-gke-django --token AAIK6BREEMCZLYP23CIDL7LGD6H24

  # Run
  docker-compose up
  ```

  If your config.sh gives you "Http response code: NotFound from 'POST https://api.github.com/actions/runner-registration'": the token has expired, refresh the "new self-hosted runner" page to get a new token

* Check that your runner is listed in the runners list and is "idle":  
  Settings > runners
