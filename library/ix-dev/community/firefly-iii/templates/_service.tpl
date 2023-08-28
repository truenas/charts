{{- define "firefly.service" -}}
service:
  firefly:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: firefly
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.fireflyNetwork.webPort }}
        nodePort: {{ .Values.fireflyNetwork.webPort }}
        targetPort: 8080
        targetSelector: firefly
  # Postgres
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
