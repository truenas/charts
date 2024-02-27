{{- define "diskover.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.diskoverStorage.config) | nindent 4 }}
    targetSelector:
      diskover:
        diskover:
          mountPath: /config
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.diskoverStorage.data) | nindent 4 }}
    targetSelector:
      diskover:
        diskover:
          mountPath: /data
  {{- range $idx, $storage := .Values.diskoverStorage.additionalStorages }}
  {{ printf "diskover-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      diskover:
        diskover:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
