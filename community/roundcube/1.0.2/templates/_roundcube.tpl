{{- define "roundcube.workload" -}}
workload:
  roundcube:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        roundcube:
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
                name: roundcube-creds
            - configMapRef:
                name: roundcube-config
          {{ with .Values.roundcubeConfig.additionalEnvs }}
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
              path: /?ping=ping
              port: 80
            readiness:
              enabled: true
              type: http
              path: /?ping=ping
              port: 80
            startup:
              enabled: true
              type: http
              path: /?ping=ping
              port: 80
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "01-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
