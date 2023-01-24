# Jobs - CronJobs

## Key: jobs

Info:

- Type: `dict`
- Default `{}`
- Helm Template: ✅|❌
  - Supports almost every key the main container supports,
    except probes and lifecycle hooks.

Can be defined in:

- `.Values`.jobs

---

For each (cron)job under `jobs` it will spin up a Job or CronJob.

> Under `container.[container-name]` you can use all keys that you would use
> in a normal container. Except `probes` and `lifecycle` hooks.

Examples:

```yaml
jobs:
  job-name:
    enabled: true
    labels: {}
    annotations: {}
    backoffLimit: 1
    ttlSecondsAfterFinished: 100
    completionMode: NonIndexed
    activeDeadLineSeconds: 120
    parallelism: 2
    completions: 1
    podSpec:
      podSecurityContext:
        fsGroup: 1000
      containers:
        main:
          imageSelector: imageDict
          env:
            var: blabla
  cron-job-name:
    enabled: true
    labels: {}
    annotations: {}
    # All job options still go here
    cron:
      enabled: true
      schedule: "* * * * *"
      timezone: UTC
      failedJobsHistoryLimit: 2
      successfulJobsHistoryLimit: 3
      startingDeadlineSeconds: 5
    podSpec:
      podSecurityContext:
        fsGroup: 1000
      containers:
        main:
          imageSelector: imageDict
          env:
            var: blabla
```

---
---

## Stand alone Jobs - Cron Jobs

We can also define jobs and cronjobs that are standalone.
No "main" pod required.

`podSpec` now goes into `.Values`

Examples:

```yaml
controller:
  type: Job
  labels: {}
  annotations: {}
  backoffLimit: 1
  ttlSecondsAfterFinished: 100
  completionMode: NonIndexed
  activeDeadLineSeconds: 120
  parallelism: 2
  completions: 1

podSecurityContext:
  fsGroup: 1000

env:
  var: blabla
```
