{{- define "pal.workload" -}}
workload:
  pal:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        pal:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.palRunAs.user }}
            runAsGroup: {{ .Values.palRunAs.group }}
          env:
            PLEX_URL: {{ .Values.palConfig.plexURL }}
            PLEX_TOKEN: {{ .Values.palConfig.plexToken }}
            CONTAINERIZED: "true"
          {{ with .Values.palConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          # Port is only for health checks
          # No web interface is available.
          probes:
            liveness:
              enabled: {{ not .Values.ci }}
              type: http
              port: 9880
              path: /health
            readiness:
              enabled: {{ not .Values.ci }}
              type: http
              port: 9880
              path: /health
            startup:
              enabled: {{ not .Values.ci }}
              type: http
              port: 9880
              path: /health
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.palRunAs.user
                                                        "GID" .Values.palRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
