{{- define "newslydb.persistence" -}}
persistence:

  {{/* Database */}}
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.immichStorage.pgData
            "pgBackup" .Values.immichStorage.pgBackup
      ) | nindent 2 }}

{{- end -}}