# Priority Class Name

## Key: priorityClassName

Info:

- Type: `string`
- Default: `""`
- Helm Template: ❌

Can be defined in:

- `.Values`.priorityClassName
- `.Values.jobs.[job-name].podSpec`.priorityClassName

---

Defines the `priorityClassName` for the workloads.

Leaving it empty it will let Kubernetes resolve the `priorityClassName`.

Examples:

```yaml
priorityClassName: some-priority-class-name
```

Kubernetes Documentation:

- [Priority Class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/)
