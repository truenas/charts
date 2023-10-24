{{- define "pigallery.service" -}}
service:
  pigallery:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: pigallery
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.pigalleryNetwork.webPort }}
        nodePort: {{ .Values.pigalleryNetwork.webPort }}
        targetSelector: pigallery
{{- end -}}
