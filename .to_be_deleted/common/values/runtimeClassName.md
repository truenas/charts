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

Leaving it empty it will let Kubernetes resolve the `runtimeClassName`.
> On TrueNAS Scale, it will dynamically pick the `runtimeClassName`
> based on metadata provided by the middleware.

You can also set a global default `runtimeClassName` in `.Values.global.defaults.runtimeClassName`

Priority of usage (Highest to Lowest):

- Dynamic Class Name provided from Scale Metadata
- Per pod definition
- Global definition

Examples:

```yaml
runtimeClassName: some-class-name
```

Kubernetes Documentation:

- [Runtime Class](https://kubernetes.io/docs/concepts/containers/runtime-class/#usage)
