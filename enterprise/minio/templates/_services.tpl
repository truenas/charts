{{- define "minio.services" -}}
minio:
  enabled: true
  primary: true
  type: NodePort
  targetSelector: minio
  ports:
    api:
      enabled: true
      primary: true
      port: {{ .Values.minio.network.api_port }}
      nodePort: {{ .Values.minio.network.api_port }}
      targetSelector: minio
    webui:
      enabled: true
      port: {{ .Values.minio.network.web_port }}
      nodePort: {{ .Values.minio.network.web_port }}
      targetSelector: minio
{{- end -}}
