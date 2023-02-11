# DNS

## Key: dnsPolicy

Info:

- Type: `string`
- Default: `""`
- Helm Template: ❌

Can be defined in:

- `.Values`.dnsPolicy
- `.Values.jobs.[job-name].podSpec`.dnsPolicy

---

Defines the `dnsPolicy` for the workload.

You can also set a global default `dnsPolicy` in `.Values.global.defaults.dnsPolicy`

> Assuming it's left empty, it will use the global default, which is `ClusterFirst`
> If hostNetwork is enabled for the Pod, it will automatically switch `ClusterFirstWithHostNet`

Priority of usage (Highest to Lowest):

- Per pod definition
- Global definition

Examples:

```yaml
dnsPolicy: ClusterFirst
```

Kubernetes Documentation:

- [DNS Policy](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy)

---
---

## Key: dnsConfig

Info:

- Type: `dict`
- Default: `{}`
- Helm Template:
  - dnsConfig.nameservers.[item]: ✅
  - dnsConfig.searches.[item]: ✅
  - dnsConfig.options.name: ✅
  - dnsConfig.options.value: ✅

Can be defined in:

- `.Values`.dnsConfig
- `.Values.jobs.[job-name].podSpec`.dnsConfig

---

Defines dns configuration for the Pod.
