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

## Install pre-commit

Checks code conventions.

Pre-commit sets up git hooks.  
Once added, any scripts defined in `.pre-commit-config.yaml`
runs upon commit and ensures defined conventions are met.

If they aren’t, files might be automatically fixed
or you might have to fix the detected problems yourself.
After fixing the files, add them to the staged diffs and commit.

* Install python 3.12

  ```
  sudo add-apt-repository ppa:deadsnakes/ppa
  sudo apt install python3.12 python3.12-dev

  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
  python3.12 get-pip.py --force-reinstall
  python3.12 -m pip install --upgrade pip
  ```

* Install pre-commit

  ```
  python3.12 -m pip install pre_commit
  ```

* Add the pre-commit hook to git

  ```
  cd django
  python3.12 -m pre_commit uninstall
  python3.12 -m pre_commit install
  ```

  Note: After a rebase or fixing a conflict, you need to run pre-commit manually

  ```
  python3.12 -m pre_commit run --all-files
  ```

## Deployment

- [Provision the infra](DEPLOY_0_PROVISION.md)
- [Set up Gtilab](DEPLOY_1_GITLAB.md)
