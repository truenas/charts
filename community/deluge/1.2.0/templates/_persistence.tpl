{{- define "deluge.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "deluge.storage.ci.migration" (dict "storage" .Values.delugeStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.delugeStorage.config) | nindent 4 }}
    targetSelector:
      deluge:
        deluge:
          mountPath: /config
        config:
          mountPath: /config
  downloads:
    enabled: true
    {{- include "deluge.storage.ci.migration" (dict "storage" .Values.delugeStorage.downloads) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.delugeStorage.downloads) | nindent 4 }}
    targetSelector:
      deluge:
        deluge:
          mountPath: /downloads
  {{- range $idx, $storage := .Values.delugeStorage.additionalStorages }}
  {{ printf "deluge-%v:" (int $idx) }}
    enabled: true
    {{- include "deluge.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      deluge:
        deluge:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "deluge.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
