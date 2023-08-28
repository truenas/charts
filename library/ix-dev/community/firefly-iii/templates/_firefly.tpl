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
          envFrom:
            - secretRef:
                name: firefly-config
          {{ with .Values.fireflyConfig.additionalEnvs }}
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
              path: /health
              port: {{ .Values.fireflyNetwork.webPort }}
            readiness:
              enabled: true
              type: http
              path: /health
              port: {{ .Values.fireflyNetwork.webPort }}
            startup:
              enabled: true
              type: http
              path: /health
              port: {{ .Values.fireflyNetwork.webPort }}
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
