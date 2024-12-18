{{- define "actual.workload" -}}
workload:
  actual:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.actualNetwork.hostNetwork }}
      containers:
        actual:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.actualRunAs.user }}
            runAsGroup: {{ .Values.actualRunAs.group }}
          env:
            ACTUAL_PORT: {{ .Values.actualNetwork.webPort }}
            ACTUAL_HOSTNAME: 0.0.0.0
            ACTUAL_SERVER_FILES: /data/server-files
            ACTUAL_USER_FILES: /data/user-files
            NODE_ENV: production
            {{- if .Values.actualNetwork.certificateID }}
            ACTUAL_HTTPS_KEY: /certs/tls.key
            ACTUAL_HTTPS_CERT: /certs/tls.crt
            {{- end }}
          {{ with .Values.actualConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          {{- $proto := "http" -}}
          {{- if .Values.actualNetwork.certificateID -}}
            {{- $proto = "https" -}}
          {{- end }}
          probes:
            liveness:
              enabled: true
              type: {{ $proto }}
              port: {{ .Values.actualNetwork.webPort }}
              path: /health
            readiness:
              enabled: true
              type: {{ $proto }}
              port: {{ .Values.actualNetwork.webPort }}
              path: /health
            startup:
              enabled: true
              type: {{ $proto }}
              port: {{ .Values.actualNetwork.webPort }}
              path: /health
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.actualRunAs.user
                                                        "GID" .Values.actualRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
