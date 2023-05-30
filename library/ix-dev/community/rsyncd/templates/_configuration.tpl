{{- define "rsync.configuration" -}}
configmap:
  config:
    enabled: true
    data:
      rsyncd.conf: |
        port = {{ .Values.rsyncNetwork.rsyncPort }}
        use chroot = yes
        pid file = /tmp/rsyncd.pid

        max connections = {{ .Values.rsyncConfig.maxConnections }}
        {{- if .Values.rsyncConfig.logging }}
        log file = /dev/stdout
        {{- end }}

{{- end -}}
