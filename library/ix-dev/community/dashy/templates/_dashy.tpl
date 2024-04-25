{{- define "dashy.workload" -}}
workload:
  dashy:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.dashyNetwork.hostNetwork }}
      containers:
        dashy:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          env:
            {{- $protocol := "http" -}}
            {{- if .Values.dashyNetwork.certificateID }}
              {{- $protocol = "https" }}
            SSL_PRIV_KEY_PATH: /cert/tls.key
            SSL_PUB_KEY_PATH: /cert/tls.crt
            SSL_PORT: {{ .Values.dashyNetwork.webPort }}
            {{- else }}
            PORT: {{ .Values.dashyNetwork.webPort }}
            {{- end }}
            NODE_ENV: production
            IS_DOCKER: "true"
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
              type: {{ $protocol }}
              port: {{ .Values.dashyNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: {{ $protocol }}
              port: {{ .Values.dashyNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: {{ $protocol }}
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
          command:
            - /bin/sh
          args:
            - -c
            - |
              if [ -z "$(ls -A /data)" ]; then
                echo "App directory is empty, copying default files"
                cp -r /app/user-data/* /data/
                exit 0
              fi

              echo "App directory is not empty, skipping copy"
              exit 0
{{- end -}}
