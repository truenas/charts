{{- define "whoogle.service" -}}
service:
  whoogle:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: whoogle
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.whoogleNetwork.webPort }}
        nodePort: {{ .Values.whoogleNetwork.webPort }}
        targetSelector: whoogle
{{- end -}}
