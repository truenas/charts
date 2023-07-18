{{- define "readarr.service" -}}
service:
  readarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: readarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.readarrNetwork.webPort }}
        nodePort: {{ .Values.readarrNetwork.webPort }}
        targetSelector: readarr
{{- end -}}
