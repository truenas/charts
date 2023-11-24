{{- define "searxng.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.searxngStorage.config) | nindent 4 }}
    targetSelector:
      searxng:
        searxng:
          mountPath: /etc/searxng
        01-permissions:
          mountPath: /mnt/directories/searxng
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      searxng:
        searxng:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.searxngStorage.additionalStorages }}
  {{ printf "searxng-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      searxng:
        searxng:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
