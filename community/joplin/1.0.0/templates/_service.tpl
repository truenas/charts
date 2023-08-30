{{- define "joplin.service" -}}
service:
  joplin:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: joplin
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.joplinNetwork.webPort }}
        nodePort: {{ .Values.joplinNetwork.webPort }}
        targetSelector: joplin
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
