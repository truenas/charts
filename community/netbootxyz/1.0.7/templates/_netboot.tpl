{{- define "netboot.workload" -}}
workload:
  netboot:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.netbootNetwork.hostNetwork }}
      containers:
        netboot:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsNonRoot: false
            runAsUser: 0
            runAsGroup: 0
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETGID
                - SETUID
                - SYS_CHROOT
                - NET_BIND_SERVICE
                - KILL
          env:
            NGINX_PORT: {{ .Values.netbootNetwork.webAssetsPort }}
            TFTPD_OPTS: {{ join " " .Values.netbootConfig.tftpdOpts }}
            WEB_APP_PORT: {{ .Values.netbootNetwork.webHttpPort }}
          {{ with .Values.netbootConfig.additionalEnvs }}
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
              command:
                - /bin/sh
                - -c
                - |
                  pgrep in.tftpd
            readiness:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  pgrep in.tftpd
            startup:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  pgrep in.tftpd
{{- end -}}
