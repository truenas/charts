{{- define "nodered.workload" -}}
workload:
  nodered:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.noderedNetwork.hostNetwork }}
      containers:
        nodered:
          enabled: true
          primary: true
          imageSelector: {{ .Values.noderedConfig.imageSelector }}
          # https://github.com/node-red/node-red-docker/wiki/Permissions-and-Persistence
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
            # TODO: Remove
            readOnlyRootFilesystem: false
          args:
          - -D
          - logging.console.level=trace
          env:
            PORT: {{ .Values.noderedNetwork.webPort }}
            NODE_RED_ENABLE_SAFE_MODE: {{ .Values.noderedConfig.safeMode }}
            NODE_RED_ENABLE_PROJECTS: {{ .Values.noderedConfig.enableProjects }}
          {{ with .Values.noderedConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  sed -i 's/\/\///g' /healthcheck.js
                  node /healthcheck.js
            readiness:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  sed -i 's/\/\///g' /healthcheck.js
                  node /healthcheck.js
            startup:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  sed -i 's/\/\///g' /healthcheck.js
                  node /healthcheck.js
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 1000
                                                        "GID" 1000
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
{{- end -}}
