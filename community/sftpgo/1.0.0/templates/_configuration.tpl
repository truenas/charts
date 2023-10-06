{{- define "sftpgo.configuration" -}}
configmap:
  sftpgo-config:
    enabled: true
    data:
      SFTPGO_CONFIG_DIR: /var/lib/sftpgo
      SFTPGO_DATA_PROVIDER__USERS_BASE_DIR: /srv/sftpgo/data
      SFTPGO_DATA_PROVIDER__BACKUPS_PATH: /srv/sftpgo/backups
      SFTPGO_GRACE_TIME: {{ .Values.sftpgoConfig.graceTime | quote }}
      SFTPGO_HTTPD__BINDINGS__0__PORT: {{ .Values.sftpgoNetwork.webPort | quote }}
      SFTPGO_HTTPD__BINDINGS__0__ADDRESS: ''
      SFTPGO_HTTPD__BINDINGS__0__ENABLE_WEB_ADMIN: "true"
  {{- if .Values.sftpgoNetwork.certificateID }}
      SFTPGO_HTTPD__BINDINGS__0__ENABLE_HTTPS: "true"
      SFTPGO_HTTPD__BINDINGS__0__CERTIFICATE_FILE: /srv/sftpgo/certs/public.crt
      SFTPGO_HTTPD__BINDINGS__0__CERTIFICATE_KEY_FILE: /srv/sftpgo/certs/private.key
  {{- end -}}
  {{/* SFTPD */}}
  {{- $enabledServices := (include "sftpgo.svc.enabled" (dict "rootCtx" $ "type" "sftpd") | fromJsonArray) -}}
  {{- range $idx, $svc := $enabledServices }}
      SFTPGO_SFTPD__BINDINGS__{{ $idx }}__PORT: {{ $svc.port | quote }}
      SFTPGO_SFTPD__BINDINGS__{{ $idx }}__ADDRESS: ''
  {{- end -}}
  {{/* FTPD */}}
  {{- $enabledServices := (include "sftpgo.svc.enabled" (dict "rootCtx" $ "type" "ftpd") | fromJsonArray) -}}
  {{- range $idx, $svc := $enabledServices }}
      SFTPGO_FTPD__BINDINGS__{{ $idx }}__PORT: {{ $svc.port | quote }}
      SFTPGO_FTPD__BINDINGS__{{ $idx }}__ADDRESS: ''
  {{- end -}}
  {{- if $enabledServices }}
      SFTPGO_FTPD__PASSIVE_PORT_RANGE__START: {{ .Values.sftpgoNetwork.ftpdPassivePortRange.start | quote }}
      SFTPGO_FTPD__PASSIVE_PORT_RANGE__END: {{ .Values.sftpgoNetwork.ftpdPassivePortRange.end | quote }}
  {{- end -}}
  {{/* WEBDAV */}}
  {{- $enabledServices := (include "sftpgo.svc.enabled" (dict "rootCtx" $ "type" "webdavd") | fromJsonArray) -}}
  {{- range $idx, $svc := $enabledServices }}
      SFTPGO_WEBDAVD__BINDINGS__{{ $idx }}__PORT: {{ $svc.port | quote }}
      SFTPGO_WEBDAVD__BINDINGS__{{ $idx }}__ADDRESS: ''
  {{- end -}}
{{- end -}}
