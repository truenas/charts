[![pipeline status](https://gitlab.com/gitlab-org/charts/gitlab/badges/master/pipeline.svg)](https://gitlab.com/gitlab-org/charts/gitlab/pipelines)

# Cloud Native GitLab Helm Chart

The `gitlab` chart is the best way to operate GitLab on Kubernetes. It contains
all the required components to get started, and can scale to large deployments.

Some of the key benefits of this chart and [corresponding containers](https://gitlab.com/gitlab-org/build/CNG) are:

- Improved scalability and reliability.
- No requirement for root privileges.
- Utilization of object storage instead of NFS for storage.

## Detailed documentation

See the [repository documentation](doc/index.md) for how to install GitLab and
other information on charts, tools, and advanced configuration.

For easy of reading, you can find this documentation rendered on
[docs.gitlab.com/charts](https://docs.gitlab.com/charts).

### Configuration Properties

We're often asked to put a table of all possible properties directly into this README.
These charts are _massive_ in scale, and as such the number of properties exceeds
the amount of context we're comfortable placing here. Please see our (nearly)
[comprehensive list of properties and defaults](doc/installation/command-line-options.md).

**Note:** We _strongly recommend_ following our complete documentation, as opposed to
jumping directly into the settings list.

## Architecture and goals

See [architecture documentation](doc/architecture/index.md) for an overview
of this project goals and architecture.

## Known issues and limitations

See [limitations](doc/index.md#limitations).

## Release Notes

Check the [releases documentation](doc/releases/index.md) for information on important releases,
and see the [changelog](CHANGELOG.md) for the full details on any release.

## Contributing

See the [contribution guidelines](CONTRIBUTING.md) and then check out the
[development styleguide](doc/development/index.md).
