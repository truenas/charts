# $ref

Key `$ref` can be defined under `schema`. It's used to fetch values from the host system API.

Supported actions:

- Definitions
- Normalize

## Definitions

### Timezone

This will populate a drop down menu of timezones.

```yaml
- variable: timezone
  label: Configure timezone
  group: Configuration
  description: "Configure timezone"
  schema:
    type: string
    $ref:
      - "definitions/timezone"
```

This returns a string with the timezone name. For example `America/New_York`.

### Interface

This will populate a drop down menu of network interfaces.

```yaml
- variable: interface
  label: Configure network interface
  group: Configuration
  description: "Configure network interface"
  schema:
    type: string
    $ref:
      - "definitions/interface"
```

This returns a string with the interface name. For example `eth0`.

### GPU

This will populate a drop down menu of GPU configurations.

```yaml
- variable: interface
  label: Configure network interface
  group: Configuration
  description: "Configure network interface"
  schema:
    type: dict
    $ref:
      - "definitions/gpuConfiguration"
```

This will return a dict with the following format:

```yaml
gpuConfiguration:
  nvidia.com/gpu: "1"
```

### Node IP

This will populate with the IP of the node where the app is running.

```yaml
- variable: host
  label: "Node IP"
  schema:
    type: string
    $ref:
      - "definitions/nodeIP"
```

### Certificate

This will populate the drop down menu with the certificates that are available in the host system.

```yaml
- variable: certificate
  label: "Certificate"
  schema:
    type: int
    $ref:
      - "definitions/certificate"
```

This will return an integer with the certificate ID.
You can use this ID to get certificate values from `.Values.ixCertificates`.
Format:

```yaml
ixCertificates:
  "1":
    privatekey: |
      -----BEGIN PRIVATE KEY-----
      ........................
      -----END PRIVATE KEY-----
    certificate: |
      -----BEGIN CERTIFICATE-----
      ........................
      -----END CERTIFICATE-----
    ...
```

## Normalize

### ixVolume

```yaml
- variable: datasetName
  label: "Configuration Volume Dataset Name"
  schema:
    type: string
    default: config
    $ref:
      - "normalize/ixVolume"
```

Defining a value here (eg. `config`) will instruct API to create a "volume" in the user configured ix-application dataset.
Then within the helm chart you can search in `.Values.ixVolumes` for the dataset name and get the mount point.
`.Values.ixVolumes` is a list of dicts with the following format:

```yaml
ixVolumes:
  - hostPath: /mnt/POOL/ix-applications/APP/DATASET_NAME
```
