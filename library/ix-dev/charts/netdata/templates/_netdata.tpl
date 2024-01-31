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
            # TODO: Drop privs
            allowPrivilegeEscalation: true
            capabilities:
              drop: []
              add:
                - CHOWN
                - DAC_OVERRIDE
                - DAC_READ_SEARCH
                - FOWNER
                - SETGID
                - SETUID
                - SETPCAP
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
