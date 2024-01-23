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
                - NET_BIND_SERVICE
                - SETGID
                - SETUID
                - SYS_CHROOT
          env:
            NGINX_PORT: {{ .Values.netbootNetwork.webAssetsPort }}
            TFTPD_OPTS: {{ join " " .Values.netbootConfig.tftpdOpts }}
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
              command: /usr/local/bin/docker-healthcheck.sh
            readiness:
              enabled: true
              type: exec
              command: /usr/local/bin/docker-healthcheck.sh
            startup:
              enabled: true
              type: exec
              command: /usr/local/bin/docker-healthcheck.sh
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 911
                                                        "GID" 1000
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
