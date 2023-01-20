#!/bin/bash
#
# generate_service_certificates.sh <service>
#--------------------------------------
# Script to generate a key and certificate for GitLab services, including Gitaly
# and Praefect to enable TLS support.
#
# Generates `<service>.crt` & `<service>.key` in a temporary directory, and
# places them into the current working directory.
#
# By default generates a key and certificated for `gitaly` in `default` namespace
# and `gitlab` release. Use `RELEASE_NAME` and `NAMESPACE` environment variables
# for non-default namespace and release.
#
# After generation, create a TLS secret:
#
#   kubectl create secret tls <service>-tls --cert=gitaly.crt --key=gitaly.key
#
# Then, configure the chart to use this:
#   global:
#     <service>:
#       tls:
#         enabled: true
#         secretName: <service>-tls
#--------------------------------------

VALID_DAYS=${VALID_DAYS-365}
CERT_NAME=${1-gitaly}
RELEASE_NAME=${RELEASE_NAME-gitlab}
NAMESPACE=${NAMESPACE-default}
DNS_SUFFIX=${DNS_SUFFIX:-.svc}

WORKDIR=`pwd`
TEMP_DIR=$(mktemp -d)
pushd ${TEMP_DIR} || exit

SERVICE_NAME="${RELEASE_NAME}-${CERT_NAME}"
SERVICE_NAME="${SERVICE_NAME:0:63}"

(
cat <<SANDOC
[req_ext]
subjectAltName = @san

[san]
DNS.1 = ${SERVICE_NAME}.${NAMESPACE}${DNS_SUFFIX}
DNS.2 = *.${SERVICE_NAME}.${NAMESPACE}${DNS_SUFFIX}

SANDOC
) > san.conf

openssl req -x509 -nodes -newkey rsa:4096 \
  -keyout "${CERT_NAME}.key" \
  -out "${CERT_NAME}.crt" \
  -days ${VALID_DAYS} \
  -subj "/CN=${CERT_NAME}" \
  -reqexts req_ext -extensions req_ext \
  -config <(cat /etc/ssl/openssl.cnf san.conf )

mv ${CERT_NAME}.* $WORKDIR/

popd
rm -rf ${TEMP_DIR}
