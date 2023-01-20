#!/bin/env bash
set -e

git config --global user.name "GitLab Distribution"
git config --global user.email "distribution-be@gitlab.com"
OPERATOR_PROJECT=${OPERATOR_PROJECT:-gitlab.com/gitlab-org/cloud-native/gitlab-operator.git}

rm -rf /tmp/gitlab-operator
git clone "https://${OPERATOR_PROJECT_USERNAME}:${OPERATOR_PROJECT_PASSWORD}@${OPERATOR_PROJECT}" /tmp/gitlab-operator

# Update the CHART_VERSIONS file
bundle exec ruby -e "require './scripts/gitlab_charts_helper'; puts GitLabChartsHelper.supported_versions" > /tmp/gitlab-operator/CHART_VERSIONS

pushd /tmp/gitlab-operator || exit
  if $(git diff --quiet); then
    echo "No changes to commit. Exiting."
    exit 0
  fi
  git checkout -b "bump-charts-${CI_COMMIT_TAG}"
  git add CHART_VERSIONS
  git commit -m "Update CHART_VERSIONS for GitLab Chart release ${CI_COMMIT_TAG}"
  git push -f origin "bump-charts-${CI_COMMIT_TAG}" \
    -o merge_request.create \
    -o merge_request.description="Created by pipeline: ${CI_PIPELINE_URL}" \
    -o merge_request.label="group::distribution" \
    -o merge_request.label="devops::enablement" \
    -o merge_request.label="section::enablement" \
    -o merge_request.label="feature::maintenance" \
    -o merge_request.label="Category:Cloud Native Installation" \
    -o merge_request.label="workflow::ready for review"
popd || exit
