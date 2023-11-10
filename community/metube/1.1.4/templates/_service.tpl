{{- define "metube.service" -}}
service:
  metube:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: metube
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.metubeNetwork.webPort }}
        nodePort: {{ .Values.metubeNetwork.webPort }}
        targetSelector: metube
{{- end -}}
