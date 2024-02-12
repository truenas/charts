{{- define "nginx.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
workload:
  nginx:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        nginx:
          enabled: true
          primary: true
          imageSelector: nginxImage
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
          probes:
            liveness:
              enabled: true
              type: https
              path: /robots.txt
              port: {{ .Values.collaboraNetwork.webPort }}
            readiness:
              enabled: true
              type: https
              path: /robots.txt
              port: {{ .Values.collaboraNetwork.webPort }}
            startup:
              enabled: true
              type: https
              path: /robots.txt
              port: {{ .Values.collaboraNetwork.webPort }}
      initContainers:
        wait-collabora:
          enabled: true
          type: init
          imageSelector: bashImage
          command:
            - bash
          args:
            - -c
            - |
              echo "Waiting for collabora to be ready at [{{ $fullname }}:9980]"
              until nc -vz -w 5 "{{ $fullname }}" 9980; do
                echo "Waiting for collabora to be ready at [{{ $fullname }}:9980]"
                sleep 1
              done

{{- end -}}
