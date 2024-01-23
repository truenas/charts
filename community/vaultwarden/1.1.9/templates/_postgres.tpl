{{- define "postgres.workload" -}}
{{/* Postgres Database */}}
workload:
{{- include "ix.v1.common.app.postgres" (dict "secretName" "postgres-creds"
                                              "resources" .Values.resources
                                              "ixChartContext" .Values.ixChartContext) | nindent 2 }}

{{/* Service */}}
service:
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{/* Persistence */}}
persistence:
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.vaultwardenStorage.pgData
            "pgBackup" .Values.vaultwardenStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
