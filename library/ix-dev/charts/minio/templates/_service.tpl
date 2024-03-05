{{- define "minio.service" -}}
service:
  minio:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: minio
    ports:
      console:
        enabled: true
        primary: true
        port: {{ .Values.minioNetwork.consolePort }}
        nodePort: {{ .Values.minioNetwork.consolePort }}
        targetSelector: minio
      api:
        enabled: true
        port: {{ .Values.minioNetwork.apiPort }}
        nodePort: {{ .Values.minioNetwork.apiPort }}
        targetSelector: minio
  # TODO: Conditionally enable (logsearch)
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}
{{- end -}}
