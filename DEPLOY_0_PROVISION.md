
## GCP Setup

* Enable the following APIs:

  - Service accounts & IAM roles:
    - Identity and Access Management (IAM) API
    - Cloud Resource Manager API

    ``` bash
    $ gcloud services enable iam.googleapis.com cloudresourcemanager.googleapis.com
    ```

  - Kubernetes:
    - Cloud Deployment Manager V2 API
    - Kubernetes Engine API
    - Compute Engine API

    ``` bash
    $ gcloud services enable deploymentmanager.googleapis.com container.googleapis.com compute.googleapis.com
    ```

  - Docker Registry:
    - Artifact Registry API

    ``` bash
    $ gcloud services enable artifactregistry.googleapis.com
    ```

  - Cloud SQL:
    - Cloud SQL
    - Cloud SQL Admin

    ``` bash
    $ gcloud services enable sql-component.googleapis.com sqladmin.googleapis.com
    ```

  - Cloud DNS:

    ``` bash
    $ gcloud services enable dns.googleapis.com
    ```

## Setup your domain name

* Buy your domain name on namecheap or other

* Go to [Networking: Network services > Cloud DNS](https://console.cloud.google.com/net-services/dns/zones) > create zone

  Zone name: gke-zone
  DNS name: example-domain.com

* On the "NS" line, column "routing policy": toggle the full cell content  
  This will list the nameservers associated to our zone

  ```
  ns-cloud-d1.googledomains.com.
  ns-cloud-d2.googledomains.com.
  ns-cloud-d3.googledomains.com.
  ns-cloud-d4.googledomains.com. 
  ```

* On namecheap: Domain > Nameservers > Custom DNS  
  Update the nameservers with Google's nameservers (and save)

## Provision the infra
 
* Launch terraform

  ``` bash
  $ cd infra

  $ terraform init
  $ terraform plan
  $ terraform apply
  ```

  Duration:
  - Cloud SQL: 10 min  
  - Kubernetes: 6 min
  - Docker registry: <1 min

## Access Cloud SQL locally

* Retrieve the credentials

  ``` bash
  $ cd infra

  $ terraform output -raw postgres_env_vars > ../env_vars/cloudsql.env
  $ terraform output -raw postgres_connection_json_key | base64 -d > ../env_vars/cloudsql_creds.json
  ```

* Launch the project  
  This will initialize the database

  ``` bash
  $ cd ..
  $ docker-compose -f docker-compose.full.yml up
  ```

## Access the docker registry locally

* Retrieve the credentials

  ``` bash
  $ cd infra

  $ DOCKER_HOSTNAME=$(terraform output -raw docker_registry_hostname)
  $ echo $DOCKER_HOSTNAME
  us-west1-docker.pkg.dev

  $ DOCKER_AUTH=$(terraform output -raw docker_registry_write_json_key)
  $ echo $DOCKER_AUTH
  ewogICJ0eX...

  $ GOOGLE_APPLICATION_CREDENTIALS=$(echo $DOCKER_AUTH | base64 -d | tr -s '\n' ' ')
  $ echo $GOOGLE_APPLICATION_CREDENTIALS
  { "type": "service_account", "project_id": "test-gke-419405", "private_key_id": ...
  ```

* Authenticate

  ``` bash
  $ echo "$GOOGLE_APPLICATION_CREDENTIALS" | docker login -u _json_key --password-stdin https://$DOCKER_HOSTNAME
  WARNING! Your password will be stored unencrypted in /home/aurelie/.docker/config.json.
  Configure a credential helper to remove this warning. See
  https://docs.docker.com/engine/reference/commandline/login/#credentials-store

  Login Succeeded
  ```
  ``` bash
  $ DOCKER_REPOSITORY=$(terraform output -raw docker_registry_repository_url)
  $ echo $DOCKER_REPOSITORY
  us-west1-docker.pkg.dev/test-gke-419405/test-gke-repo-2
  ```

* Build the image

  ``` bash
  $ cd ..
  $ docker-compose -f docker-compose.full.yml build
  $ IMAGE_NAME=django
  ```

* Push your image

  ``` bash
  $ docker tag "$IMAGE_NAME:latest" "$DOCKER_REPOSITORY/$IMAGE_NAME:latest"
  $ docker push !$
  ```

## Access Kubernetes locally

* Retrieve the credentials

  ``` bash
  $ terraform output -raw kubernetes_kubeconfig > kubeconfig
  ```

  Or

  ``` bash
  $ chmod + x get-kubeconfig.sh
  $ ./get-kubeconfig.sh
  ```

* To use as default:

  ``` bash
  $ BACKUP=~/.kube/config.bak.$(date "+%s"); cp ~/.kube/config $BACKUP && echo Saved to $BACKUP
  $ cp kubeconfig ~/.kube/config
  ```

* Check that you have access to the cluster

  ``` bash
  $ kubectl get nodes
  ```

## Test a deployment

* Create values.yaml

  ``` bash
  $ cd infra

  $ LOAD_BALANCER_IP=$(terraform output -raw kubernetes_ingress_ipv4_address)
  $ DATABASE_CONNECTION_NAME=$(terraform output -raw postgres_connection_name)

  $ cat <<EOT > ../k8s/values.yaml
  loadBalancerIP: $LOAD_BALANCER_IP
  databaseConnectionName: $DATABASE_CONNECTION_NAME
  image: $DOCKER_REPOSITORY/django:latest
  EOT

  $ cd ..
  ```

* Create secrets

  ``` bash
  $ kubectl create secret generic cloudsql --from-env-file=../env_vars/cloudsql.env
  $ kubectl create secret generic cloudsql-oauth-credentials --from-file=credentials.json=../env_vars/cloudsql_creds.json
  ```

* Deploy the app

  ``` bash
  $ helm upgrade django ./k8s --install --values=./k8s/values.yaml
  NAME: django
  LAST DEPLOYED: Sun Apr  7 16:21:08 2024
  NAMESPACE: default
  STATUS: deployed
  REVISION: 1
  TEST SUITE: None

  $ kubectl get pod -w
  NAME                      READY   STATUS    RESTARTS   AGE
  webapp-5574bd84b6-bfmfw   2/2     Running   0          7s
  webapp-5574bd84b6-j7nmr   2/2     Running   0          5s
  webapp-5574bd84b6-jrqx8   2/2     Running   0          9s

  $ $ kubectl get svc -w
  NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
  kubernetes   ClusterIP      10.76.176.1    <none>        443/TCP        69s
  webapp       LoadBalancer   10.76.182.49   <pending>     80:31029/TCP   18s
  webapp       LoadBalancer   10.76.182.49   35.185.194.193   80:31029/TCP   40s

  $ curl 35.185.194.193
  {"env": "prod", "debug": false}
  ```

* Check the DNS is working

  ``` bash
  $ ping api.a-mt.shop
  PING api.a-mt.shop (35.185.194.193) 56(84) bytes of data.
  64 bytes from 193.194.185.35.bc.googleusercontent.com (35.185.194.193): icmp_seq=1 ttl=101 time=276 ms
  64 bytes from 193.194.185.35.bc.googleusercontent.com (35.185.194.193): icmp_seq=2 ttl=101 time=196 ms
  ^C
  --- api.a-mt.shop ping statistics ---
  2 packets transmitted, 2 received, 0% packet loss, time 1001ms
  rtt min/avg/max/mdev = 195.542/235.736/275.931/40.194 ms

  $ curl api.a-mt.shop
  {"env": "prod", "debug": false}
  ```

* Note: to list images

  ``` bash
  gcloud artifacts docker images list $DOCKER_REPOSITORY --format="flattened(package)"
  ```
