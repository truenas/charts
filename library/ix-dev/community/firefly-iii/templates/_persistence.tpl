{{- define "firefly.persistence" -}}
persistence:
  uploads:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.fireflyStorage.uploads) | nindent 4 }}
    targetSelector:
      firefly:
        firefly:
          mountPath: /var/www/html/storage/upload
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      firefly:
        firefly:
          mountPath: /tmp
      firefly-importer:
        firefly-importer:
          mountPath: /tmp

  {{- range $idx, $storage := .Values.fireflyStorage.additionalStorages }}
  {{ printf "firefly-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      firefly:
        firefly:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.fireflyStorage.pgData
            "pgBackup" .Values.fireflyStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
