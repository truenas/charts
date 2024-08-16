{{- define "vikunja.api" -}}
workload:
  vikunja-api:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        vikunja-api:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.vikunjaRunAs.user }}
            runAsGroup: {{ .Values.vikunjaRunAs.group }}
            runAsNonRoot: false
          env:
            # Make vikunja skip user creation
            PUID: ""
            PGID: ""
          envFrom:
            - secretRef:
                name: vikunja-creds
            - configMapRef:
                name: vikunja-api
          {{ with .Values.vikunjaConfig.additionalEnvs }}
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
              port: {{ .Values.vikunjaPorts.api }}
              path: /health
            readiness:
              enabled: true
              type: http
              port: {{ .Values.vikunjaPorts.api }}
              path: /health
            startup:
              enabled: true
              type: http
              port: {{ .Values.vikunjaPorts.api }}
              path: /health
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.vikunjaRunAs.user
                                                        "GID" .Values.vikunjaRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "02-redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "03-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
