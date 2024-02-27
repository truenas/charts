{{- define "es.workload" -}}
workload:
  elasticsearch:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        elasticsearch:
          enabled: true
          primary: true
          imageSelector: elasticSearchImage
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
            readOnlyRootFilesystem: false
          env:
            ES_SETTING_HTTP_PORT: 9200
            ELASTIC_PASSWORD: changeme
            ES_SETTING_DISCOVERY_TYPE: single-node
            ES_SETTING_XPACK_SECURITY_ENABLED: true
            ES_SETTING_XPACK_SECURITY_TRANSPORT_SSL_ENABLED: false
            ES_SETTING_XPACK_SECURITY_HTTP_SSL_ENABLED: false
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              path: /_cluster/health?local=true
              port: 9200
              httpHeaders:
                Authorization: Basic {{ printf "elastic:%s" "changeme" | b64enc }}
            readiness:
              enabled: true
              type: http
              path: /_cluster/health?local=true
              port: 9200
              httpHeaders:
                Authorization: Basic {{ printf "elastic:%s" "changeme" | b64enc }}
            startup:
              enabled: true
              type: http
              path: /_cluster/health?local=true
              port: 9200
              httpHeaders:
                Authorization: Basic {{ printf "elastic:%s" "changeme" | b64enc }}
{{- end -}}
