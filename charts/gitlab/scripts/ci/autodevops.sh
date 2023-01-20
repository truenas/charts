#!/bin/bash

# Auto DevOps variables and functions
[[ "$TRACE" ]] && set -x
export CI_APPLICATION_REPOSITORY=$CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG
export CI_APPLICATION_TAG=$CI_COMMIT_SHA
export CI_CONTAINER_NAME=ci_job_build_${CI_JOB_ID}

# Derive the Helm RELEASE argument from CI_ENVIRONMENT_SLUG
if [[ $CI_ENVIRONMENT_SLUG =~ ^.{3}-review ]]; then
  # if a "review", use $REVIEW_REF_PREFIX$CI_COMMIT_REF_SLUG
  RELEASE_NAME=rvw-${REVIEW_REF_PREFIX}${CI_COMMIT_REF_SLUG}
  # Trim release name to leave room for prefixes/suffixes
  RELEASE_NAME=${RELEASE_NAME:0:30}
  # Trim any hyphens in the suffix
  RELEASE_NAME=${RELEASE_NAME%-}
else
  # otherwise, use CI_ENVIRONMENT_SLUG
  RELEASE_NAME=$CI_ENVIRONMENT_SLUG
fi
export RELEASE_NAME

function previousDeployFailed() {
  set +e
  echo "Checking for previous deployment of $RELEASE_NAME"
  deployment_status=$(helm status $RELEASE_NAME >/dev/null 2>&1)
  status=$?
  # if `status` is `0`, deployment exists, has a status
  if [ $status -eq 0 ]; then
    echo "Previous deployment found, checking status"
    deployment_status=$(helm status $RELEASE_NAME | grep ^STATUS | cut -d' ' -f2)
    echo "Previous deployment state: $deployment_status"
    if [[ "$deployment_status" == "FAILED" || "$deployment_status" == "PENDING_UPGRADE" || "$deployment_status" == "PENDING_INSTALL" ]]; then
      status=0;
    else
      status=1;
    fi
  else
    echo "Previous deployment NOT found."
  fi
  set -e
  return $status
}

