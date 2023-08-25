{{- define "pgadmin.validation" -}}
  {{- if not .Values.pgadminConfig.adminEmail -}}
    {{- fail "pgAdmin - Admin Email is required" -}}
  {{- end -}}
  {{- if not .Values.pgadminConfig.adminPassword -}}
    {{- fail "pgAdmin - Admin Password is required" -}}
  {{- end -}}
{{- end -}}
