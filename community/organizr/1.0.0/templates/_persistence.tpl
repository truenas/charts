{{- define "organizr.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.organizrStorage.config) | nindent 4 }}
    targetSelector:
      organizr:
        organizr:
          mountPath: /config
  varrun:
    enabled: true
    type: emptyDir
    targetSelector:
      organizr:
        organizr:
          mountPath: /var/run
  {{- range $idx, $storage := .Values.organizrStorage.additionalStorages }}
  {{ printf "organizr-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      organizr:
        organizr:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
