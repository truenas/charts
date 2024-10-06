{{- define "tmm.service" -}}
service:
  tmm:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: tmm
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.tmmNetwork.webPort }}
        nodePort: {{ .Values.tmmNetwork.webPort }}
        targetPort: 4000
        targetSelector: tmm
{{- end -}}
