{{- define "sftpgo.configuration" -}}
configmap:
  sftpgo-config:
    enabled: true
    data:
      SFTPGO_CONFIG_DIR: /var/lib/sftpgo
      SFTPGO_GRACE_TIME: {{ .Values.sftpgoConfig.graceTime }}
      SFTPGO_HTTPD__BINDINGS__0__PORT: {{ .Values.sftpgoNetwork.webPort }}
{{- end -}}
