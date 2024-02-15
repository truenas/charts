{{- define "autobrr.service" -}}
service:
  autobrr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: autobrr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.autobrrNetwork.webPort }}
        nodePort: {{ .Values.autobrrNetwork.webPort }}
        targetSelector: autobrr
{{- end -}}
