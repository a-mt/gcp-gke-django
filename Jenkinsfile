pipeline {
  agent any

  environment {
    CI_PIPELINE = getEnvName(env.BRANCH_NAME)
    CI_IMAGE = "${env.DOCKER_REGISTRY}/${env.DOCKER_REPOSITORY}/django"
    CI_COMMIT_SHA = "${env.GIT_COMMIT}"
    CI_COMMIT_BRANCH = "${env.GIT_BRANCH}"
  }
  stages {
    stage('Infos') {
      steps {
        script {
          env.CI_IMAGE_VERSION = sh(script: 'sha1sum docker.base.Dockerfile requirements.txt | sha1sum | head -c 40', returnStdout: true)
          env.CI_IMAGE_PATH = "${CI_IMAGE}:${env.CI_IMAGE_VERSION}"
        }
        echo "CI_PIPELINE: ${env.CI_PIPELINE}"
        echo "CI_IMAGE_VERSION: $CI_IMAGE_VERSION"
      }
    }
    stage('Build base') {
      steps {
        withCredentials([
          file(credentialsId: 'DOCKER_CREDENTIALS_FILE', variable: 'CREDENTIALS'),
        ]) {
          sh "cat \"$CREDENTIALS\" | docker login -u _json_key --password-stdin https://${env.DOCKER_REGISTRY}"

          sh '''
          if (docker pull "$CI_IMAGE_PATH"); then
            echo "Image $CI_IMAGE_PATH already exists"
          else
            docker build \
              --file docker.base.Dockerfile \
              --build-arg CI_COMMIT_SHA="$CI_COMMIT_SHA" \
              --build-arg CI_COMMIT_BRANCH="$CI_COMMIT_BRANCH" \
              --label "cicd.image_type=base" \
              --label "cicd.image=$CI_IMAGE_VERSION" \
              --label "cicd.ci_commit_sha=$CI_COMMIT_SHA" \
              -t "$CI_IMAGE_PATH" \
              -t "$CI_IMAGE:latest" .
            docker push "$CI_IMAGE_PATH"
            docker push "$CI_IMAGE:latest"
            echo "Image $CI_IMAGE_PATH build"
          fi
          '''
        }
      }
    }
    stage('Pre-commit') {
      agent {
        docker {
          image "${env.CI_IMAGE_PATH}"
          args "-it --entrypoint='' -u root"
        }
      }
      steps {
        sh '''
          apt-get update -qq && apt-get install -qq -y git
          pip install --quiet --upgrade pre-commit
          git config --global --add safe.directory `pwd`
        '''

        echo "Running tests for pipeline $CI_PIPELINE"
        sh 'pre-commit run -v --all-files --show-diff-on-failure'
      }
    }
    stage('Unit tests') {
      agent {
        docker {
          image "${env.CI_IMAGE_PATH}"
          args "-it --entrypoint='' -u root"
        }
      }
      steps {
        dir ('www') {
          sh 'python manage.py test'
        }
      }
    }
    stage('Build full image') {
      steps {
        sh '''
        sed -i "s%./docker.base.Dockerfile%$CI_IMAGE_PATH%" docker.full.Dockerfile

        docker build \
        --file docker.full.Dockerfile \
        --build-arg CI_COMMIT_SHA=$CI_COMMIT_SHA \
        --build-arg CI_COMMIT_BRANCH=$CI_COMMIT_BRANCH \
        --label "cicd.pipeline=$CI_PIPELINE" \
        --label "cicd.image_type=full" \
        --label "cicd.image=$CI_IMAGE_VERSION" \
        --label "cicd.ci_commit_sha=$CI_COMMIT_SHA" \
        -t "$CI_IMAGE/$CI_PIPELINE:$CI_COMMIT_SHA" \
        -t "$CI_IMAGE/$CI_PIPELINE:latest" . && \
        docker push $CI_IMAGE/$CI_PIPELINE:$CI_COMMIT_SHA && \
        docker push $CI_IMAGE/$CI_PIPELINE:latest
        '''
      }
    }
    stage('Deploy') {
      agent {
        docker {
          image "bitnami/kubectl:latest"
          args "-it --entrypoint='' -u root"
        }
      }
      steps {
        withCredentials([
          file(credentialsId: 'KUBE_CA', variable: 'CA'),
          string(credentialsId: 'KUBE_TOKEN', variable: 'TOKEN'),
        ]) {
          sh '''
          # Set credentials
          kubectl config set-cluster gke --server="$KUBE_CLUSTER" --embed-certs --certificate-authority "$CA"
          kubectl config set-credentials pipeline --token="$TOKEN"
          kubectl config set-context primary --user=pipeline --cluster=gke
          kubectl config use-context primary

          # Update image
          kubectl set image deploy/webapp api="$CI_IMAGE/$CI_PIPELINE:$CI_COMMIT_SHA"

          message="version change to $CI_PIPELINE:$CI_COMMIT_SHA"
          kubectl annotate deploy webapp kubernetes.io/change-cause="$message" --overwrite=true
          '''
        }
      }
    }

  }
}

def getEnvName(branchName) {
  if("cicd".equals(branchName)) {
      return "dev";
  }
  println("Branch value error: " + branch)
  currentBuild.getRawBuild().getExecutor().interrupt(Result.FAILURE)
}
