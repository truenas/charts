{{- define "kapowarr.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.kapowarrStorage.config) | nindent 4 }}
    targetSelector:
      kapowarr:
        kapowarr:
          mountPath: /app/db
  downloads:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.kapowarrStorage.downloads) | nindent 4 }}
    targetSelector:
      kapowarr:
        kapowarr:
          mountPath: /app/temp_downloads
  content:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.kapowarrStorage.content) | nindent 4 }}
    targetSelector:
      kapowarr:
        kapowarr:
          mountPath: /content
  {{- range $idx, $storage := .Values.kapowarrStorage.additionalStorages }}
  {{ printf "kapowarr-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      kapowarr:
        kapowarr:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
