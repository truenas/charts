{{- define "postgres.workload" -}}
{{/* Postgres Database */}}
workload:
{{- include "ix.v1.common.app.postgres" (dict "secretName" "postgres-creds" "resources" .Values.resources) | nindent 2 }}

{{/* Service */}}
service:
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- include "vaultwarden.storage.ci.migration" (dict "storage" .Values.vaultwardenStorage.pgData) }}
{{- include "vaultwarden.storage.ci.migration" (dict "storage" .Values.vaultwardenStorage.pgBackup) }}
{{/* Persistence */}}
persistence:
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.vaultwardenStorage.pgData
            "pgBackup" .Values.vaultwardenStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
