{{- define "pgadmin.workload" -}}
workload:
  pgadmin:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.pgadminNetwork.hostNetwork }}
      securityContext:
        fsGroup: 5050
      containers:
        pgadmin:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 5050
            runAsGroup: 5050
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - NET_BIND_SERVICE
          env:
            PGADMIN_LISTEN_PORT: {{ .Values.pgadminNetwork.webPort }}
            PGADMIN_DEFAULT_EMAIL: {{ .Values.pgadminConfig.adminEmail }}
            PGADMIN_DEFAULT_PASSWORD: {{ .Values.pgadminConfig.adminPassword }}
            PGADMIN_SERVER_JSON_FILE: /var/lib/pgadmin/servers/servers.json
            {{ if .Values.pgadminNetwork.certificateID }}
            PGADMIN_ENABLE_TLS: true
            {{ end }}
          {{ with .Values.pgadminConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            {{- $protocol := "http" -}}
            {{- if .Values.pgadminNetwork.certificateID -}}
              {{- $protocol = "https" -}}
            {{- end }}
            liveness:
              enabled: true
              type: {{ $protocol }}
              port: "{{ .Values.pgadminNetwork.webPort }}"
              path: /misc/ping
            readiness:
              enabled: true
              type: {{ $protocol }}
              port: "{{ .Values.pgadminNetwork.webPort }}"
              path: /misc/ping
            startup:
              enabled: true
              type: {{ $protocol }}
              port: "{{ .Values.pgadminNetwork.webPort }}"
              path: /misc/ping
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 5050
                                                        "GID" 5050
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
