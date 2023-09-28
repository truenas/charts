{{- define "twofauth.service" -}}
service:
  twofauth:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: twofauth
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.twofauthNetwork.webPort }}
        nodePort: {{ .Values.twofauthNetwork.webPort }}
        targetPort: 8000
        targetSelector: twofauth
{{- end -}}
