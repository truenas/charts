{{- define "sabnzbd.service" -}}
service:
  sabnzbd:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: sabnzbd
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.sabnzbdNetwork.webPort }}
        nodePort: {{ .Values.sabnzbdNetwork.webPort }}
        targetSelector: sabnzbd
{{- end -}}
