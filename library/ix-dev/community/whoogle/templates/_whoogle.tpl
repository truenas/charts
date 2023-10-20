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
            runAsUser: {{ .Values.whoogleRunAs.user }}
            runAsGroup: {{ .Values.whoogleRunAs.group }}
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
                                                        "UID" .Values.whoogleRunAs.user
                                                        "GID" .Values.whoogleRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
{{- end -}}
