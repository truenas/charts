{{- define "kapowarr.service" -}}
service:
  kapowarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: kapowarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.kapowarrNetwork.webPort }}
        nodePort: {{ .Values.kapowarrNetwork.webPort }}
        targetPort: 5656
        targetSelector: kapowarr
{{- end -}}
