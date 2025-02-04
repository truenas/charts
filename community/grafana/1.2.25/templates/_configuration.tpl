{{- define "grafana.configuration" -}}
configmap:
  grafana-config:
    enabled: true
    data:
      GF_SERVER_HTTP_PORT: {{ .Values.grafanaNetwork.webPort | quote }}
      GF_PATHS_DATA: /var/lib/grafana
      GF_PATHS_PLUGINS: /var/lib/grafana/plugins
      {{- with .Values.grafanaConfig.plugins }}
      GF_INSTALL_PLUGINS: {{ join "," . }}
      {{- end -}}
      {{- if .Values.grafanaNetwork.certificateID }}
      GF_SERVER_PROTOCOL: https
      GF_SERVER_CERT_FILE: /grafana/certs/tls.crt
      GF_SERVER_CERT_KEY: /grafana/certs/tls.key
        {{- with .Values.grafanaNetwork.rootURL }}
      GF_SERVER_ROOT_URL: {{ . | quote }}
        {{- end -}}
      {{- end }}
{{- end -}}
