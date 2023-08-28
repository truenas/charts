{{- define "firefly.importer" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) }}
workload:
  firefly-importer:
    enabled: true
    type: Deployment
    podSpec:
      containers:
        firefly-importer:
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
                name: import-config
          {{ with .Values.fireflyConfig.additionalImporterEnvs }}
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
