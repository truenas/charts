#!/bin/bash

is_semver() {
  if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    return 0
  else
    return 1
  fi
}

is_autodeploy() {
  if [[ -z "${AUTO_DEPLOY_TAG_REGEX}" ]]; then
    return 1
  elif [[ $1 =~ ${AUTO_DEPLOY_TAG_REGEX} ]]; then
    return 0
  else
    return 1
  fi
}

CNG_REGISTRY=${CNG_REGISTRY:-"registry.gitlab.com/gitlab-org/build/cng"}

GITLAB_VERSION=$(awk '/^appVersion:/ {print $2}' Chart.yaml)
if [ "${GITLAB_VERSION}" == "master" || "${GITLAB_VERSION}" == "main" ]; then
  echo "Chart specifies master or main as GitLab version. Hence not waiting for images."
  exit 0
elif is_autodeploy "${GITLAB_VERSION}"; then
  # if it's auto-deploy tag, we use the slug of the tag because auto-deploy tag
  # format is invalid for docker image tag. We also do not prepend a v.
  # We also check for the existence in dev registry.
  wait_on_version=$(echo $GITLAB_VERSION | tr ".+" "-")
  CNG_REGISTRY="dev.gitlab.org:5005/gitlab/charts/components/images"
elif is_semver "${GITLAB_VERSION}"; then
  # if it's semver, we are using a releasable tag, and that tag will have a v prepended
  wait_on_version="v${GITLAB_VERSION}"
else
  # if it's not semver, no v will be prepended
  wait_on_version=${GITLAB_VERSION}
fi

#TODO: Get all the components and their corresponding versions
components=(gitlab-rails-ee gitlab-webservice-ee gitlab-workhorse-ee gitlab-sidekiq-ee gitlab-toolbox-ee)

# ${CNG_REGISTRY%%/*} will get registry domain from the entire path. It
# essentially says "delete the longest substring starting with a forward slash
# from the end of the CNG_REGISTRY variable"
docker login -u ${CNG_REGISTRY_USERNAME:-gitlab-ci-token} -p ${CNG_REGISTRY_PASSWORD:-$CI_JOB_TOKEN} ${CNG_REGISTRY%%/*}

for component in "${components[@]}"; do
  image="${CNG_REGISTRY}/${component}:${wait_on_version}"
  echo -n "Waiting for ${image}: "
  while ! $(DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "${image}" > /dev/null 2>&1 ) ; do
    echo -n ".";
    sleep 1m;
  done
  echo "Found"
done
