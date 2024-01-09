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
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          envFrom:
            - secretRef:
                name: invidious-creds
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
              type: http
              path: /api/v1/comments/jNQXAC9IVRw
              port: {{ .Values.invidiousNetwork.webPort }}
            readiness:
              enabled: true
              type: http
              path: /api/v1/comments/jNQXAC9IVRw
              port: {{ .Values.invidiousNetwork.webPort }}
            startup:
              enabled: true
              type: http
              path: /api/v1/comments/jNQXAC9IVRw
              port: {{ .Values.invidiousNetwork.webPort }}
      initContainers:
        {{- include "ix.v1.common.app.postgresWait" (dict "name" "01-postgres-wait"
                                                          "secretName" "postgres-creds") | nindent 8 }}
        02-fetch-seed:
          enabled: {{ .Release.IsInstall }}
          type: init
          imageSelector: gitImage
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - SETGID
                - SETUID
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
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
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
{{- end -}}
