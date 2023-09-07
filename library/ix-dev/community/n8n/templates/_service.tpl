{{- define "n8n.service" -}}
service:
  n8n:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: n8n
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.n8nNetwork.webPort }}
        nodePort: {{ .Values.n8nNetwork.webPort }}
        targetSelector: n8n
  # Redis
  redis:
    enabled: true
    type: ClusterIP
    targetSelector: redis
    ports:
      redis:
        enabled: true
        primary: true
        port: 6379
        targetPort: 6379
        targetSelector: redis
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
