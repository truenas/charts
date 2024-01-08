{{- define "roundcube.workload" -}}
workload:
  roundube:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        roundube:
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
          envFrom:
            - secretRef:
                name: roundube-creds
            - configMapRef:
                name: roundube-config
          {{ with .Values.roundubeConfig.additionalEnvs }}
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
