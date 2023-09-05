{{- define "rust-server.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) }}
workload:
  server:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.rustNetwork.hostNetwork }}
      containers:
        server:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.rustRunAs.user }}
            runAsGroup: {{ .Values.rustRunAs.group }}
          command:
            - hbbs
          args:
            - -r
            - {{ printf "%s-relay:%d" $fullname .Values.rustNetwork.relayPort }}
          {{ with .Values.rustConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: tcp
              port: "{{ .Values.rustNetwork.natTypeTestPort }}"
            readiness:
              enabled: true
              type: tcp
              port: "{{ .Values.rustNetwork.natTypeTestPort }}"
            startup:
              enabled: true
              type: tcp
              port: "{{ .Values.rustNetwork.natTypeTestPort }}"
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.rustRunAs.user
                                                        "GID" .Values.rustRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
{{- end -}}
