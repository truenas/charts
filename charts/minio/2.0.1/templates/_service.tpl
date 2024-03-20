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
  {{ if .Values.minioStorage.logSearchApi }}
  log:
    enabled: true
    type: ClusterIP
    targetSelector: logsearchapi
    ports:
      log:
        enabled: true
        port: 8080
        targetPort: 8080
        targetSelector: logsearchapi
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}
  {{ end }}
{{- end -}}
