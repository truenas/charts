{{- define "rsync.configuration" -}}
{{- include "rsync.validation" $ }}
configmap:
  config:
    enabled: true
    data:
      rsyncd.conf: |
        port = {{ .Values.rsyncNetwork.rsyncPort }}
        use chroot = yes
        pid file = /tmp/rsyncd.pid

        max connections = {{ .Values.rsyncConfig.maxConnections }}
        {{- if .Values.rsyncConfig.logToStdout }}
        log file = /dev/stdout
        {{- end }}

{{- end -}}
