{{- define "briefkasten.service" -}}
service:
  briefkasten:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: briefkasten
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.briefkastenNetwork.webPort }}
        nodePort: {{ .Values.briefkastenNetwork.webPort }}
        targetSelector: briefkasten
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
