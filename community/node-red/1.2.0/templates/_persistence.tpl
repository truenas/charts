{{- define "nodered.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "nodered.storage.ci.migration" (dict "storage" .Values.noderedStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.noderedStorage.data) | nindent 4 }}
    targetSelector:
      nodered:
        nodered:
          mountPath: /data
        01-permissions:
          mountPath: /mnt/directories/data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      nodered:
        nodered:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.noderedStorage.additionalStorages }}
  {{ printf "nodered-%v" (int $idx) }}:
    enabled: true
    {{- include "nodered.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      nodered:
        nodered:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "nodered.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
