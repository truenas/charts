#!/bin/bash
set -e

# Prepare and deploy ChaosKube
# https://github.com/linki/chaoskube
# https://hub.helm.sh/charts/stable/chaoskube

# MacOS does not support readlink, but it does have perl
KERNEL_NAME=$(uname -s)
if [ "${KERNEL_NAME}" = "Darwin" ]; then
  SCRIPT_PATH=$(perl -e 'use Cwd "abs_path";use File::Basename;print dirname(abs_path(shift))' "$0")
else
  SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
fi

source $SCRIPT_PATH/common.sh;

function print_help() {
  cat <<EOF
Usage: ${0} ARGS (up|down)
-h - Prints this message

Arguments available when using the "up" subcommand
-n NAMESPACE - Namespace to use for the deployment. Defaults to kube-system
-v VERSION - Version of the Helm chart to use. Defaults to 3.1.2
-i INTERVAL - Interval for pods to be killed. Defaults to 10m
-f VALUES_FILE - Specifies values file to use for the deployment. Defaults to \$SCRIPTS_DIR/chaoskube-resources/values.yaml
-a ARGS - Optional Helm args (i.e. "key=value"). Be sure to wrap these args in quotes. You can pass multiple "-a" flags if needed.
-d - When used with "up", will run Helm installation with dry run and debug flags

up - Deploys ChaosKube
down - Uninstalls ChaosKube
EOF
}

function do_up() {
  local namespace="${1}"
  local version="${2}"
  local interval="${3}"
  local values_file=${4}
  local helm_args="${5}"

  validate_tools kubectl helm;

  helm install chaoskube \
    stable/chaoskube \
    --version ${version} \
    --namespace ${namespace} \
    -f ${values_file} \
    --set interval=${interval} \
    ${helm_args}
}

function do_down() {
  validate_tools kubectl helm;

  helm delete chaoskube
}

# Set defaults before getting user input
namespace=${NAMESPACE-kube-system}
version=${VERSION-3.1.2}
interval=${INTERVAL-10m}
helm_args=${HELM_ARGS}
values_file=${VALUES_FILE-$SCRIPT_PATH/chaoskube-resources/values.yaml}

while getopts "n:v:i:f:a:dh" opt; do
  case "${opt}" in
    n)
      namespace=${OPTARG} ;;
    v)
      version=${OPTARG} ;;
    i)
      interval=${OPTARG} ;;
    f)
      values_file=${OPTARG} ;;
    a)
      helm_args="$helm_args --set ${OPTARG}" ;;
    d)
      helm_args="$helm_args --dry-run --debug" ;;
    h)
      print_help
      exit 0
      ;;
    *)
      print_help
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

case ${1} in
  up)
    do_up "${namespace}" "${version}" "${interval}" "${values_file}" "${helm_args}"
    ;;
  down)
    do_down
    ;;
  *)
    print_help
    exit 1
esac
