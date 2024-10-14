{{- define "nodered.service" -}}
service:
  nodered:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: nodered
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.noderedNetwork.webPort }}
        nodePort: {{ .Values.noderedNetwork.webPort }}
        targetSelector: nodered
{{- end -}}
