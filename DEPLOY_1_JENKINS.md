Configuration file: Jenkinsfile.yml

## Setup Jenkins

### Install plugins

* Manage jenkins > Plugins > Available plugins  

* Docker, Docker Pipeline, Kubernetes
* Multibranch Scan Webhook Trigger (to enable webhooks targeting a multi-branch pipeline)
* Restart

### Create a multi-branch pipeline

* New item > multi-branch pipeline  
* Branch source > Git

  * Project repository: paste the https link of your repo
  * Behaviors: filter by name > dev  
  * Discard old builds:  
    Days to keep old items 365  
    Max # of old items to keep 15

* Build Configuration: by Jenkinsfile
* Save

### Enable webhooks

To automatically trigger the pipeline whenever you push on Github:

* Make sure your Jenkins URL is set up:  
  Manage Jenkins > system > Jenkins URL: http://YOUR_IP:8080

* Go to the multi-branch pipeline configurations (Configure):  
  Scan Multibranch Pipeline Triggers > Scan by webhook > Trigger token: mytoken

* Go to your Github repo:  
  Settings > Webhooks > Add webhook

  - Payload URL: http://YOUR_IP:8080/multibranch-webhook-trigger/invoke?token=mytoken  
    Note, for a classic pipeline that would be http://YOUR_IP:8080/github-webhook/

  - Content type: application/json
  - Just the push event

### Add environment variables

* Manage Jenkins > System > Global properties > Environment variables

  ```
  DOCKER_REGISTRY=us-west1-docker.pkg.dev
  DOCKER_REPOSITORY=test-gke-419405/test-gke-repo

  KUBE_CLUSTER=https://35.203.177.212
  ```

### Add Docker & Kubernetes credentials

* Add credentials for the current pipeline:  
  In the sidebar of the multi-branch pipeline > Credentials > Stores scoped to [PIPELINE_NAME] > [PIPELINE_NAME] > global > Add credentials
  
  ```
  DOCKER_CREDENTIALS={  "type": "service_account... (as file)
  KUBE_CA_DATA=-----BEGIN ... (as file)
  KUBE_TOKEN=ya29.c.c0A...
  ```

---

## Using a local Jenkins runner

* Create the Dockerfile  
  Note we're setting up the container to use docker-in-docker with the host's Docker

  ``` bash
  mkdir runner-jenkins
  cd runner-jenkins

  # Create docker-compose.yml with the appropriate docker group
  $ docker_group=$(getent group docker | cut -d: -f3)
  $ echo $docker_group
  998

  cat <<EOT > docker-compose.yml
  version: '3'

  # https://github.com/jenkinsci/docker/blob/master/README.md#connecting-agents
  services:
    jenkins-server:
      build:
        context: .
        dockerfile: Dockerfile
        args:
          DOCKER_GROUP: ${docker_group}
      restart: "unless-stopped"
      ports:
        - "8080:8080"    # UI
        - "50000:50000"  # master-slave communication
      volumes:
        - jenkins_home:/var/jenkins_home
        - /usr/bin/docker:/usr/bin/docker
        - /var/run/docker.sock:/var/run/docker.sock
      privileged: true
      environment:
        JAVA_OPTS: -Dhudson.DNSMultiCast.disabled=true -Dhudson.udp=-1

  volumes:
    jenkins_home:
  EOT

  # Create Dockerfile as-is
  cat <<'EOT' > Dockerfile
  FROM jenkins/jenkins:lts

  ARG DOCKER_GROUP

  LABEL DockerGroup=${DOCKER_GROUP}

  # Add jenkins to Docker group
  USER root
  RUN groupadd docker -g ${DOCKER_GROUP} \
      && gpasswd -a jenkins docker
  USER jenkins
  EOT
  ```

* Launch Jenkins

  ``` bash
  docker-compose up
  ```

  Go to localhost:8080 (the password is displayed in the console)
