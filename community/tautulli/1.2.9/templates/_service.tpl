{{- define "tautulli.service" -}}
service:
  tautulli:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: tautulli
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.tautulliNetwork.webPort }}
        nodePort: {{ .Values.tautulliNetwork.webPort }}
        targetSelector: tautulli
{{- end -}}
