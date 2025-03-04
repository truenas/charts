{{- define "pgadmin.service" -}}
service:
  pgadmin:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: pgadmin
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.pgadminNetwork.webPort }}
        nodePort: {{ .Values.pgadminNetwork.webPort }}
        targetSelector: pgadmin
{{- end -}}
