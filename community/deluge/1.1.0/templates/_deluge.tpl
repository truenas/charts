{{- define "deluge.workload" -}}
workload:
  deluge:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      securityContext:
        fsGroup: {{ .Values.delugeID.group }}
      hostNetwork: {{ .Values.delugeNetwork.hostNetwork }}
      containers:
        deluge:
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
                - DAC_OVERRIDE
                - FOWNER
                - SETGID
                - SETUID
          {{ with .Values.delugeConfig.additionalEnvs }}
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
              port: 8112
              path: /
            readiness:
              enabled: true
              type: http
              port: 8112
              path: /
            startup:
              enabled: true
              type: http
              port: 8112
              path: /
      initContainers:
        config:
          enabled: true
          type: init
          imageSelector: image
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
                - SETGID
                - SETUID
          command:
            - python
          args:
            - -c
            - |
              from deluge.config import Config
              import os
              import shutil
              if not os.path.exists('/config/core.conf'):
                print('Copying default config')
                shutil.copyfile('/defaults/core.conf', '/config/core.conf')
              print('Loading config')
              config = Config('/config/core.conf')
              print('Setting listen ports to {{ .Values.delugeNetwork.torrentPort }}')
              config['listen_ports'] = [{{ .Values.delugeNetwork.torrentPort }}, {{ .Values.delugeNetwork.torrentPort }}]
              print('Saving config')
              Config.save(config)
              print('Done')
{{- end -}}
