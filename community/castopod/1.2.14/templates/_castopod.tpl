{{- define "castopod.workload" -}}
workload:
  castopod:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        castopod:
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
                name: castopod-creds
            - configMapRef:
                name: castopod-config
          {{ with .Values.castopodConfig.additionalEnvs }}
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
              port: 9000
            readiness:
              enabled: true
              type: tcp
              port: 9000
            startup:
              enabled: true
              type: tcp
              port: 9000
              spec:
                initialDelaySeconds: 30
                failureThreshold: 180
      initContainers:
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "01-redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.mariadbWait" (dict "name" "02-mariadb-wait"
                                                       "secretName" "mariadb-creds") | nindent 8 }}
{{- end -}}
