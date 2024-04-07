## Install

* Prerequisite: install docker & docker-compose

  ``` bash
  docker version
  ```
  ``` bash
  docker-compose version
  # or "docker compose version" if installed via docker-compose-plugin
  ```

* Build the image

  ``` bash
  touch env_vars/local.env
  docker-compose build
  ```

* Initialize the database

  ``` bash
  docker-compose up
  docker-compose exec api bash
  python manage.py migrate
  ```

## Launch

``` bash
docker-compose up
```

* Go to localhost:8080

* Documentation: localhost:8080/swagger

## Deploy

1. [Provision the infra](DEPLOY_0_PROVISION.md)

