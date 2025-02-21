{{- define "netdata.workload" -}}
workload:
  netdata:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      automountServiceAccountToken: true
      securityContext:
        fsGroup: 201
      containers:
        netdata:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            allowPrivilegeEscalation: true
            capabilities:
              add:
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETGID
                - SETUID
                - SYS_PTRACE
          env:
            NETDATA_LISTENER_PORT: {{ .Values.netdataNetwork.webPort }}
          {{ with .Values.netdataConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: exec
              command: /usr/sbin/health.sh
            readiness:
              enabled: true
              type: exec
              command: /usr/sbin/health.sh
            startup:
              enabled: true
              type: exec
              command: /usr/sbin/health.sh
{{- end -}}
