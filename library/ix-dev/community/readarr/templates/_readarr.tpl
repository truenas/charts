{{- define "readarr.workload" -}}
workload:
  readarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.readarrNetwork.hostNetwork }}
      containers:
        readarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.readarrRunAs.user }}
            runAsGroup: {{ .Values.readarrRunAs.group }}
          env:
            READARR__PORT: {{ .Values.readarrNetwork.webPort }}
            READARR__SERVER__PORT: {{ .Values.readarrNetwork.webPort }}
            READARR__APP__INSTANCENAME: {{ .Values.readarrConfig.instanceName }}
          {{ with .Values.readarrConfig.additionalEnvs }}
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
              port: "{{ .Values.readarrNetwork.webPort }}"
              path: /ping
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.readarrNetwork.webPort }}"
              path: /ping
            startup:
              enabled: true
              type: http
              port: "{{ .Values.readarrNetwork.webPort }}"
              path: /ping
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.readarrRunAs.user
                                                        "GID" .Values.readarrRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
