#!/bin/bash

# Checks that appropriate gke params are set and
# that gcloud and kubectl are properly installed and authenticated
function need_tool(){
  local tool="${1}"
  local url="${2}"

  echo >&2 "${tool} is required. Please follow ${url}"
  exit 1
}

function need_gcloud(){
  need_tool "gcloud" "https://cloud.google.com/sdk/downloads"
}

function need_kubectl(){
  need_tool "kubectl" "https://kubernetes.io/docs/tasks/tools/install-kubectl"
}

function need_helm(){
  need_tool "helm" "https://github.com/helm/helm/#install"
}

function need_eksctl(){
  need_tool "eksctl" "https://eksctl.io"
}

function need_az(){
  need_tool "az" "https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
}

function need_jq(){
  need_tool "jq" "https://stedolan.github.io/jq/download/"
}

function validate_tools(){
  for tool in "$@"
  do
    # Basic check for installation
    command -v "${tool}" > /dev/null 2>&1 || "need_${tool}"

    # Additional  checks if validating gcloud binary
    if [ "$tool" == 'gcloud' ]; then
      if [ -z "$PROJECT" ]; then
        echo "\$PROJECT needs to be set to your project id";
        exit 1;
      fi

      gcloud container clusters list --project $PROJECT >/dev/null 2>&1 || { echo >&2 "Gcloud seems to be configured incorrectly or authentication is unsuccessfull"; exit 1; }
    fi

    # Additional check if validating Helm
    if [ "$tool" == 'helm' ]; then
      if ! helm version --short --client | grep -q '^v3\.[0-9]\{1,\}'; then
        echo "Helm 3+ is required.";
        exit 1
      fi
    fi
  done
}

function cluster_admin_password_gke(){
  gcloud container clusters describe $CLUSTER_NAME --zone $ZONE --project $PROJECT --format='value(masterAuth.password)';
}

# Function to compare versions in a semver compatible way
# given args A and B, return 0 if A=B, -1 if A<B and 1 if A>B
function semver_compare() {
  if [ "$1" = "$2" ]; then
    # A = B
    echo 0
  else
    ordered=$(printf '%s\n' "$@" | sort -V | head -n 1)

    if [ "$ordered" = "$1" ]; then
      # A < B
      echo -1
    else
      # A > B
      echo 1
    fi
  fi
}
