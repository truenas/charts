{{- define "castopod.web.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $backend := printf "%s-castopod-api" $fullname }}
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
            capabilities:
              add:
                - CHOWN
                - SETGID
                - SETUID
          env:
            CP_APP_HOSTNAME: {{ $backend }}
            CP_TIMEOUT: {{ .Values.castopodConfig.webTimeout }}
            CP_MAX_BODY_SIZE: {{ printf "%vM" .Values.castopodConfig.webMaxBodySize }}
          probes:
            liveness:
              enabled: true
              type: http
              path: /health
              port: 80
            readiness:
              enabled: true
              type: http
              path: /health
              port: 80
            startup:
              enabled: true
              type: http
              path: /health
              port: 80
      initContainers:
        wait-server:
          enabled: true
          type: init
          imageSelector: bashImage
          command:
            - bash
          args:
            - -c
            - |
              echo "Waiting for backend to be ready at [{{ $backend }}:9000]"
              until nc -vz -w 5 "{{ $backend }}" 9000; do
                echo "Waiting for backend to be ready at [{{ $backend }}:9000]"
                sleep 1
              done
{{- end -}}
