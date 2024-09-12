{{- define "palworld.persistence" -}}
persistence:
  steamcmd:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.palworldStorage.steamcmd) | nindent 4 }}
    targetSelector:
      palworld:
        palworld:
          mountPath: /serverdata/steamcmd
  server:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.palworldStorage.server) | nindent 4 }}
    targetSelector:
      palworld:
        palworld:
          mountPath: /serverdata/serverfiles
        01-config:
          mountPath: /serverdata/serverfiles
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      palworld:
        palworld:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.palworldStorage.additionalStorages }}
  {{ printf "palworld-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      palworld:
        palworld:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
