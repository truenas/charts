{{- define "dashy.service" -}}
service:
  dashy:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: dashy
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.dashyNetwork.webPort }}
        nodePort: {{ .Values.dashyNetwork.webPort }}
        targetSelector: dashy
{{- end -}}
