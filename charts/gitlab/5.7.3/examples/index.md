# Examples

## Purpose

This folder includes files that serve as examples for different configurations
for various use cases and customizations of these charts.

## Usage

1. Copy the needed `values.yaml` example to the root of this repository
1. Open the file in your text editor
1. Edit the file as needed
1. run `helm upgrade --install -f <file-name>.yaml gitlab .`

### Example

Let us say we would like to have a basic GitLab installation using the included
`values-base.yaml`. we would be doing the following:

1. `cp examples/values-base.yaml ./`
1. Open the file in a text editor
1. Change `gitlab.hosts.domain` and `gitlab.hosts.externalIP` with our own values
1. Change `smtp` block with our values making sure we have the needed secret. Alternatively we can omit the block completely if we do not need to configure `smtp`. Finally we save the file
1. run `helm upgrade --install -f values-base.yaml gitlab .`

### Testing

All examples that end in either `.yaml` or `.yml` are tested in CI by
[`spec/integration/examples_spec.rb`](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/spec/integration/examples_spec.rb).

This do not test that the examples work as intended, but they do check
that the configuration can be rendered by `helm template` without
errors.
