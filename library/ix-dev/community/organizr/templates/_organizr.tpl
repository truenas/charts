{{- define "organizr.workload" -}}
workload:
  organizr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      securityContext:
        fsGroup: {{ .Values.organizrID.group }}
      containers:
        organizr:
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
                - DAC_OVERRIDE
                - SETGID
                - SETUID
          fixedEnv:
            PUID: {{ .Values.organizrID.user }}
          {{ with .Values.organizrConfig.additionalEnvs }}
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
              port: 80
              path: /api/v2/ping
            readiness:
              enabled: true
              type: http
              port: 80
              path: /api/v2/ping
            startup:
              enabled: true
              type: http
              port: 80
              path: /api/v2/ping
{{- end -}}