function deploy() {
  # Enable / disable KAS based on environment
  local enable_kas=()
  if [[ -n "$KAS_ENABLED" ]]; then
    enable_kas=("--set" "global.kas.enabled=true")
  fi

  # Use the gitlab version from the environment or use stable images when on the stable branch
  gitlab_app_version=$(grep 'appVersion:' Chart.yaml | awk '{ print $2}')
  if [[ -n "${GITLAB_VERSION}" ]]; then
    image_branch=$GITLAB_VERSION
  elif [[ "${CI_COMMIT_BRANCH}" =~ -stable$ ]] && [[ "${gitlab_app_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    image_branch=$(echo "${gitlab_app_version%.*}-stable" | tr '.' '-')
  fi

  gitlab_version_args=()
  if [[ -n "$image_branch" ]]; then
      gitlab_version_args=(
      "--set" "global.gitlabVersion=${image_branch}"
      "--set" "global.certificates.image.tag=${image_branch}"
      "--set" "global.kubectl.image.tag=${image_branch}"
      "--set" "gitlab.gitaly.image.tag=${image_branch}"
      "--set" "gitlab.gitlab-shell.image.tag=${image_branch}"
      "--set" "gitlab.gitlab-exporter.image.tag=${image_branch}"
      "--set" "registry.image.tag=${image_branch}"
    )
  fi

  # Cleanup and previous installs, as FAILED and PENDING_UPGRADE will cause errors with `upgrade`
  if [ "$RELEASE_NAME" != "production" ] && previousDeployFailed ; then
    echo "Deployment in bad state, cleaning up $RELEASE_NAME"
    delete
    cleanup
  fi

  #ROOT_PASSWORD=$(cat /dev/urandom | LC_TYPE=C tr -dc "[:alpha:]" | head -c 16)
  #echo "Generated root login: $ROOT_PASSWORD"
  kubectl create secret generic "${RELEASE_NAME}-gitlab-initial-root-password" --from-literal=password=$ROOT_PASSWORD -o yaml --dry-run | kubectl replace --force -f -

  echo "${REVIEW_APPS_EE_LICENSE}" > /tmp/license.gitlab
  kubectl create secret generic "${RELEASE_NAME}-gitlab-license" --from-file=license=/tmp/license.gitlab -o yaml --dry-run | kubectl replace --force -f -

  # YAML_FILE=""${KUBE_INGRESS_BASE_DOMAIN//\./-}.yaml"

  helm repo add gitlab https://charts.gitlab.io/
  helm repo add jetstack https://charts.jetstack.io
  helm dep update .

  WAIT="--wait --timeout 900s"

  # Only enable Prometheus on `master`
  PROMETHEUS_INSTALL="false"
  if [ "$CI_COMMIT_REF_NAME" == "master" ]; then
    PROMETHEUS_INSTALL="true"
  fi

  # helm's --set argument dislikes special characters, pass them as YAML
  cat << CIYAML > ci.details.yaml
  ci:
    title: |
      ${CI_COMMIT_TITLE}
    sha: "${CI_COMMIT_SHA}"
    branch: "${CI_COMMIT_REF_NAME}"
    job:
      url: "${CI_JOB_URL}"
    pipeline:
      url: "${CI_PIPELINE_URL}"
    environment: "${CI_ENVIRONMENT_SLUG}"
CIYAML

  # configure CI resources, intentionally trimmed.
  cat << CIYAML > ci.scale.yaml
  gitlab:
    webservice:
      minReplicas: 1    # 2
      maxReplicas: 3    # 10
      resources:
        requests:
          cpu: 500m     # 900m
          memory: 1500M # 2.5G
    sidekiq:
      minReplicas: 1    # 1
      maxReplicas: 2    # 10
      resources:
        requests:
          cpu: 500m     # 900m
          memory: 1000M # 2G
    gitlab-shell:
      minReplicas: 1    # 2
      maxReplicas: 2    # 10
    toolbox:
      enabled: true
  nginx-ingress:
    controller:
      replicaCount: 1   # 2
  redis:
    resources:
      requests:
        cpu: 100m
  minio:
    resources:
      requests:
        cpu: 100m
CIYAML

  helm upgrade --install \
    $WAIT \
    -f ci.details.yaml \
    -f ci.scale.yaml \
    --set releaseOverride="$RELEASE_NAME" \
    --set global.image.pullPolicy="Always" \
    --set global.hosts.hostSuffix="$HOST_SUFFIX" \
    --set global.hosts.domain="$KUBE_INGRESS_BASE_DOMAIN" \
    --set global.ingress.annotations."external-dns\.alpha\.kubernetes\.io/ttl"="10" \
    --set global.ingress.tls.secretName=helm-charts-win-tls \
    --set global.ingress.configureCertmanager=false \
    --set global.appConfig.initialDefaults.signupEnabled=false \
    --set nginx-ingress.controller.electionID="$RELEASE_NAME" \
    --set nginx-ingress.controller.ingressClassByName=true \
    --set nginx-ingress.controller.ingressClassResource.controllerValue="ci.gitlab.com/$RELEASE_NAME" \
    --set certmanager.install=false \
    --set prometheus.install=$PROMETHEUS_INSTALL \
    --set global.gitlab.license.secret="$RELEASE_NAME-gitlab-license" \
    "${enable_kas[@]}" \
    --namespace="$NAMESPACE" \
    "${gitlab_version_args[@]}" \
    --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
    $HELM_EXTRA_ARGS \
    "$RELEASE_NAME" \
    .
}

function check_kas_status() {
  iteration=0
  kasState=""

  while [ "${kasState[1]}" != "Running" ]; do
    if [ $iteration -eq 0 ]; then
      echo ""
      echo -n "Waiting for KAS deploy to complete.";
    else
      echo -n "."
    fi

    iteration=$((iteration+1))
    kasState=($(kubectl get pods -n "$NAMESPACE" -lrelease=${RELEASE_NAME},app=kas | awk '{print $3}'))
    sleep 5;
  done
}

function wait_for_deploy {
  iteration=0

  # Watch for a `webservice` Pod to come online.
  webserviceState=0
  while [ "$webserviceState" -lt 2 ]; do
    # This will always return at least one line, `NAME`
    webserviceState=($(kubectl get pods -n "$NAMESPACE" -lrelease=${RELEASE_NAME},app=webservice --field-selector status.phase=Running -o=custom-columns=NAME:.metadata.name | wc -l))
    if [ $iteration -eq 0 ]; then
      echo -n "Waiting for deploy to complete.";
    else
      echo -n "."
    fi
    sleep 5;
  done

  if [[ -n "$KAS_ENABLED" ]]; then
    check_kas_status
  fi

  echo ""
}

function restart_toolbox() {
  # restart the toolbox pods, by deleting them
  # the ReplicaSet of the Deployment will re-create them
  # this ensure we run up-to-date on tags like `master` when there
  # have been no changes to the configuration to warrant a restart
  # via metadata checksum annotations
  kubectl -n ${NAMESPACE} delete pods -lapp=toolbox,release=${RELEASE_NAME}
  # always "succeed" so not to block.
  return 0
}

function download_chart() {
  mkdir -p chart/

  helm repo add gitlab https://charts.gitlab.io
  helm repo add jetstack https://charts.jetstack.io

  helm dependency update chart/
  helm dependency build chart/
}

function ensure_namespace() {
  kubectl describe namespace "$NAMESPACE" || kubectl create namespace "$NAMESPACE"
}

function check_kube_domain() {
  if [ -z ${KUBE_INGRESS_BASE_DOMAIN+x} ]; then
    echo "ERROR: In order to deploy, KUBE_INGRESS_BASE_DOMAIN must be set as a variable at the group or project level, or manually added in .gitlab-cy.yml"
    false
  else
    true
  fi
}

function check_domain_ip() {
  # Don't run on EKS clusters
  if [[ "$CI_ENVIRONMENT_SLUG" =~ ^eks.* ]]; then
    echo "Not running on EKS cluster"
    return 0
  fi

  # Expect the `DOMAIN` is a wildcard.
  domain_ip=$(nslookup gitlab$DOMAIN 2>/dev/null | grep "Address: \d" | awk '{print $2}')
  if [ -z $domain_ip ]; then
    echo "ERROR: There was a problem resolving the IP of 'gitlab$DOMAIN'. Be sure you have configured a DNS entry."
    false
  else
    export DOMAIN_IP=$domain_ip
    echo "Found IP for gitlab$DOMAIN: $DOMAIN_IP"
    true
  fi
}

function install_external_dns() {
  local provider="${1}"
  local domain_filter="${2}"
  local helm_args=''

  echo "Checking External DNS..."
  release_name="gitlab-external-dns"
  if ! helm status --namespace "${NAMESPACE}"  "${release_name}" > /dev/null 2>&1 ; then
    case "${provider}" in
      google)
        # We need to store the credentials in a secret
        kubectl create secret generic "${release_name}-secret" --from-literal="credentials.json=${GOOGLE_CLOUD_KEYFILE_JSON}"
        helm_args=" --set google.project=${GOOGLE_PROJECT_ID} --set google.serviceAccountSecret=${release_name}-secret"
        ;;
      aws)
        echo "Installing external-dns, ensure the NodeGroup has the permissions specified in"
        echo "https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-permissions"
        ;;
    esac

    helm repo add bitnami https://charts.bitnami.com/bitnami

    helm install "${release_name}" bitnami/external-dns \
      --namespace "${NAMESPACE}" \
      --set provider="${provider}" \
      --set domainFilters[0]="${domain_filter}" \
      --set txtOwnerId="${NAMESPACE}" \
      --set rbac.create="true" \
      --set policy='sync' \
      ${helm_args}
  fi
}

function create_secret() {
  kubectl create secret -n "$NAMESPACE" \
    docker-registry gitlab-registry-docker \
    --docker-server="$CI_REGISTRY" \
    --docker-username="$CI_REGISTRY_USER" \
    --docker-password="$CI_REGISTRY_PASSWORD" \
    --docker-email="$GITLAB_USER_EMAIL" \
    -o yaml --dry-run | kubectl replace -n "$NAMESPACE" --force -f -
}

function delete() {
  helm uninstall "$RELEASE_NAME" || true
}

function cleanup() {
  kubectl -n "$NAMESPACE" get ingress,svc,pdb,hpa,deploy,statefulset,job,pod,secret,configmap,pvc,secret,clusterrole,clusterrolebinding,role,rolebinding,sa 2>&1 \
    | grep "$RELEASE_NAME" \
    | awk '{print $1}' \
    | xargs kubectl -n "$NAMESPACE" delete \
    || true
}
