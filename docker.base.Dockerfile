FROM python:3.12.2-slim-bullseye

ENV PYTHONUNBUFFERED=1

# install system dependencies
RUN apt update \
  && apt install -y gettext \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# install app dependencies
ENV APPDIR='/srv'
ENV DJANGODIR='/srv/www'
ENV PRODUCTION=1

WORKDIR $APPDIR
RUN pip3 install --upgrade pip
COPY requirements.txt ./requirements.txt
RUN pip install -r requirements.txt

# setup server runtime
COPY docker-entrypoint.sh .
ENTRYPOINT ["bash", "/srv/docker-entrypoint.sh"]

WORKDIR $DJANGODIR
EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=10s --retries=3 CMD curl --fail http://localhost:8080/healthcheck/api || exit 1

CMD ["./manage.py", "runserver"]

# curl localhost:8080/api/course/
