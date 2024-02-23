{{- define "paperless.workload" -}}
workload:
  paperless:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.paperlessNetwork.hostNetwork }}
      containers:
        paperless:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETGID
                - SETUID
          envFrom:
            - secretRef:
                name: paperless-creds
            - configMapRef:
                name: paperless-config
          {{ with .Values.paperlessConfig.additionalEnvs }}
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
              port: {{ .Values.paperlessNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.paperlessNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.paperlessNetwork.webPort }}
              path: /
              spec:
                initialDelaySeconds: 30
                failureThreshold: 180
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.paperlessID.user
                                                        "GID" .Values.paperlessID.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "02-redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "03-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
