{{- define "joplin.workload" -}}
workload:
  joplin:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.joplinNetwork.hostNetwork }}
      containers:
        joplin:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 1001
            runAsGroup: 1001
            readOnlyRootFilesystem: false
          env:
            APP_PORT: {{ .Values.joplinNetwork.webPort }}
            APP_BASE_URL: {{ .Values.joplinConfig.baseUrl }}
            DB_CLIENT: pg
            POSTGRES_PORT: 5432
            POSTGRES_HOST:
              secretKeyRef:
                name: postgres-creds
                key: POSTGRES_HOST
            POSTGRES_DATABASE:
              secretKeyRef:
                name: postgres-creds
                key: POSTGRES_DB
            POSTGRES_USER:
              secretKeyRef:
                name: postgres-creds
                key: POSTGRES_USER
            POSTGRES_PASSWORD:
              secretKeyRef:
                name: postgres-creds
                key: POSTGRES_PASSWORD
          {{ with .Values.joplinConfig.additionalEnvs }}
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
              port: {{ .Values.joplinNetwork.webPort }}
              path: /api/ping
              httpHeaders:
                Host: '{{ .Values.joplinConfig.baseUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/" }}'
            readiness:
              enabled: true
              type: http
              port: {{ .Values.joplinNetwork.webPort }}
              path: /api/ping
              httpHeaders:
                Host: '{{ .Values.joplinConfig.baseUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/" }}'
            startup:
              enabled: true
              type: http
              port: {{ .Values.joplinNetwork.webPort }}
              path: /api/ping
              httpHeaders:
                Host: '{{ .Values.joplinConfig.baseUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/" }}'
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                    "UID" 1001
                                                    "GID" 1001
                                                    "mode" "check"
                                                    "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
