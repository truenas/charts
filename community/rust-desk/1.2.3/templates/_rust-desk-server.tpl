{{- define "rust-server.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $relay := (printf "%s-relay:%v" $fullname .Values.rustNetwork.relayPort) -}}
{{- $relays := mustAppend .Values.rustConfig.additionalRelayServers $relay }}
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
            - "{{ join "," $relays }}"
          {{ if .Values.rustConfig.allowOnlyEncryptedConnections }}
            - -k
            - _
          {{ end }}
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
              port: 21115
            readiness:
              enabled: true
              type: tcp
              port: 21115
            startup:
              enabled: true
              type: tcp
              port: 21115
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.rustRunAs.user
                                                        "GID" .Values.rustRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
