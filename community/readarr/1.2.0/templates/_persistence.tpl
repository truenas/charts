{{- define "readarr.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "readarr.storage.ci.migration" (dict "storage" .Values.readarrStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.readarrStorage.config) | nindent 4 }}
    targetSelector:
      readarr:
        readarr:
          mountPath: /config
        {{- if eq .Values.readarrStorage.config.type "ixVolume" }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      readarr:
        readarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.readarrStorage.additionalStorages }}
  {{ printf "readarr-%v:" (int $idx) }}
    enabled: true
    {{- include "readarr.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      readarr:
        readarr:
          mountPath: {{ $storage.mountPath }}
        {{- if eq $storage.type "ixVolume" }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "readarr.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
