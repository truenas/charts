{{- define "frigate.workload" -}}
workload:
  frigate:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.frigateNetwork.hostNetwork }}
      containers:
        frigate:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
          {{ with .Values.frigateConfig.additionalEnvs }}
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
              port: "{{ .Values.frigateNetwork.webPort }}"
              path: /api
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.frigateNetwork.webPort }}"
              path: /api
            startup:
              enabled: true
              type: http
              port: "{{ .Values.frigateNetwork.webPort }}"
              path: /api
      initContainers:
        01-init:
          enabled: true
          type: init
          imageSelector: bashImage
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          command:
            - /bin/sh
          args:
            - -c
            - |
              if [ ! -f /config/config.yml ]; then
                {
                  echo 'mqtt:'
                  echo '  enabled: false'
                  echo 'cameras:'
                  echo '  dummy:'
                  echo '    enabled: false'
                  echo '    ffmpeg:'
                  echo '      inputs:'
                  echo '        - path: rtsp://127.0.0.1:554/rtsp'
                  echo '          roles:'
                  echo '            - detect'
                } > /config/config.yml
              fi
{{- end -}}
