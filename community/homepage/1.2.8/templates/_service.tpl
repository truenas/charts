{{- define "homepage.service" -}}
service:
  homepage:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: homepage
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.homepageNetwork.webPort }}
        nodePort: {{ .Values.homepageNetwork.webPort }}
        targetSelector: homepage
{{- end -}}
