{{- define "distribution.configuration" -}}
configmap:
  distribution-config:
    enabled: true
    data:
      REGISTRY_HTTP_ADDR: {{ printf "0.0.0.0:%s" .Values.distributionNetwork.apiPort }}

secret:
  distribution-creds:
    enabled: true
    data:
      KEY: VALUE
{{- end -}}
