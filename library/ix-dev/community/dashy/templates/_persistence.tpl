{{- define "dashy.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.dashyStorage.config) | nindent 4 }}
    targetSelector:
      dashy:
        dashy:
          mountPath: /app/public
        # Mount the same dir to different path on init container
        # So we can check if `/data` is empty and copy the default
        # from /app/public
        init-config:
          mountPath: /data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      dashy:
        dashy:
          mountPath: /tmp

  {{- range $idx, $storage := .Values.dashyStorage.additionalStorages }}
  {{ printf "dashy-%v" (int $idx) }}:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      dashy:
        dashy:
          mountPath: {{ $storage.mountPath }}
  {{- end -}}
{{- end -}}
