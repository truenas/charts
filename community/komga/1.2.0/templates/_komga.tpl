{{- define "komga.workload" -}}
workload:
  komga:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.komgaNetwork.hostNetwork }}
      containers:
        komga:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.komgaRunAs.user }}
            runAsGroup: {{ .Values.komgaRunAs.group }}
          env:
            SERVER_PORT: {{ .Values.komgaNetwork.webPort }}
            KOMGA_CONFIGDIR: /config
            KOMGA_DATABASE_FILE: /config/database.sqlite
            SERVER_SERVLET_CONTEXT_PATH: "/"
          {{ with .Values.komgaConfig.additionalEnvs }}
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
              port: "{{ .Values.komgaNetwork.webPort }}"
              path: /actuator/health
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.komgaNetwork.webPort }}"
              path: /actuator/health
            startup:
              enabled: true
              type: http
              port: "{{ .Values.komgaNetwork.webPort }}"
              path: /actuator/health
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.komgaRunAs.user
                                                        "GID" .Values.komgaRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
