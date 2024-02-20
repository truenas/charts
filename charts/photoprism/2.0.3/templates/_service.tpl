{{- define "photoprism.service" -}}
service:
  photoprism:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: photoprism
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.photoprismNetwork.webPort }}
        nodePort: {{ .Values.photoprismNetwork.webPort }}
        targetSelector: photoprism
{{- end -}}
