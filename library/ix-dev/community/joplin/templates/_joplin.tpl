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
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          env:
            APP_PORT: {{ .Values.joplinNetwork.webPort }}
            #TODO: Adapt portal to parse the baseURL
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
                Host: '{{ .Values.joplinConfig.baseUrl | replace "https://" "" | replace "http://" "" }}'
            readiness:
              enabled: true
              type: http
              port: {{ .Values.joplinNetwork.webPort }}
              path: /api/ping
              httpHeaders:
                Host: '{{ .Values.joplinConfig.baseUrl | replace "https://" "" | replace "http://" "" }}'
            startup:
              enabled: true
              type: http
              port: {{ .Values.joplinNetwork.webPort }}
              path: /api/ping
              httpHeaders:
                Host: '{{ .Values.joplinConfig.baseUrl | replace "https://" "" | replace "http://" "" }}'
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
