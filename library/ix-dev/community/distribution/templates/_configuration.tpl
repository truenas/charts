{{- define "distribution.configuration" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

{{- $secretKey := randAlphaNum 32 -}}
{{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-distribution" $fullname)) -}}
  {{- $secretKey = ((index .data "REGISTRY_HTTP_SECRET") | b64dec) -}}
{{- end }}

configmap:
  distribution-config:
    enabled: true
    data:
      REGISTRY_HTTP_ADDR: {{ printf "0.0.0.0:%v" .Values.distributionNetwork.apiPort }}
      {{- if .Values.distributionStorage.useFilesystemBackend }}
      REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /var/lib/registry
      {{- end -}}
      {{- if .Values.distributionNetwork.certificateID }}
      REGISTRY_HTTP_TLS_CERTIFICATE: /certs/tls.crt
      REGISTRY_HTTP_TLS_KEY: /certs/tls.key
      {{- end -}}
      {{- if .Values.distributionConfig.basicAuthUsers }}
      REGISTRY_AUTH_HTPASSWD_REALM: basic-realm
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
      {{- end }}

secret:
  distribution-creds:
    enabled: true
    data:
      REGISTRY_HTTP_SECRET: {{ $secretKey }}

  {{- if .Values.distributionConfig.basicAuthUsers }}
  distribution-htpasswd:
    enabled: true
    data:
      htpasswd: |
        {{- range $idx, $v := .Values.distributionConfig.basicAuthUsers }}
        {{- htpasswd $v.user $v.pass | nindent 8 }}
        {{- end -}}
  {{- end -}}
{{- end -}}
