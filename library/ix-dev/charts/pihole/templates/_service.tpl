{{- define "pihole.service" -}}
service:
  pihole:
    enabled: true
    primary: true
    type: ClusterIP
    targetSelector: pihole
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.piholeNetwork.webPort }}
        nodePort: {{ .Values.piholeNetwork.webPort }}
        targetSelector: pihole
{{- end -}}
