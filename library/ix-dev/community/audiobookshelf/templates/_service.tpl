{{- define "audiobookshelf.service" -}}
service:
  audiobookshelf:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: audiobookshelf
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.audiobookshelfNetwork.webPort }}
        nodePort: {{ .Values.audiobookshelfNetwork.webPort }}
        targetSelector: audiobookshelf
{{- end -}}
