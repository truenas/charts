#!/bin/bash
# The script will:
# - up
#   - Create a new Resource Group (optional)
#   - Create a new AKS cluster
#   - Create a new Public IP (optional)
# - down
#   - Delete the specified Resource Group (optional)
#   - Delete the AKS cluster
#   - Delete the Resource Group created by the Cluster
# - creds
#   - Connect `kubectl` to the cluster.

set -e

# MacOS does not support readlink, but it does have perl
KERNEL_NAME=$(uname -s)
if [ "${KERNEL_NAME}" = "Darwin" ]; then
  SCRIPT_PATH=$(perl -e 'use Cwd "abs_path";use File::Basename;print dirname(abs_path(shift))' "$0")
else
  SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
fi

source "${SCRIPT_PATH}/common.sh"

# Set default values
# Documentation: doc/installation/cloud/aks.md
resource_group=${RESOURCE_GROUP-gitlab-resources}
region=${REGION-eastus}
cluster_version=${CLUSTER_VERSION-''}
cluster_name=${CLUSTER_NAME-gitlab-cluster}
node_count=${NODE_COUNT-2}
node_vm_size=${NODE_VM_SIZE-Standard_D4s_v3}
public_ip_name=${PUBLIC_IP_NAME-gitlab-ext-ip}
kubectl_config_file=${KUBCTL_CONFIG_FILE-'~/.kube/config'}
create_resource_group=false
delete_resource_group=false
create_static_ip=false

function print_help(){
  cat <<EOF
Usage: ${0} ARGS (up|down|creds)
Common:
  -g | --resource-group  - Name of the resource group to use. Defaults to gitlab-resources
  -n | --cluster-name - Name of the cluster to use. Defaults to gitlab-cluster
Up:
  -r | --region - Region to install the cluster in. Defaults to eastus
  -v | --cluster-version - Version of Kubernetes to use for creating the cluster. Defaults to the latest version
  -c | --node-count - Number of nodes to use. Defaults to 2
  -s | --node-vm-size - Type of nodes to use. Defaults to Standard_D4s_v3
  -p | --public-ip-name - Name of the public IP to create. Defaults to gitlab-ext-ip
  --create-resource-group - Create a new resource group to hold all created resources.
  --create-public-ip - Create a public IP to use with the new cluster.
Down:
  --delete-resource-group - Delete the resource group when using the down command. Defaults to false
Creds:
  -f | --kubctl_config_file - Kubernetes configuration file to update. Use "-" to print YAML to stdout instead. Defaults to ~/.kube/config

up - create a cluster
down - delete a cluster
creds - download credentials and install into kubeconfig file
EOF
}

function do_up(){
  local resource_group="$1"
  local region="$2"
  local cluster_version="$3"
  local create_resource_group="$4"
  local cluster_name="$5"
  local node_count="$6"
  local node_vm_size="$7"
  local public_ip_name="$8"
  local kubernetes_version=""

  if [ $create_resource_group = true ]; then
    echo "Creating Resource Group: $resource_group"

    az group create \
      --name $resource_group \
      --location $region
  fi

  echo "Creating $cluster_name cluster in resource group $resource_group"

  if [ -n "$cluster_version" ]; then
    kubernetes_version="--kubernetes-version $cluster_version"
  fi

  local node_resource_group=$(az aks create \
    --resource-group $resource_group \
    --name $cluster_name \
    --node-count $node_count \
    --node-vm-size $node_vm_size \
    $kubernetes_version --generate-ssh-keys | \
    jq -r '.nodeResourceGroup')

  if [ "$create_public_ip" = true ]; then
    echo "Creating a public IP called $public_ip_name in resource group $node_resource_group"

    az network public-ip create \
      --resource-group $node_resource_group \
      --name $public_ip_name \
      --sku Standard \
      --allocation-method static
  fi
}

function do_down(){
  local delete_resource_group=$1
  local resource_group=$2
  local cluster_name=$3

  if [ $delete_resource_group = true ]; then
    echo "Deleting resource group $resource_group"

    az group delete \
      -n $resource_group \
      --no-wait
  else
    echo "Deleting $cluster_name cluster from resource group $resource_group"

    az aks delete \
      --name $cluster_name \
      --resource-group $resource_group \
      --no-wait
  fi

  local node_resource_group=$(az aks show \
    --name $cluster_name \
    --resource-group $resource_group | \
    jq -r '.nodeResourceGroup')

  echo "Deleting cluster resource group $node_resource_group"

  az group delete \
    -n $node_resource_group \
    --no-wait \
    --yes
}

function do_creds(){
  local resource_group=$1
  local cluster_name=$2
  local kubctl_config_file=$3

  az aks get-credentials \
    --resource-group $resource_group \
    --name $cluster_name \
    --file $kubctl_config_file
}

validate_tools az kubectl helm jq

for arg in $@
do
  case $arg in
    -g|--resource-group)
      resource_group="$2"
      shift
      shift
    ;;
    -r|--region)
      region="$2"
      shift
      shift
    ;;
    --create-resource-group)
      create_resource_group=true
      shift
    ;;
    --delete-resource-group)
      delete_resource_group=true
      shift
    ;;
    -v|--cluster-version)
      cluster_version="$2"
      shift
      shift
    ;;
    -n|--cluster-name)
      cluster_name="$2"
      shift
      shift
    ;;
    -c|--node-count)
      node_count="$2"
      shift
      shift
    ;;
    -s|--node-vm-size)
      node_vm_size="$2"
      shift
      shift
    ;;
    --create-public-ip)
      create_public_ip=true
      shift
    ;;
    -p|--public-ip-name)
      public_ip_name="$2"
      shift
      shift
    ;;
    -f|--kubctl_config_file)
      kubctl_config_file="$2"
      shift
      shift
    ;;
    [?])
      echo "Invalid Argument Passed: $arg"
      print_help
      exit 1
    ;;
  esac
done

case $1 in
  up)
    do_up "$resource_group" "$region" "$cluster_version" "$create_resource_group" "$cluster_name" "$node_count" "$node_vm_size" "$public_ip_name"
    ;;
  down)
    do_down "$delete_resource_group" "$resource_group" "$cluster_name"
    ;;
  creds)
    do_creds "$resource_group"  "$cluster_name" "$kubctl_config_file"
    ;;
  *)
    echo "Invalid Run Type $1: up|down|creds"
    print_help
    exit 1
esac