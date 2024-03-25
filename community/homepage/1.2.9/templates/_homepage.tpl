{{- define "homepage.workload" -}}
workload:
  homepage:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.homepageNetwork.hostNetwork }}
      containers:
        homepage:
          enabled: true
          primary: true
          imageSelector: image
          # While it seems that any uid/gid can be used
          # There was permission errors when trying to cache things.
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
            readOnlyRootFilesystem: false
          env:
            PORT: {{ .Values.homepageNetwork.webPort }}
          {{ with .Values.homepageConfig.additionalEnvs }}
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
              port: "{{ .Values.homepageNetwork.webPort }}"
              path: /api/healthcheck
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.homepageNetwork.webPort }}"
              path: /api/healthcheck
            startup:
              enabled: true
              type: http
              port: "{{ .Values.homepageNetwork.webPort }}"
              path: /api/healthcheck
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 1000
                                                        "GID" 1000
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
