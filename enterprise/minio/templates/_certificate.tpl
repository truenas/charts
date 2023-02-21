{{- define "minio.certificate" -}}
minio-cert:
  enabled: true
  labels: {}
  annotations: {}
  id: {{ .Values.minio.certificate_id }}
{{- end -}}
