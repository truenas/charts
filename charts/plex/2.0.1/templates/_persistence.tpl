{{- define "plex.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.plexStorage.data) | nindent 4 }}
    targetSelector:
      plex:
        plex:
          mountPath: /data
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.plexStorage.config) | nindent 4 }}
    targetSelector:
      plex:
        plex:
          mountPath: /config
  transcode:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.plexStorage.transcode) | nindent 4 }}
    targetSelector:
      plex:
        plex:
          mountPath: /transcode
  shared:
    enabled: true
    type: emptyDir
    targetSelector:
      plex:
        plex:
          mountPath: /shared
  logs:
    enabled: true
    type: emptyDir
    targetSelector:
      plex:
        plex:
          mountPath: "/config/Library/Application Support/Plex Media Server/Logs"
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      plex:
        plex:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.plexStorage.additionalStorages }}
  {{ printf "plex-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      plex:
        plex:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
