{{- define "audiobookshelf.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.audiobookshelfStorage.config) | nindent 4 }}
    targetSelector:
      audiobookshelf:
        audiobookshelf:
          mountPath: /config
  metadata:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.audiobookshelfStorage.metadata) | nindent 4 }}
    targetSelector:
      audiobookshelf:
        audiobookshelf:
          mountPath: /metadata
  {{- range $idx, $storage := .Values.audiobookshelfStorage.additionalStorages }}
  {{ printf "audiobookshelf-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      audiobookshelf:
        audiobookshelf:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
