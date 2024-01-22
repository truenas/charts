{{- define "briefkasten.workload" -}}
workload:
  briefkasten:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.briefkastenNetwork.hostNetwork }}
      containers:
        briefkasten:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 1001
            runAsGroup: 1001
            readOnlyRootFilesystem: false
          envFrom:
            - secretRef:
                name: briefkasten
            - configMapRef:
                name: briefkasten
          {{ with .Values.briefkastenConfig.additionalEnvs }}
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
              port: {{ .Values.briefkastenNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.briefkastenNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.briefkastenNetwork.webPort }}
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 1001
                                                        "GID" 1001
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "02-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
        02-migrate-db:
          enabled: true
          type: init
          imageSelector: image
          securityContext:
            runAsUser: 1001
            runAsGroup: 1001
            readOnlyRootFilesystem: false
          envFrom:
            - secretRef:
                name: briefkasten
            - configMapRef:
                name: briefkasten
          command:
            - /bin/sh
            - -c
            - |
              echo "Migrating database"
              pnpm db:push || (echo "DB migration failed..." && exit 1)
              echo "DB migration successful. Application will now start"
              exit 0
{{- end -}}
