{{- define "nginx.workload" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
  {{- $ncUrl := printf "http://%s:%v" $fullname .Values.ncNetwork.webPort -}}
  {{- if .Values.ncNetwork.certificateID -}}
    {{- $ncUrl = printf "https://%s:80" $fullname -}}
  {{- end }}
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
                - DAC_OVERRIDE
                - FOWNER
                - NET_BIND_SERVICE
                - NET_RAW

          {{ with .Values.ncConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: https
              port: {{ .Values.ncNetwork.webPort }}
              path: /status.php
              httpHeaders:
                Host: localhost
            readiness:
              enabled: true
              type: https
              port: {{ .Values.ncNetwork.webPort }}
              path: /status.php
              httpHeaders:
                Host: localhost
            startup:
              enabled: true
              type: https
              port: {{ .Values.ncNetwork.webPort }}
              path: /status.php
              httpHeaders:
                Host: localhost
      initContainers:
        01-wait-server:
          enabled: true
          type: init
          imageSelector: bashImage
          command:
            - bash
          args:
            - -c
            - |
              echo "Waiting for [{{ $ncUrl }}]";
              until wget --spider --quiet --timeout=3 --tries=1 {{ $ncUrl }}/status.php;
              do
                echo "Waiting for [{{ $ncUrl }}]";
                sleep 2;
              done
              echo "API is up: {{ $ncUrl }}";
{{- end -}}
