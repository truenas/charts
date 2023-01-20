#!/bin/bash
set -e

mkdir -p /etc/gitlab/minio

kubectl get secret ${RELEASE_NAME}-minio-secret -o jsonpath='{.data.accesskey}' | base64 --decode > /etc/gitlab/minio/accesskey
kubectl get secret ${RELEASE_NAME}-minio-secret -o jsonpath='{.data.secretkey}' | base64 --decode > /etc/gitlab/minio/secretkey
