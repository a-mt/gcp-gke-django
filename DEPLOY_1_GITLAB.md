
## Setup Gitlb

- Activate the CI/CD menu  
  Settings > General > Visibility, project features, permissions

  - Check CI/CD
  - Check container registry
  - Save

- Update the default settings  
  Settings > CI/CD

  - Auto DevOps > Uncheck > Save
  - Runner > Uncheck "Enable instance runners for this project"

- Update the old images deletion policy
  - Settings > Packages & registries > Clean up image images
  - Enable
  - Run cleanup: every week
  - Remove these tags
    - Older than: 30 days
    - Remove tags matching: .* (latest is always kept)

- Create secrets  
  Settings > CI/CD > Variables

  ```
  DOCKER_CREDENTIALS={ "type": "service_account", ... (as file)
  DOCKER_REGISTRY=us-west1-docker.pkg.dev
  DOCKER_REPOSITORY=django-gke-420513/test-gke-repo

  KUBE_CLUSTER=https://35.203.177.212
  KUBE_CA=-----BEGIN ... (as file)
  KUBE_TOKEN=ya29.c.c0A...
  ```

  ``` bash
  $ terraform output -raw cicd_docker_credentials
  $ terraform output -raw kubernetes_cluster_ip

  $ kubectl get secret cicd-token -o yaml
  ```

---

## Using a local Gitlab runner

### Install a runner

* Create a container named "django-runner-gitlab"

  ``` bash
  mkdir runner-gitlab
  cd runner-gitlab

  docker run -d --name django-runner-gitlab --restart unless-stopped \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v /etc/localtime:/etc/localtime:ro \
      -v "$(pwd)/docker_volumes/config":/etc/gitlab-runner \
      gitlab/gitlab-runner:latest
  ```

### Register

* Go to Gitlab: Settings > CI/CD > Project runners  
  In "Set up a project runner for a project": take note of the URL and registration token

* Start your runner

  ``` bash
  docker start django-runner-gitlab
  ```

* Register your runner to Gitlab:  

  ``` bash
  # cd runner-gitlab

  docker run --rm -it -v "$(pwd)"/docker_volumes/config:/etc/gitlab-runner gitlab/gitlab-runner register
  ```
  
  - **Enter the GitLab instance URL**:  
    Use the URL you copied earlier from GitLab

  - **Enter the registration token**:  
    Use the token you copied from Gitlab

  - **Enter a description for the runner**:  
    `YOUR-FIRSTNAME Django` — will help identify your runner in GitLab

  - **Enter tags for the runner**:  
    Take example from the existing runners (ie `docker,deploy`)

  - **Enter optional maintenance note for the runner**:  
    Leave empty

  - **Enter an executor**:  
    `docker`

  - **Enter the default Docker image**:  
    `alpine:latest` — you can change it later in the configs

* Check that your runner is detected and edit it:  
  GitLab > Settings > CI/CD  
  Edit > check "Can run untagged jobs"

* Back in your terminal, stop your container:

  ``` bash
  docker stop django-runner-gitlab
  ```

* Edit the following configs for your runner: `privileged`, `volumes` and `allowed_pull_policies`

  ``` bash
  sudo vim docker_volumes/config/config.toml
  ```
  ``` diff
  concurrent = 1
  check_interval = 0
  shutdown_timeout = 0

  [session_server]
    session_timeout = 1800

  [[runners]]
    name = "Django Gitlab Runner"
    url = "https://gitlab.com/"
    id = 34779655
    token = "xs4D27n1GXrNri1byssm"
    token_obtained_at = 2024-04-15T20:59:36Z
    token_expires_at = 0001-01-01T00:00:00Z
    executor = "docker"
    [runners.cache]
      MaxUploadedArchiveSize = 0
    [runners.docker]
      tls_verify = false
      image = "alpine:latest"
  +   privileged = true 
      disable_entrypoint_overwrite = false
      oom_kill_disable = false
      disable_cache = false
  +   volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]
  +   allowed_pull_policies = ["always", "if-not-present"]
      shm_size = 0
      network_mtu = 0
  ```

### Run

* Once installed and registered, all you have to do is start your runner:

  ``` bash
  docker start django-runner-gitlab
  ```

  (jump back to the "Launching a pipeline" section of the documentation for the rest)

* Once the pipeline is complete, you can simply stop your runner:

  ``` bash
  docker stop django-runner-gitlab
  ```
