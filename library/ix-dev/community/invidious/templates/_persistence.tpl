{{- define "invidious.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.invidiousStorage.config) | nindent 4 }}
    targetSelector:
      invidious:
        invidious:
          mountPath: /config
        04-init-config:
          mountPath: /config
  shared:
    enabled: true
    type: emptyDir
    targetSelector:
      invidious:
        02-fetch-seed:
          mountPath: /shared
        03-init-db:
          mountPath: /shared
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      invidious:
        invidious:
          mountPath: /tmp

  {{- range $idx, $storage := .Values.invidiousStorage.additionalStorages }}
  {{ printf "invidious-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      invidious:
        invidious:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.invidiousStorage.pgData
            "pgBackup" .Values.invidiousStorage.pgBackup
      ) | nindent 2 }}

{{- end -}}
