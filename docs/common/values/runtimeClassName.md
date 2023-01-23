# Runtime Class Name

## Key: runtimeClassName

Info:

- Type: `string`
- Default: `""`
- Helm Template: ❌

Can be defined in:

- `.Values`.runtimeClassName
- `.Values.jobs.[job-name].podSpec`.runtimeClassName

---

Defines the `runtimeClassName` for the workloads.

Leaving it empty it will use the default `runtimeClassName`.
> On TrueNAS Scale, it will dynamically pick the `runtimeClassName`
> based on metadata provided by the middleware.

Examples:

```yaml
runtimeClassName: some-class-name
```

Kubernetes Documentation:

- [Runtime Class](https://kubernetes.io/docs/concepts/containers/runtime-class/#usage)
