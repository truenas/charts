# Scale Certificate

| Key                                      |   Type    | Required |   Helm Template    | Default | Description                                   |
| :--------------------------------------- | :-------: | :------: | :----------------: | :-----: | :-------------------------------------------- |
| scaleCertificate                         |  `list`   |    ❌    |         ❌         |  `{}`   | Define the certificate as dicts               |
| scaleCertificate.[cert-name].enabled     | `boolean` |    ✅    |         ❌         | `false` | Enables the certificate (The secret creation) |
| scaleCertificate.[cert-name].labels      |  `dict`   |    ❌    | ✅ (On value only) |  `{}`   | Additional labels for secret                  |
| scaleCertificate.[cert-name].annotations |  `dict`   |    ❌    | ✅ (On value only) |  `{}`   | Additional annotations for secret             |
| scaleCertificate.[cert-name].id          | `string`  |    ✅    |         ❌         |  `""`   | ID of the certificate in ixCertificates       |

> A secret will be created with 2 keys in the data section: `crt` and `key`.

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

You can mount certificate as a secret using the following snippet:

```yaml
scaleCertificate:
  cert-name:
    enabled: false
    labels: {}
    annotations: {}
    id: 1

persistence:
  # This will mount it on the primary pod/container
  cert-vol:
    enabled: true
    type: secret
    objectName: cert-name
    expandObjectName: true # You can omit this, it's the default
    # subPath
    mountPath: /path/to/mount/cert.crt
    subPath: crt
    # or items
    mountPath: /path/to/mount
    items:
      - key: crt
        path: cert.crt

  # This will mount it on the specific pod/container
  cert-vol:
    enabled: true
    type: secret
    objectName: cert-name
    expandObjectName: true # You can omit this, it's the default
    # subPath
    subPath: crt
    targetSelector:
      workload-name:
        container-name:
          mountPath: /path/to/mount/cert.crt
          # subPath: crt (You can define subPath here as well, per container)
    # or items
    items:
      - key: crt
        path: cert.crt
    targetSelector:
      workload-name:
        container-name:
          mountPath: /path/to/mount

# Both will result in a mounted file in the container at /path/to/mount/cert.crt
```
