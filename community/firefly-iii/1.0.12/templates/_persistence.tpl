{{- define "firefly.persistence" -}}
persistence:
  uploads:
    enabled: true
    type: {{ .Values.fireflyStorage.uploads.type }}
    datasetName: {{ .Values.fireflyStorage.uploads.datasetName | default "" }}
    hostPath: {{ .Values.fireflyStorage.uploads.hostPath | default "" }}
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

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.fireflyStorage.pgData
            "pgBackup" .Values.fireflyStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
