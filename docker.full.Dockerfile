# syntax = devthefuture/dockerfile-x
FROM ./docker.base.Dockerfile

# possible Dockerfile arguments
ARG CI_COMMIT_BRANCH='dev'
ARG CI_COMMIT_TAG='latest'
ARG CI_COMMIT_SHA='latest'

ENV COMMIT_BRANCH=$CI_COMMIT_BRANCH
ENV COMMIT_TAG=$CI_COMMIT_TAG
ENV COMMIT_SHA=$CI_COMMIT_SHA

# install app dependencies
WORKDIR $APPDIR

COPY requirements.full.txt ./requirements.full.txt
RUN pip install -r requirements.full.txt

# copy the code base
COPY www $DJANGODIR

# setup server runtime
ENTRYPOINT ["bash", "/srv/docker-entrypoint.sh", "--migrate"]

CMD [ "gunicorn", \
      "--bind", ":8080", \
      "--workers", "3", \
      "--worker-class", "sync", \
      "--log-level", "info", \
      "--log-file", "-", \
      "--forwarded-allow-ips", "*", \
      "--pid", "gunicorn.pid", \
      "--timeout", "60", \
      "--max-requests", "1000", \
      "wsgi:application" \
]

WORKDIR $DJANGODIR
