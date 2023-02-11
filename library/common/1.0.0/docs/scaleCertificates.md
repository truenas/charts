# Scale Certificate

| Key                                      |   Type    | Required |   Helm Template    | Default | Description                                   |
| :--------------------------------------- | :-------: | :------: | :----------------: | :-----: | :-------------------------------------------- |
| scaleCertificate                         |  `list`   |    ❌    |         ❌         |  `{}`   | Define the certificate as dicts               |
| scaleCertificate.[cert-name].enabled     | `boolean` |    ✅    |         ❌         | `false` | Enables the certificate (The secret creation) |
| scaleCertificate.[cert-name].labels      |  `dict`   |    ❌    | ✅ (On value only) |  `{}`   | Additional labels for secret                  |
| scaleCertificate.[cert-name].annotations |  `dict`   |    ❌    | ✅ (On value only) |  `{}`   | Additional annotations for secret             |
| scaleCertificate.[cert-name].id          | `string`  |    ✅    |         ❌         |  `""`   | ID of the certificate in ixCertificates       |

---

Appears in:

- `.Values.scaleCertificate`

---

Naming scheme:

- `$FullName-$CertName` (release-name-chart-name-CertName)

---

Examples:

```yaml
scaleCertificate:
  cert-name:
    enabled: false
    labels: {}
    annotations: {}
    id: 1
```
