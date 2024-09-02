{{- define "audiobookshelf.workload" -}}
workload:
  audiobookshelf:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.audiobookshelfNetwork.hostNetwork }}
      containers:
        audiobookshelf:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.audiobookshelfRunAs.user }}
            runAsGroup: {{ .Values.audiobookshelfRunAs.group }}
            readOnlyRootFilesystem: false
          env:
            PORT: {{ .Values.audiobookshelfNetwork.webPort }}
            CONFIG_PATH: /config
            METADATA_PATH: /metadata
          {{ with .Values.audiobookshelfConfig.additionalEnvs }}
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
              port: "{{ .Values.audiobookshelfNetwork.webPort }}"
              path: /healthcheck
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.audiobookshelfNetwork.webPort }}"
              path: /healthcheck
            startup:
              enabled: true
              type: http
              port: "{{ .Values.audiobookshelfNetwork.webPort }}"
              path: /healthcheck
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.audiobookshelfRunAs.user
                                                        "GID" .Values.audiobookshelfRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
