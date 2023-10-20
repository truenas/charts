{{- define "whoogle.workload" -}}
workload:
  whoogle:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.whoogleNetwork.hostNetwork }}
      fsGroup: 927
      containers:
        whoogle:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 927
            runAsGroup: 927
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
                                                        "UID" 927
                                                        "GID" 927
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
{{- end -}}
