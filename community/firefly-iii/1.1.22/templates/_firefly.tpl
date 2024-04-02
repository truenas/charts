{{- define "firefly.workload" -}}
workload:
  firefly:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.fireflyNetwork.hostNetwork }}
      containers:
        firefly:
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
                - FOWNER
                - SETUID
                - SETGID
          envFrom:
            - secretRef:
                name: firefly-config
          {{ with .Values.fireflyConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value | quote }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              path: /health
              port: 8080
            readiness:
              enabled: true
              type: http
              path: /health
              port: 8080
            startup:
              enabled: true
              type: http
              path: /health
              port: 8080
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
{{- end -}}
