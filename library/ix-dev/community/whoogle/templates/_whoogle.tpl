{{- define "whoogle.workload" -}}
workload:
  whoogle:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.whoogleNetwork.hostNetwork }}
      containers:
        whoogle:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 102
            runAsGroup: 102
            readOnlyRootFilesystem: false
          env:
            EXPOSE_PORT: {{ .Values.whoogleNetwork.webPort }}
          {{ with .Values.whoogleConfig.additionalEnvs }}
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
              port: {{ .Values.whoogleNetwork.webPort }}
              path: /healthz
            readiness:
              enabled: true
              type: http
              port: {{ .Values.whoogleNetwork.webPort }}
              path: /healthz
            startup:
              enabled: true
              type: http
              port: {{ .Values.whoogleNetwork.webPort }}
              path: /healthz
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 102
                                                        "GID" 102
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
{{- end -}}
