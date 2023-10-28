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
  firefly-importer:
    enabled: {{ .Values.fireflyConfig.enableImporter }}
    type: NodePort
    targetSelector: firefly-importer
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.fireflyNetwork.importerPort }}
        nodePort: {{ .Values.fireflyNetwork.importerPort }}
        targetPort: 8080
        targetSelector: firefly-importer
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
