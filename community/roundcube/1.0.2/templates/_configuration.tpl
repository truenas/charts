{{- define "roundcube.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "roundcube" -}}
  {{- $dbName := "roundcube" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "roundcubeDbPass" $dbPass -}}
  {{- $_ := set .Values "roundcubeDbHost" $dbHost -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) }}
secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}

  roundcube-creds:
    enabled: true
    data:
      ROUNDCUBEMAIL_DB_TYPE: pgsql
      ROUNDCUBEMAIL_DB_HOST: {{ $dbHost }}
      ROUNDCUBEMAIL_DB_PORT: "5432"
      ROUNDCUBEMAIL_DB_USER: {{ $dbUser }}
      ROUNDCUBEMAIL_DB_PASSWORD: {{ $dbPass }}
      ROUNDCUBEMAIL_DB_NAME: {{ $dbName }}

configmap:
  roundcube-config:
    enabled: true
    data:
      ROUNDCUBEMAIL_SKIN: {{ .Values.roundcubeConfig.skin }}
      {{/* IMAP */}}
      ROUNDCUBEMAIL_DEFAULT_HOST: {{ .Values.roundcubeConfig.defaultHost | quote }}
      ROUNDCUBEMAIL_DEFAULT_PORT: {{ .Values.roundcubeConfig.defaultPort | quote }}
      {{/* SMTP */}}
      ROUNDCUBEMAIL_SMTP_SERVER: {{ .Values.roundcubeConfig.smtpServer | quote }}
      ROUNDCUBEMAIL_SMTP_PORT: {{ .Values.roundcubeConfig.smtpPort | quote }}
      ROUNDCUBEMAIL_PLUGINS: {{ join "," .Values.roundcubeConfig.plugins | quote }}
      ROUNDCUBEMAIL_ASPELL_PACKAGES: {{ join "," .Values.roundcubeConfig.aspellDicts | quote }}
      ROUNDCUBEMAIL_UPLOAD_MAX_FILESIZE: {{ printf "%vM" .Values.roundcubeConfig.uploadMaxSize | quote }}
{{- end -}}
