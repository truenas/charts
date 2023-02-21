{{- define "minio.config" -}}
enabled: true
data:
  MINIO_VOLUMES: /data
  {{- if .Values.minio.certificate_id -}}
    {{- $domain := (required "Expected non-empty <domain>" .Values.minio.domain) }}
  MINIO_SERVER_URL: {{ printf "https://%s:%s" $domain .Values.minio.api_port }}
  MINIO_BROWSER_REDIRECT_URL: {{ printf "https://%s:%s" $domain .Values.minio.web_port }}
  {{- end -}}
{{- end -}}
