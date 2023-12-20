{{- define "rust-relay.workload" -}}
workload:
  relay:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.rustNetwork.hostNetwork }}
      containers:
        relay:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.rustRunAs.user }}
            runAsGroup: {{ .Values.rustRunAs.group }}
          command:
            - hbbr
          {{ if .Values.rustConfig.allowOnlyEncryptedConnections }}
          args:
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
              port: 21117
            readiness:
              enabled: true
              type: tcp
              port: 21117
            startup:
              enabled: true
              type: tcp
              port: 21117
{{- end -}}
