{{- define "postgres.workload" -}}
workload:
{{- include "ix.v1.common.app.postgres" (dict "secretName" "postgres-creds"
                                              "resources" .Values.resources
                                              "ixChartContext" .Values.ixChartContext) | nindent 2 }}

service:
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{/* Persistence */}}
persistence:
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.giteaStorage.pgData
            "pgBackup" .Values.giteaStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
