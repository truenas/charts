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
            runAsUser: {{ .Values.joplinRunAs.user }}
            runAsGroup: {{ .Values.joplinRunAs.group }}
          env:
            APP_PORT: {{ .Values.joplinNetwork.webPort }}
            #TODO: Adapt portal to parse the baseURL
            #TODO: Probably have to hardcode pod's hostname for CI runs to have a valid URL
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
            readiness:
              enabled: true
              type: http
              port: {{ .Values.joplinNetwork.webPort }}
              path: /api/ping
            startup:
              enabled: true
              type: http
              port: {{ .Values.joplinNetwork.webPort }}
              path: /api/ping
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
