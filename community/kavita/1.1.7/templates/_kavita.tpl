{{- define "kavita.workload" -}}
workload:
  kavita:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        kavita:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          {{ with .Values.kavitaConfig.additionalEnvs }}
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
              port: 5000
              path: /api/health
            readiness:
              enabled: true
              type: http
              port: 5000
              path: /api/health
            startup:
              enabled: true
              type: http
              port: 5000
              path: /api/health
{{- end -}}
