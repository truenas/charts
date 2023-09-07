{{- define "n8n.workload" -}}
workload:
  n8n:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.n8nNetwork.hostNetwork }}
      containers:
        n8n:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          envFrom:
            - secretRef:
                name: n8n-creds
            - configMapRef:
                name: n8n-config
          {{ with .Values.n8nConfig.additionalEnvs }}
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
              path: /healthz
              port: {{ .Values.n8nNetwork.webPort }}
            readiness:
              enabled: true
              type: http
              path: /healthz
              port: {{ .Values.n8nNetwork.webPort }}
            startup:
              enabled: true
              type: http
              path: /healthz
              port: {{ .Values.n8nNetwork.webPort }}
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 1000
                                                        "GID" 1000
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "02-redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "03-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
