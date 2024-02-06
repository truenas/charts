{{- define "netdata.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.netdataStorage.config) | nindent 4 }}
    targetSelector:
      netdata:
        netdata:
          mountPath: /etc/netdata
  cache:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.netdataStorage.cache) | nindent 4 }}
    targetSelector:
      netdata:
        netdata:
          mountPath: /var/cache/netdata
  lib:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.netdataStorage.lib) | nindent 4 }}
    targetSelector:
      netdata:
        netdata:
          mountPath: /var/lib/netdata
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      netdata:
        netdata:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.netdataStorage.additionalStorages }}
  {{ printf "netdata-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      netdata:
        netdata:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  os-release:
    enabled: true
    type: hostPath
    hostPath: /etc/os-release
    targetSelector:
      netdata:
        netdata:
          mountPath: /host/etc/os-release
          readOnly: true
  sys:
    enabled: true
    type: hostPath
    hostPath: /sys
    targetSelector:
      netdata:
        netdata:
          mountPath: /host/sys
          readOnly: true
  proc:
    enabled: true
    type: hostPath
    hostPath: /proc
    targetSelector:
      netdata:
        netdata:
          mountPath: /host/proc
          readOnly: true
  etc-passwd:
    enabled: true
    type: hostPath
    hostPath: /etc/passwd
    targetSelector:
      netdata:
        netdata:
          mountPath: /host/etc/passwd
          readOnly: true
  etc-group:
    enabled: true
    type: hostPath
    hostPath: /etc/group
    targetSelector:
      netdata:
        netdata:
          mountPath: /host/etc/group
          readOnly: true
{{- end -}}
