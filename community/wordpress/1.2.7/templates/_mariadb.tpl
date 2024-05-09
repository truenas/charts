{{- define "wordpress.mariadb.workload" -}}
workload:
{{- include "ix.v1.common.app.mariadb" (dict "secretName" "mariadb-creds"
                                              "resources" .Values.resources
                                              "ixChartContext" .Values.ixChartContext) | nindent 2 }}
{{- end -}}
