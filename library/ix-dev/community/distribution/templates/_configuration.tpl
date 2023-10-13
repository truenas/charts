{{- define "distribution.configuration" -}}
configmap:
  distribution-config:
    enabled: true
    data:
      REGISTRY_HTTP_ADDR: {{ printf "0.0.0.0:%s" .Values.distributionNetwork.apiPort }}
      REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /var/lib/registry
      {{- if .Values.distributionNetwork.certificateID }}
      REGISTRY_HTTP_TLS_CERTIFICATE: /certs/tls.crt
      REGISTRY_HTTP_TLS_KEY: /certs/tls.key
      {{- end }}

secret:
  distribution-creds:
    enabled: true
    data:
      htpasswd: |
        {{- range $idx, $v := .Values.distributionConfig.basicAuthUsers }}
        {{- htpasswd $v.user $v.pass | nindent 8 }}
        {{- end -}}
{{- end -}}
