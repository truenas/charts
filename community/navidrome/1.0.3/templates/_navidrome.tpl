{{- define "navidrome.workload" -}}
workload:
  navidrome:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.navidromeNetwork.hostNetwork }}
      containers:
        navidrome:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.navidromeRunAs.user }}
            runAsGroup: {{ .Values.navidromeRunAs.group }}
          env:
            ND_MUSICFOLDER: /music
            ND_DATAFOLDER: /data
            ND_PORT: {{ .Values.navidromeNetwork.webPort | quote }}
            ND_UIWELCOMEMESSAGE: {{ .Values.navidromeConfig.uiWelcomeMessage }}
          {{ with .Values.navidromeConfig.additionalEnvs }}
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
              port: "{{ .Values.navidromeNetwork.webPort }}"
              path: /ping
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.navidromeNetwork.webPort }}"
              path: /ping
            startup:
              enabled: true
              type: http
              port: "{{ .Values.navidromeNetwork.webPort }}"
              path: /ping
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.navidromeRunAs.user
                                                        "GID" .Values.navidromeRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
{{- end -}}
