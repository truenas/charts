# Node Selector

## Key: nodeSelector

Info:

- Type: `dict`
- Default: `{}`
- Helm Template:
  - key: ❌
  - value: ✅

Can be defined in:

- `.Values`.nodeSelector
- `.Values.jobs.[job-name].podSpec`.nodeSelector

---

Defines the nodeSelector(s) that will be used.
Node selector is used to select in which node a workload will be deployed.

Examples:

```yaml
nodeSelector:
  disktype: ssd
  cpu-type: "{{ .Values.some.path }}"
```

Kubernetes Documentation:

- [Node Selector](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/)
