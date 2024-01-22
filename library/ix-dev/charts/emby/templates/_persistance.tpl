{{- define "emby.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.embyStorage.config) | nindent 4 }}
    targetSelector:
      emby:
        emby:
          mountPath: /config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      emby:
        emby:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.embyStorage.additionalStorages }}
  {{ printf "emby-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      emby:
        emby:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
