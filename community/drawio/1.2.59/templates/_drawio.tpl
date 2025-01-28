{{- define "drawio.workload" -}}
workload:
  drawio:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.drawioNetwork.hostNetwork }}
      containers:
        drawio:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 1000
            runAsGroup: 999
            readOnlyRootFilesystem: false
          {{ with .Values.drawioConfig.additionalEnvs }}
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
              port: 8080
              path: /
            readiness:
              enabled: true
              type: http
              port: 8080
              path: /
            startup:
              enabled: true
              type: http
              port: 8080
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 1000
                                                        "GID" 999
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
