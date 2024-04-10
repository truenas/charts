{{- define "syncthing.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.syncthingStorage.config) | nindent 4 }}
    targetSelector:
      syncthing:
        syncthing:
          mountPath: /var/syncthing
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      syncthing:
        syncthing:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.syncthingStorage.additionalStorages }}
  {{ printf "syncthing-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      syncthing:
        syncthing:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
