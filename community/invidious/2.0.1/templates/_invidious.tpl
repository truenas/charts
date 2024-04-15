{{- define "invidious.workload" -}}
workload:
  invidious:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        invidious:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
          env:
            INVIDIOUS_CONFIG_FILE: /config/config.yaml
          {{ with .Values.invidiousConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: tcp
              port: {{ .Values.invidiousNetwork.webPort }}
            readiness:
              enabled: true
              type: tcp
              port: {{ .Values.invidiousNetwork.webPort }}
            startup:
              enabled: true
              type: tcp
              port: {{ .Values.invidiousNetwork.webPort }}
      initContainers:
        {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 1000
                                                        "GID" 1000
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
        {{- include "ix.v1.common.app.postgresWait" (dict "name" "01-postgres-wait"
                                                          "secretName" "postgres-creds") | nindent 8 }}
        02-fetch-seed:
          enabled: {{ .Release.IsInstall }}
          type: init
          imageSelector: gitImage
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
          command:
            - /bin/sh
            - -c
          args:
            - |
              echo "Fetching DB Seed..."
              mkdir -p /shared/invidious
              cd /shared/invidious

              git init && \
              git remote add invidious https://github.com/iv-org/invidious.git && \
              git fetch invidious && \
              # Fetch config and docker dirs
              git checkout invidious/master -- docker config

              # Move config into docker dir
              echo "Preparing directory structure..."
              mv -fv config docker
              echo "Done."
        03-init-db:
          enabled: {{ .Release.IsInstall }}
          type: init
          imageSelector: postgresImage
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
          envFrom:
            - secretRef:
                name: postgres-creds
          command:
            - /bin/sh
            - -c
          args:
            - |
              echo "Initializing Invidious DB..."
              cd /shared/invidious/docker
              ./init-invidious-db.sh
              echo "Done."
        04-init-config:
          enabled: true
          type: init
          imageSelector: image
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
          command:
            - /bin/sh
            - -c
          args:
            - |
              if [ ! -f /config/config.yaml ]; then
                echo "Initializing Invidious Config..."
                cp -v /invidious/config/config.yml /config/config.yaml
                exit 0
              fi
              echo "Config already exists, skipping."
        05-update-config:
          enabled: true
          type: init
          imageSelector: yqImage
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
            readOnlyRootFilesystem: false
          command: /setup/config.sh
{{- end -}}
