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
      # TODO: Host https://registry.surge.sh/about/configuration/#http
      # REGISTRY_HTTP_HOST:
      {{- end }}
      {{- if .Values.distributionConfig.basicAuthUsers }}
      REGISTRY_HTPASSWD_REALM: basic-realm
      REGISTRY_HTPASSWD_PATH: /auth/htpasswd
      {{- end -}}

  {{- $secretKey := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-distribution" $fullname)) -}}
    {{- $secretKey = ((index .data "REGISTRY_HTTP_SECRET") | b64dec) -}}
  {{- end -}}

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
