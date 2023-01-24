# Persistence

## Key: persistence

- Type: `dict`
- Default:

  ```yaml
  shared:
    enabled: true
    type: emptyDir
    mountPath: /shared

  varlogs:
    enabled: true
    type: emptyDir
    mountPath: /var/logs

  tmp:
    enabled: true
    type: emptyDir
    mountPath: /tmp
  ```

- Helm Template: ❌

Can be defined in:

- `.Values`.persistence

---

Examples:

```yaml
persistence:
  # emptyDir
  emptyDir-vol:
    enabled: true
    mountPath: /some/container/path
    # Optional: When set, it won't automatically
    # mount the volume to the main container.
    # Useful if the volume is supposed to be mounted on
    # another container only, default false
    noMount: true
    # Optional
    mountPropagation: HostToContainer
    # Optional
    readOnly: false
    # Optional, useful for secret and configmap volumes
    subPath: subpath
    # Above keys apply to all types
    type: emptyDir
    # Optional: Defaults to Memory
    medium: Memory
    # Optional: Only applies if set
    sizeLimit: 1G

  nfs-vol:
    enabled: true
    mountPath: /some/container/path
    type: nfs
    server: 192.168.1.100
    path: /path/to/nfs/share

  hotsPath-vol:
    enabled: true
    mountPath: /some/container/path
    type: hostPath
    hostPath: /path/to/host
    # Optional
    hostPathType: DirectoryOrCreate
    # Optional, defaults to .Values.global.defaults.validateHostPath
    # It can be overwritten per volume too
    validateHostPath: false

  ixVolume-vol:
    enabled: true
    mountPath: /some/container/path
    type: ixVolume
    datasetName: populated-from-refs
    # Optional
    hostPathType: DirectoryOrCreate

  configmap-vol:
    enabled: true
    mountPath: /some/container/path
    type: configmap
    # Optional: Must be a string with 4 digits
    # If passed as integer, it will result in a different value
    # Because of how k8s does the conversion to octal
    defaultMode: "0600"
    items:
      - key: key-from-the-configmap
        path: path-in-the-container (usually the filename)

  secret-vol:
    enabled: true
    mountPath: /some/container/path
    type: configmap
    # Optional: Must be a string with 4 digits
    # If passed as integer, it will result in a different value
    # Because of how k8s does the conversion to octal
    defaultMode: "0600"
    items:
      - key: key-from-the-configmap
        path: path-in-the-container (usually the filename)

  pvc-vol:
    enabled: true
    mountPath: /some/container/path
    type: pvc
```
