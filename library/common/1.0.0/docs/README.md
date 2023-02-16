# Root Chart Context

| Key              |   Type   | Required | Helm Template | Default | Description                                 |
| :--------------- | :------: | :------: | :-----------: | :-----: | :------------------------------------------ |
| .Values.TZ | `string` |    ✅    |      ❌       |  `UTC`  | Timezone that is used everywhere applicable |

---

Examples:

```yaml
TZ: Europe/Berlin
```

---

Documentation:

- [workload](workload/README.md)
- [container](container/README.md)
- [service](service/README.md)
- [persistence](persistence/README.md)
- [configmap](configmap.md)
- [secret](secret.md)
- [imagePullSecrets](imagePullSecrets.md)
- [serviceAccount](serviceAccount.md)
- [rbac](rbac.md)
- [scaleGPU](scaleGPU.md)
- [scaleCertificate](scaleCertificate.md)
- [scaleExternalInterface](scaleExternalInterface.md)
- [volumeClaimTemplates](volumeClaimTemplates.md)
