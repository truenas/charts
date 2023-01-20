---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Resource usage

## Resource Requests

All of our containers include predefined resource request values. By default we
have not put resource limits into place. If your nodes do not have excess memory
capacity, one option is to apply memory limits, though adding more memory (or nodes)
would be preferable. (You want to avoid running out of memory on any of your
Kubernetes nodes, as the Linux kernel's [out of memory manager](https://www.kernel.org/doc/gorman/html/understand/understand016.html) may end essential Kube processes)

In order to come up with our default request values, we run the application, and
come up with a way to generate various levels of load for each service. We monitor the
service, and make a call on what we think is the best default value.

We will measure:

- **Idle Load** - No default should be below these values, but an idle process
  isn't useful, so typically we will not set a default based on this value.

- **Minimal Load** - The values required to do the most basic useful amount of work.
  Typically, for CPU, this will be used as the default, but memory requests come with
  the risk of the Kernel reaping processes, so we will avoid using this as a memory default.

- **Average Loads** - What is considered *average* is highly dependent on the installation,
  for our defaults we will attempt to take a few measurements at a few of what we
  consider reasonable loads. (we will list the loads used). If the service has a pod
  autoscaler, we will typically try to set the scaling target value based on these.
  And also the default memory requests.

- **Stressful Task** - Measure the usage of the most stressful task the service
  should perform. (Not necessary under load). When applying resource limits, try and
  set the limit above this and the average load values.

- **Heavy Load** - Try and come up with a stress test for the service, then measure
  the resource usage required to do it. We currently don't use these values for any
  defaults, but users will likely want to set resource limits somewhere between the
  average loads/stress task and this value.

### GitLab Shell

Load was tested using a bash loop calling  `nohup git clone <project> <random-path-name>` in order to have some concurrency.
In future tests we will try to include sustained concurrent load, to better match the types of tests we have done for the other services.

- **Idle values**
  - 0 tasks, 2 pods
    - cpu: 0
    - memory: `5M`

- **Minimal Load**
  - 1 tasks (one empty clone), 2 pods
    - cpu: 0
    - memory: `5M`

- **Average Loads**
  - 5 concurrent clones, 2 pods
    - cpu: `100m`
    - memory: `5M`
  - 20 concurrent clones, 2 pods
    - cpu: `80m`
    - memory: `6M`

- **Stressful Task**
  - SSH clone the Linux kernel (17MB/s)
    - cpu: `280m`
    - memory: `17M`
  - SSH push the Linux kernel (2MB/s)
    - cpu: `140m`
    - memory: `13M`
    - *Upload connection speed was likely a factor during our tests*

- **Heavy Load**
  - 100 concurrent clones, 4 pods
    - cpu: `110m`
    - memory: `7M`

- **Default Requests**
  - cpu: 0 (from minimal load)
  - memory: `6M` (from average load)
  - target CPU average: `100m` (from average loads)

- **Recommended Limits**
  - cpu: > `300m` (greater than stress task)
  - memory: > `20M` (greater than stress task)

Check the [troubleshooting documentation](../troubleshooting/index.md#git-over-ssh-the-remote-end-hung-up-unexpectedly)
for details on what might happen if `gitlab.gitlab-shell.resources.limits.memory` is set too low.

### Webservice

Webservice resources were analyzed during testing with the
[10k reference architecture](https://docs.gitlab.com/ee/administration/reference_architectures/10k_users.html).
Notes can be found in the [Webservice resources documentation](../charts/gitlab/webservice/index.md#resources).

### Sidekiq

Sidekiq resources were analyzed during testing with the
[10k reference architecture](https://docs.gitlab.com/ee/administration/reference_architectures/10k_users.html).
Notes can be found in the [Sidekiq resources documentation](../charts/gitlab/sidekiq/index.md#resources).

### KAS

Until we learn more about our users need, we expect that our users will be using KAS the following way.

- **Idle values**
  - 0 agents connected, 2 pods
    - cpu: `10m`
    - memory: `55M`
- **Minimal Load**:
  - 1 agents connected, 2 pods
    - cpu: `10m`
    - memory: `55M`
- **Average Load**: 1 agent is connected to the cluster.
  - 5 agents connected, 2 pods
    - cpu: `10m`
    - memory: `65M`
- **Stressful Task**:
  - 20 agents connected, 2 pods
    - cpu: `30m`
    - memory: `95M`
- **Heavy Load**:
  - 50 agents connected, 2 pods
    - cpu: `40m`
    - memory: `150M`
- **Extra Heavy Load**:
  - 200 agents connected, 2 pods
    - cpu: `50m`
    - memory: `315M`

The KAS resources defaults set by this chart are more than enough to handle even the 50 agents scenario.
If you are planning to reach what we consider an **Extra Heavy Load**, then you should consider tweaking the
default to scale up.

- **Defaults**: 2 pods, each with
  - cpu: `100m`
  - memory: `100M`

For more information on how these numbers were calculated, see the
[issue discussion](https://gitlab.com/gitlab-org/gitlab/-/issues/296789#note_542196438).
