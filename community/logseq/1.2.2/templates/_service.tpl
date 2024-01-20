{{- define "logseq.service" -}}
service:
  logseq:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: logseq
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.logseqNetwork.webPort }}
        nodePort: {{ .Values.logseqNetwork.webPort }}
        targetSelector: logseq
{{- end -}}
