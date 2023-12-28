{{- define "fscrawler.service" -}}
  {{- if .Values.fscrawlerNetwork.enableRestApiService }}
service:
  fscrawler:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: fscrawler
    ports:
      rest:
        enabled: true
        primary: true
        port: {{ .Values.fscrawlerNetwork.restPort }}
        nodePort: {{ .Values.fscrawlerNetwork.restPort }}
        targetSelector: fscrawler
  {{- end -}}
{{- end -}}
