{{- define "postgres.workload" -}}
{{- $psql := "PGPASSWORD=${POSTGRES_PASSWORD} psql --host=${POSTGRES_HOST} --dbname=${POSTGRES_DB} --username=${POSTGRES_USER}" -}}
{{- $tasks := (list
  (printf "%s -c \"ALTER DATABASE ${POSTGRES_DB} REFRESH COLLATION VERSION;\"" $psql)
) }}

workload:
{{- include "ix.v1.common.app.postgres" (dict "secretName" "postgres-creds"
                                              "resources" .Values.resources
                                              "imageSelector" "pgvectorImage"
                                              "preUpgradeTasks" $tasks
                                              "ixChartContext" .Values.ixChartContext) | nindent 2 }}
{{- end -}}
