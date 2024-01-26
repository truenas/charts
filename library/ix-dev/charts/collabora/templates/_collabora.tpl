{{- define "collabora.workload" -}}
workload:
  collabora:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        collabora:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            # capabilities:
            #   add:
            #     - NET_BIND_SERVICE
            #     - NET_RAW
          env:
            timezone: {{ .Values.TZ }}
            aliasgroup1: {{ join "," .Values.collaboraConfig.aliasGroup1 }}
            dictionaries: {{ join " " .Values.collaboraConfig.dictionaries }}
            extra_params: {{ join " " .Values.collaboraConfig.extraParams }}
            DONT_GEN_SSL_CERT: "true"
            {{- if .Values.collaboraConfig.enableWebUI }}
            username: {{ .Values.collaboraConfig.username }}
            password: {{ .Values.collaboraConfig.password }}
            {{- end }}
            {{- if not (contains ":" .Values.collaboraConfig.serverName) }}
            server_name: {{ printf "%s:%v" .Values.collaboraConfig.serverName .Values.collaboraNetwork.webPort }}
            {{- else }}
            server_name: {{ .Values.collaboraConfig.serverName }}
            {{- end }}
          {{ with .Values.collaboraConfig.additionalEnvs }}
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
              path: /
              port: 9980
            readiness:
              enabled: true
              type: http
              path: /
              port: 9980
            startup:
              enabled: true
              type: http
              path: /
              port: 9980
{{- end -}}
