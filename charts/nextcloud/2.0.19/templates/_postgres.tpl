{{- define "postgres.workload" -}}
  {{- $backupSecretName := "postgres-creds" -}}
  {{- if eq (include "nextcloud.is-migration" $) "true" }}
    {{- $backupSecretName = "postgres-backup-creds" -}}
  {{- end }}
workload:
{{- include "ix.v1.common.app.postgres" (dict "secretName" "postgres-creds"
                                              "backupSecretName" $backupSecretName
                                              "resources" .Values.resources
                                              "imageSelector" "ncPostgresImage"
                                              "ixChartContext" .Values.ixChartContext) | nindent 2 }}
{{- end -}}
