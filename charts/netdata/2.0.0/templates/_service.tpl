{{- define "netdata.service" -}}
service:
  netdata:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: netdata
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.netdataNetwork.webPort }}
        nodePort: {{ .Values.netdataNetwork.webPort }}
        targetSelector: netdata
{{- end -}}
