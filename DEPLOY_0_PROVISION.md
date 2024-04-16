
## Setup GCP

* Create a project + service account via the [console](https://console.cloud.google.com/)
* Switch to it in your CLI

  ```
  $ gcloud init

  $ gcloud config get project
  Your active configuration is: [test-gke]
  django-gke-420513
  ```

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
    - Cloud DNS
    - Certificate Manager

    ``` bash
    $ gcloud services enable dns.googleapis.com certificatemanager.googleapis.com
    ```

## Setup your domain name

* In the Google cloud console, go to [Networking: Network services > Cloud DNS](https://console.cloud.google.com/net-services/dns/zones) > create zone

  Zone name: gke-zone
  DNS name: example-domain.com

* On the "NS" line, column "routing policy": toggle the full cell content. This will list the nameservers associated to our zone

  ```
  ns-cloud-d1.googledomains.com.
  ns-cloud-d2.googledomains.com.
  ns-cloud-d3.googledomains.com.
  ns-cloud-d4.googledomains.com. 
  ```

* Buy your domain name on namecheap or other.  
  On Namecheap: Domain > Nameservers > Custom DNS  
  Update the nameservers with Google's nameservers (and save)

## Setup Terraform Cloud

* Go to [Terraform Cloud](https://app.terraform.io/)
* Create a CLI-driven workspace

  ```
  test-django-dev
  ```

* Add the following variables:

  ```
  gcp_credentials
  gcp_project_id
  gcp_project_name
  gcp_project_number
  ```

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

---

## Access Cloud SQL locally — initialize the database

* Retrieve the credentials

  ``` bash
  $ cd infra

  $ terraform output -raw postgres_env_vars > ../env_vars/cloudsql.env
  $ terraform output -raw postgres_connection_json_key | base64 -d > ../env_vars/cloudsql_creds.json
  ```

* Build the image and launch the project  
  This will initialize the database

  ``` bash
  $ cd ..
  $ docker-compose -f docker-compose.full.yml build
  $ docker-compose -f docker-compose.full.yml up
  ```

## Access the docker registry locally — send an image

* Authenticate

  ``` bash
  $ cd infra
  $ terraform output -raw cicd_docker_credentials

  # Copy and paste the output from the previous command
  $ DOCKER_REGISTRY='us-west1-docker.pkg.dev';
  $ DOCKER_CREDENTIALS='{  "type": "service_account", ...';

  $ echo "$DOCKER_CREDENTIALS" | docker login -u _json_key --password-stdin https://$DOCKER_REGISTRY
  WARNING! Your password will be stored unencrypted in /home/aurelie/.docker/config.json.
  Configure a credential helper to remove this warning. See
  https://docs.docker.com/engine/reference/commandline/login/#credentials-store

  Login Succeeded
  ```

* Tag & push your image

  ``` bash
  $ DOCKER_REPOSITORY=$(terraform output -raw docker_registry_repository)
  $ echo $DOCKER_REPOSITORY
  test-gke-419405/test-gke-repo-2

  $ IMAGE_NAME=django
  ```
  ``` bash
  $ docker tag "$IMAGE_NAME:latest" "$DOCKER_REGISTRY/$DOCKER_REPOSITORY/$IMAGE_NAME:latest"
  $ docker push !$
  ```

## Access Kubernetes locally — get kubeconfig

* Retrieve the credentials  
  Retrieve the last generated token:

  ``` bash
  $ terraform output -raw kubernetes_kubeconfig > kubeconfig
  ```

  Or, if it expired, create a new one:

  ``` bash
  $ cd ..
  $ chmod + x get-kubeconfig.sh
  $ ./get-kubeconfig.sh
  ```

* To use this kubeconfig as default:

  ``` bash
  $ BACKUP=~/.kube/config.bak.$(date "+%s"); cp ~/.kube/config $BACKUP && echo Saved to $BACKUP
  $ cp kubeconfig ~/.kube/config
  ```

* Check that you have access to the cluster

  ``` bash
  $ kubectl get nodes
  ```

## Launch the first deployment

* Create CloudSQL secrets

  ``` bash
  $ kubectl create secret generic cloudsql --from-env-file=../env_vars/cloudsql.env
  $ kubectl create secret generic cloudsql-oauth-credentials --from-file=credentials.json=../env_vars/cloudsql_creds.json
  ```

* Create Helm values.yaml

  ``` bash
  $ terraform output -raw helm_values > ../k8s/values.yaml

  $ cat !$
  loadBalancerGlobalIPAddress: 34.36.76.231
  loadBalancerGlobalIPName: test-gke-ingress-global-ipv4
  loadBalancerRootDomain: a-mt.shop
  loadBalancerManagedCerticateMap: test-gke-ingress-map-entry
  databaseConnectionName: test-django-419804:us-west1:django-postgres
  image: us-west1-docker.pkg.dev/test-django-419804/test-gke-repo/django:latest
  ```

* Deploy the app

  ``` bash
  $ cd ..

  $ helm upgrade django ./k8s --install --values=./k8s/values.yaml
  Release "django" does not exist. Installing it now.
  NAME: django
  LAST DEPLOYED: Tue Apr  9 07:41:20 2024
  NAMESPACE: default
  STATUS: deployed
  REVISION: 1
  TEST SUITE: None
  ```
  ``` bash
  $ kubectl get pod
  NAME                      READY   STATUS    RESTARTS   AGE
  webapp-58776df459-c5zql   2/2     Running   0          18s
  webapp-58776df459-ls5pd   2/2     Running   0          18s
  webapp-58776df459-xrbj9   2/2     Running   0          18s

  $ kubectl get svc
  NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
  kubernetes   ClusterIP   10.11.144.1     <none>        443/TCP          49m
  webapp       NodePort    10.11.154.207   <none>        8080:31727/TCP   33s
  ```
  ``` bash
  $ kubectl get gateway
  NAME      CLASS                            ADDRESS        PROGRAMMED   AGE
  gateway   gke-l7-global-external-managed   34.36.76.231   True         80s

  # Give it 2-3 min for the Load Balancer to get up and running
  $ curl 34.36.76.23
  curl: (52) Empty reply from server

  $ curl 34.36.76.23
  curl: (56) Recv failure: Connection reset by peer

  $ curl 34.36.76.23
  {"env": "prod", "debug": false}
  ```

* Check the DNS is working

  ``` bash
  $ ping -c1 api.a-mt.shop
  PING api.a-mt.shop (34.36.76.231) 56(84) bytes of data.
  64 bytes from 231.76.36.34.bc.googleusercontent.com (34.36.76.231): icmp_seq=1 ttl=116 time=12.1 ms

  --- api.a-mt.shop ping statistics ---
  1 packets transmitted, 1 received, 0% packet loss, time 0ms
  rtt min/avg/max/mdev = 12.067/12.067/12.067/0.000 ms

  $ curl api.a-mt.shop
  {"env": "prod", "debug": false}

  $ curl https://api.a-mt.shop
  {"env": "prod", "debug": false}
  ```

* Note: to list images

  ``` bash
  gcloud artifacts docker images list $DOCKER_REGISTRY/$DOCKER_REPOSITORY --format="flattened(package)"
  ```

  To list certificate managers

  ``` bash
  gcloud certificate-manager certificates list
  ```

  To list IP addresses

  ``` bash
  gcloud compute addresses list
  ```

  To list load balancers:

  ``` bash
  # HTTPS
  gcloud compute target-https-proxies list

  # HTTP
  gcloud compute target-http-proxies list
  ```

## Test access with our CI/CD service account

``` bash
# Retrieve values
$ KUBE_CLUSTER="https://$(terraform output -raw kubernetes_cluster_ip)";
$ echo $KUBE_CLUSTER
https://35.247.74.19

$ KUBE_CA_DATA=$(terraform output -raw kubernetes_cluster_ca_certificate | base64 -d);
$ echo "$KUBE_CA_DATA"
-----BEGIN CERTIFICATE-----
MIIELTCCApWgAwIBAgIRA...

$ KUBE_TOKEN=$(kubectl get secret cicd-token -o jsonpath='{ .data.token }' | base64 -d);
$ echo $KUBE_TOKEN
eyJhbGciOiJSU...

$ KUBE_CA=/tmp/ca
$ echo "$KUBE_CA_DATA" > $KUBE_CA

# Define context
$ kubectl config set-cluster gke --server="$KUBE_CLUSTER" --embed-certs --certificate-authority $KUBE_CA
$ kubectl config set-credentials pipeline --token="$KUBE_TOKEN"
$ kubectl config set-context primary --user=pipeline --cluster=gke

# Switch context
$ kubectl config current-context
test-gke
$ kubectl config use-context primary
Switched to context "primary".

# Check access
$ kubectl get pod
NAME                      READY   STATUS    RESTARTS   AGE
webapp-76c94cbbf7-gnxlc   2/2     Running   0          14m
webapp-76c94cbbf7-hxmc4   2/2     Running   0          14m
webapp-76c94cbbf7-wmssx   2/2     Running   0          14m
$ kubectl delete pod webapp-76c94cbbf7-gnxlc
Error from server (Forbidden): pods "webapp-76c94cbbf7-gnxlc" is forbidden: User "system:serviceaccount:default:cicd-user" cannot delete resource "pods" in API group "" in the namespace "default"

$ kubectl rollout history deploy/webapp
deployment.apps/webapp 
REVISION  CHANGE-CAUSE
1         <none>
```
