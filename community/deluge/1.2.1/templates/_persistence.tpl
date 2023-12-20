{{- define "deluge.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.delugeStorage.config) | nindent 4 }}
    targetSelector:
      deluge:
        deluge:
          mountPath: /config
        config:
          mountPath: /config
  downloads:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.delugeStorage.downloads) | nindent 4 }}
    targetSelector:
      deluge:
        deluge:
          mountPath: /downloads
  {{- range $idx, $storage := .Values.delugeStorage.additionalStorages }}
  {{ printf "deluge-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      deluge:
        deluge:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
