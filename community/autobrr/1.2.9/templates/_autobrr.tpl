{{- define "autobrr.workload" -}}
workload:
  autobrr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.autobrrNetwork.hostNetwork }}
      containers:
        autobrr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.autobrrRunAs.user }}
            runAsGroup: {{ .Values.autobrrRunAs.group }}
          env:
            AUTOBRR__PORT: {{ .Values.autobrrNetwork.webPort }}
            AUTOBRR__HOST: "0.0.0.0"
          {{ with .Values.autobrrConfig.additionalEnvs }}
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
              port: {{ .Values.autobrrNetwork.webPort }}
              path: /api/healthz/liveness
            readiness:
              enabled: true
              type: http
              port: {{ .Values.autobrrNetwork.webPort }}
              path: /api/healthz/readiness
            startup:
              enabled: true
              type: http
              port: {{ .Values.autobrrNetwork.webPort }}
              path: /api/healthz/readiness
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.autobrrRunAs.user
                                                        "GID" .Values.autobrrRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
