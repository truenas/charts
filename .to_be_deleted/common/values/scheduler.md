# Scheduler

## Key: schedulerName

Info:

- Type: `string`
- Default: `""`
- Helm Template: ✅

Can be defined in:

- `.Values`.schedulerName
- `.Values.jobs.[job-name].podSpec`.schedulerName

---

Defines the scheduler that will be used.
Leaving it empty, Kubernetes will assign the `default-scheduler`

Examples:

```yaml
schedulerName: some-scheduler
# schedulerName: "{{ .Values.some.path }}"
```

Kubernetes Documentation:

- [Scheduler](https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/#specify-schedulers-for-pods)
