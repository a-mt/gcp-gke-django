# Getting started with Django on Google Kubernetes Engine

Ref: [django_tutorial](https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/kubernetes_engine/django_tutorial)

* Create a database

  ``` bash
  ENV_VARS=`realpath ../env_vars`

  export $(awk '{print}' $ENV_VARS/cloudsql.env)
  export DATABASE_NAME=polls
  ```
  ``` bash
  INSTANCE_NAME=${DATABASE_CONNECTION_NAME##*:}

  gcloud sql databases create $DATABASE_NAME \
    --instance $INSTANCE_NAME
  ```
  ``` bash
  kubectl create secret generic cloudsql-polls \
    --from-literal="DATABASE_NAME=$DATABASE_NAME" \
    --from-literal="DATABASE_USERNAME=$DATABASE_USERNAME" \
    --from-literal="DATABASE_PASSWORD=$DATABASE_PASSWORD"
  ```

* Start cloud-sql-proxy

  ``` bash
  curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.10.1/cloud-sql-proxy.linux.amd64
  chmod +x cloud-sql-proxy
  ./cloud-sql-proxy --credentials-file $ENV_VARS/cloudsql_creds.json $DATABASE_CONNECTION_NAME
  ```

* Install the dependencies

  ``` bash
  python -m venv venv
  source venv/bin/activate
  pip install --upgrade pip
  pip install -r requirements.txt
  ```

* Initialize the database

  ``` bash
  python manage.py makemigrations
  python manage.py makemigrations polls
  python manage.py migrate
  ```

* Initialize the assets

  ``` bash
  python manage.py collectstatic
  ```

* Launch the project

  ``` bash
  python manage.py runserver 8080
  ```

* Build, tag and push the image

  ``` bash
  PROJECT_ID=${DATABASE_CONNECTION_NAME%%:*}
  docker build -t $DOCKER_REPOSITORY/polls .
  docker push $DOCKER_REPOSITORY/polls
  ```

* Run the app in kubernetes  
  Update polls.yaml: cloud sql connection name + image name

  ``` bash
  echo Connection name: $DATABASE_CONNECTION_NAME
  echo Image polls-app: $DOCKER_REPOSITORY/polls

  kubectl apply -f polls.yaml
  ```

---

* Keeping tabs

  ``` bash
  git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
  cd python-docs-samples/kubernetes_engine/django_tutorial
  ```

  ``` bash
  export DATABASE_NAME=postgres-db
  export DATABASE_USERNAME=postgres-user
  export DATABASE_PASSWORD=postgres-password

  INSTANCE_NAME=django-postgres
  PROJECT_ID=test-gke-419405
  REGION=us-west1

  # Create instance
  gcloud sql instances create $INSTANCE_NAME
      --project $PROJECT_ID
      --database-version $POSTGRES_13 \
      --tier db-f1-micro \
      --region $REGION

  # Create database
  gcloud sql databases create $DATABASE_NAME \
    --instance $INSTANCE_NAME

  # Create user
  gcloud sql users create $DATABASE_USERNAME \
      --instance $INSTANCE_NAME \
      --password $DATABASE_PASSWORD
  ```

  ``` bash
  # Create a GKE cluster
  gcloud container clusters create polls \
    --scopes "https://www.googleapis.com/auth/userinfo.email","cloud-platform" \
    --num-nodes 4 --zone "us-central1-a"

  # Update kubeconfig
  gcloud container clusters get-credentials polls --zone "us-central1-a"

  # Create cloudSQL secrets
  kubectl create secret generic cloudsql-oauth-credentials \
    --from-file=credentials.json="$ENV_VARS/cloudsql_creds.json"

  kubectl create secret generic cloudsql \
    --from-literal="DATABASE_NAME=$DATABASE_NAME" \
    --from-literal="DATABASE_USERNAME=$DATABASE_USERNAME" \
    --from-literal="DATABASE_PASSWORD=$DATABASE_PASSWORD"
  ```

  ``` bash
  # Authenticate docker to the registry
  gcloud auth configure-docker
  ```
