{{- define "filebrowser.service" -}}
service:
  filebrowser:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: filebrowser
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.filebrowserNetwork.webPort }}
        nodePort: {{ .Values.filebrowserNetwork.webPort }}
        targetSelector: filebrowser
{{- end -}}
