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
        targetPort: 80
        targetSelector: audiobookshelf
{{- end -}}
