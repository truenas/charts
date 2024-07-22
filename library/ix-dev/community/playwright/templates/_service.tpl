{{- define "playwright.service" -}}
service:
  playwright:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: playwright
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.playwrightNetwork.webPort }}
        nodePort: {{ .Values.playwrightNetwork.webPort }}
        targetSelector: playwright
{{- end -}}
