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
      {{- if .Values.distributionConfig.basicAuthUsers }}
      REGISTRY_HTPASSWD_REALM: basic-realm
      REGISTRY_HTPASSWD_PATH: /auth/htpasswd
      {{- end -}}

{{- if .Values.distributionConfig.basicAuthUsers }}
secret:
  distribution-creds:
    enabled: true
    data:
      htpasswd: |
        {{- range $idx, $v := .Values.distributionConfig.basicAuthUsers }}
        {{- htpasswd $v.user $v.pass | nindent 8 }}
        {{- end -}}
{{- end -}}
{{- end -}}
