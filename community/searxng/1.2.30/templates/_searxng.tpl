{{- define "searxng.workload" -}}
workload:
  searxng:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.searxngNetwork.hostNetwork }}
      containers:
        searxng:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            capabilities:
              add:
                - SETUID
                - SETGID
          env:
            BIND_ADDRESS: {{ printf "0.0.0.0:%v" .Values.searxngNetwork.webPort }}
            INSTANCE_NAME: {{ .Values.searxngConfig.instanceName }}
          {{ with .Values.searxngConfig.additionalEnvs }}
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
              port: "{{ .Values.searxngNetwork.webPort }}"
              path: /healthz
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.searxngNetwork.webPort }}"
              path: /healthz
            startup:
              enabled: true
              type: http
              port: "{{ .Values.searxngNetwork.webPort }}"
              path: /healthz
{{- end -}}
