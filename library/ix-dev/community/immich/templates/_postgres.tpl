{{- define "postgres.workload" -}}
workload:
{{- include "ix.v1.common.app.postgres" (dict "secretName" "postgres-creds"
                                              "resources" .Values.resources
                                              "imageSelector" "pgvectorImage"
                                              "ixChartContext" .Values.ixChartContext) | nindent 2 }}

{{- end -}}
