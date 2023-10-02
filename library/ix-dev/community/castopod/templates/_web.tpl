{{- define "castopod.web.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) }}
workload:
  web:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        web:
          enabled: true
          primary: true
          imageSelector: webImage
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          #   capabilities:
          #     add:
          #       - CHOWN
          #       - DAC_OVERRIDE
          #       - FOWNER
          #       - NET_BIND_SERVICE
          #       - SETGID
          #       - SETUID
          env:
            CP_HOST_BACK: {{ printf "%s-castopod" $fullname }}
          probes:
            liveness:
              enabled: false
              type: http
              path: /
              port: 8000
            readiness:
              enabled: false
              type: http
              path: /
              port: 8000
            startup:
              enabled: false
              type: http
              path: /
              port: 8000
      initContainers:
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "01-redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.mariadbWait" (dict "name" "02-mariadb-wait"
                                                       "secretName" "mariadb-creds") | nindent 8 }}
{{- end -}}
