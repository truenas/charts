{{- define "distribution.service" -}}
service:
  distribution:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: distribution
    ports:
      api:
        enabled: true
        primary: true
        port: {{ .Values.distributionNetwork.apiPort }}
        nodePort: {{ .Values.distributionNetwork.apiPort }}
        targetSelector: distribution
{{- end -}}
