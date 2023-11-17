{{- define "newslydb.persistence" -}}
persistence:

  {{/* Database */}}
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.newslyStorage.pgData
            "pgBackup" .Values.newslyStorage.pgBackup
      ) | nindent 2 }}

{{- end -}}