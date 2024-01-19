{{- define "kavita.service" -}}
service:
  kavita:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: kavita
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.kavitaNetwork.webPort }}
        nodePort: {{ .Values.kavitaNetwork.webPort }}
        targetPort: 5000
        targetSelector: kavita
{{- end -}}
