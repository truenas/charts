{{- define "metube.workload" -}}
workload:
  metube:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.metubeNetwork.hostNetwork }}
      containers:
        metube:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.metubeRunAs.user }}
            runAsGroup: {{ .Values.metubeRunAs.group }}
          env:
            PORT: {{ .Values.metubeNetwork.webPort }}
            DOWNLOAD_DIR: /downloads
            STATE_DIR: /downloads/.metube
            DEFAULT_THEME: auto
          {{ with .Values.metubeConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value | quote }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ .Values.metubeNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.metubeNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.metubeNetwork.webPort }}
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.metubeRunAs.user
                                                        "GID" .Values.metubeRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
