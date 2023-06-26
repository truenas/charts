{{- define "filebrowser.workload" -}}
workload:
  filebrowser:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.filebrowserNetwork.hostNetwork }}
      containers:
        filebrowser:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.filebrowserRunAs.user }}
            runAsGroup: {{ .Values.filebrowserRunAs.group }}
          args:
            - --config
            - /config/filebrowser.yaml
            - --database
            - /config/filebrowser.db
            - --port
            - "{{ .Values.filebrowserNetwork.webPort }}"
          {{ with .Values.filebrowserConfig.additionalEnvs }}
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
              port: "{{ .Values.filebrowserNetwork.webPort }}"
              path: /
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.filebrowserNetwork.webPort }}"
              path: /
            startup:
              enabled: true
              type: http
              port: "{{ .Values.filebrowserNetwork.webPort }}"
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.filebrowserRunAs.user
                                                        "GID" .Values.filebrowserRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
{{- end -}}
