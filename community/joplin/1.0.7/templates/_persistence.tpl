{{- define "joplin.persistence" -}}
persistence:
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.joplinStorage.pgData
            "pgBackup" .Values.joplinStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
