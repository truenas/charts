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
          imageSelector: {{ .Values.frigateConfig.imageSelector | default "image" }}
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            {{- if .Values.frigateConfig.mountUSBBus }}
            privileged: true
            allowPrivilegeEscalation: true
            {{- end }}
            capabilities:
              add:
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETUID
                - SETGID
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
              port: 5000
              path: /api
            readiness:
              enabled: true
              type: http
              port: 5000
              path: /api
            startup:
              enabled: true
              type: http
              port: 5000
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
  {{- with .Values.frigateGPU }}
scaleGPU:
    {{- range $key, $value := . }}
  - gpu:
      {{ $key }}: {{ $value }}
    targetSelector:
      frigate:
        - frigate
    {{- end }}
  {{- end -}}
{{- end -}}
