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
              path: /
            readiness:
              enabled: true
              type: http
              port: 80
              path: /
            startup:
              enabled: true
              type: http
              port: 80
              path: /
{{- end -}}
