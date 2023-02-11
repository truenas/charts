# Names

## Key: nameOverride

Info:

- Type: `string`
- Default: `""`
- Helm Template: ❌

Can be defined in:

- `.Values`.nameOverride

---

Overrides the name of the workload.

> This is not the full name, but a part of the full name
> This is something that will only needed in very rare scenarios.
> Should be avoided, unless is absolutely needed.

Examples:

```yaml
nameOverride: some_name
```

---
---

## Key: fullnameOverride

Info:

- Type: `string`
- Default: `""`
- Helm Template: ❌

Can be defined in:

- `.Values`.fullnameOverride

---

Overrides the name of the workload.

> This affects the full name of the Deployment/StatefulSet/etc
> This is something that will only needed in very rare scenarios.
> Should be avoided, unless is absolutely needed.
