{{- define "sftpgo.configuration" -}}
configmap:
  sftpgo-config:
    enabled: true
    data:
      SFTPGO_CONFIG_DIR: /var/lib/sftpgo
      SFTPGO_DATA_PROVIDER_USERS_BASE_DIR: /srv/sftpgo/data
      SFTPGO_DATA_PROVIDER_BACKUPS_PATH: /srv/sftpgo/backups
      SFTPGO_GRACE_TIME: {{ .Values.sftpgoConfig.graceTime | quote }}
      SFTPGO_HTTPD__BINDINGS__0__PORT: {{ .Values.sftpgoNetwork.webPort | quote }}
      SFTPGO_HTTPD__BINDINGS__0__ADDRESS: ''
      SFTPGO_HTTPD__BINDINGS__0__ENABLE_WEB_ADMIN: "true"
      {{- if .Values.sftpgoNetwork.sftpdEnabled }}
      SFTPGO_SFTPD__BINDINGS__0__PORT: {{ .Values.sftpgoNetwork.sftpdPort | quote }}
      SFTPGO_SFTPD__BINDINGS__0__ADDRESS: ''
      {{- end -}}
      {{- if .Values.sftpgoNetwork.ftpdEnabled }}
      SFTPGO_FTPD__BINDINGS__0__PORT: {{ .Values.sftpgoNetwork.ftpdPort | quote }}
      SFTPGO_FTPD__BINDINGS__0__ADDRESS: ''
      {{- end -}}
      {{- if .Values.sftpgoNetwork.webdavEnabled }}
      SFTPGO_WEBDAV__BINDINGS__0__PORT: {{ .Values.sftpgoNetwork.webdavPort | quote }}
      SFTPGO_WEBDAV__BINDINGS__0__ADDRESS: ''
      {{- end -}}
{{- end -}}
# TODO: Mount single certificate if available to all integrations?
# Integrations that support certificate file:
# - HTTPD
# - FTPD
# - WebDAV
