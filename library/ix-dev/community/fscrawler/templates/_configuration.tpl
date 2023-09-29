{{- define "fscrawler.configuration" -}}
configmap:
  example-config:
    enabled: true
    data:
      # A default config file that users will need to edit
      _settings.example.yaml: |
        # It will be updated automatically on every start based on the configuration
        name: {{ .Values.fscrawlerConfig.jobName }}
        elasticsearch:
          username: elastic
          password: <password>
          nodes:
            - url: http://<node_ip>:<port>
        {{- if .Values.fscrawlerNetwork.enableRestApiService }}
        rest:
          url: http://0.0.0.0:{{ .Values.fscrawlerNetwork.restPort }}/fscrawler
          # Optionally
          # enable_cors: true/false
        {{- end -}}
{{- end -}}
