{{- define "dashy.workload" -}}
workload:
  dashy:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.dashyNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.dashyID.group }}
      containers:
        dashy:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
          fixedEnv:
            PUID: {{ .Values.dashyID.user }}
          env:
            NODE_ENV: production
            IS_DOCKER: "true"
            PORT: {{ .Values.dashyNetwork.webPort }}
          {{ with .Values.dashyConfig.additionalEnvs }}
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
              port: {{ .Values.dashyNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.dashyNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.dashyNetwork.webPort }}
              path: /
      initContainers:
        init-config:
          enabled: true
          type: init
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
          fixedEnv:
            PUID: {{ .Values.dashyID.user }}
          command:
            - /bin/sh
          args:
            - -c
            - |
              if [ -z "$(ls -A /data)" ]; then
                echo "App directory is empty, copying default files"
                cp -r /app/public/* /data/
                exit 0
              fi

              echo "App directory is not empty, skipping copy"
              exit 0
{{- end -}}
