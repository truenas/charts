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
              port: "{{ .Values.rustNetwork.relayPort }}"
            readiness:
              enabled: true
              type: tcp
              port: "{{ .Values.rustNetwork.relayPort }}"
            startup:
              enabled: true
              type: tcp
              port: "{{ .Values.rustNetwork.relayPort }}"
{{- end -}}
