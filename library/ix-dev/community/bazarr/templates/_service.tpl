{{- define "bazarr.service" -}}
service:
  bazarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: bazarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.bazarrNetwork.webPort }}
        nodePort: {{ .Values.bazarrNetwork.webPort }}
        targetSelector: bazarr
{{- end -}}
