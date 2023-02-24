{{- define "minio.services" -}}
service:
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
  {{- if .Values.logsearch.enabled }}
  logsearch:
    enabled: true
    type: ClusterIP
    targetSelector: logsearch
    ports:
      logsearch:
        enabled: true
        primary: true
        port: 8080
        targetSelector: logsearch
  postgres:
    enabled: true
    type: ClusterIP
    targetSelector: postgres
    ports:
      postgres:
        enabled: true
        primary: true
        port: 5432
        targetSelector: postgres
  {{- end -}}

{{- end -}}
