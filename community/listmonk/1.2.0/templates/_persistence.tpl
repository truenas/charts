{{- define "listmonk.persistence" -}}
persistence:
  uploads:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.listmonkStorage.uploads) | nindent 4 }}
    targetSelector:
      listmonk:
        listmonk:
          mountPath: /listmonk/uploads
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      listmonk:
        listmonk:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.listmonkStorage.additionalStorages }}
  {{ printf "listmonk-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      listmonk:
        listmonk:
          mountPath: {{ $storage.mountPath }}
  {{- end -}}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.listmonkStorage.pgData
            "pgBackup" .Values.listmonkStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
