{{- define "handbrake.service" -}}
service:
  handbrake:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: handbrake
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.handbrakeNetwork.webPort }}
        nodePort: {{ .Values.handbrakeNetwork.webPort }}
        targetSelector: handbrake
      vnc:
        enabled: true
        port: {{ .Values.handbrakeNetwork.vncPort }}
        nodePort: {{ .Values.handbrakeNetwork.vncPort }}
        targetSelector: handbrake
{{- end -}}
