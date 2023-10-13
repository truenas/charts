{{- define "distribution.configuration" -}}
configmap:
  distribution-config:
    enabled: true
    data:
      REGISTRY_HTTP_ADDR: {{ printf "0.0.0.0:%s" .Values.distributionNetwork.apiPort }}
      {{- if .Values.distributionNetwork.certificateID }}
      REGISTRY_HTTP_TLS_CERTIFICATE: /certs/tls.crt
      REGISTRY_HTTP_TLS_KEY: /certs/tls.key
      {{- end }}

secret:
  distribution-creds:
    enabled: true
    data:
      KEY: VALUE
{{- end -}}
