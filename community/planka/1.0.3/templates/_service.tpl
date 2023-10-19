{{- define "planka.service" -}}
service:
  planka:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: planka
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.plankaNetwork.webPort }}
        nodePort: {{ .Values.plankaNetwork.webPort }}
        targetSelector: planka
  postgres:
    enabled: true
    type: ClusterIP
    targetSelector: postgres
    ports:
      postgres:
        enabled: true
        primary: true
        port: 5432
        targetPort: 5432
        targetSelector: postgres
{{- end -}}
