{{- define "freshrss.service" -}}
service:
  freshrss:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: freshrss
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.freshrssNetwork.webPort }}
        nodePort: {{ .Values.freshrssNetwork.webPort }}
        targetSelector: freshrss

  {{/* Database */}}
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
