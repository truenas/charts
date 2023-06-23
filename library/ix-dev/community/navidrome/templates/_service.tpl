{{- define "navidrome.persistence" -}}
service:
  navidrome:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: navidrome
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.navidromeNetwork.webPort }}
        nodePort: {{ .Values.navidromeNetwork.webPort }}
        targetSelector: navidrome
{{- end -}}
