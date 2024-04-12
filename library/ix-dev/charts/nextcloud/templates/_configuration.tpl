{{- define "nextcloud.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "nextcloud" -}}
  {{- $dbName := "nextcloud" -}}
  {{- $dbPass := (randAlphaNum 32) -}}

  {{/* Fetch secrets from pre-migration secret */}}
  {{- with (lookup "v1" "Secret" .Release.Namespace "db-details") -}}
    {{- $dbUser = ((index .data "db-user") | b64dec) -}}
    {{- $dbPass = ((index .data "db-password") | b64dec) -}}
  {{- end -}}

  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbUser = ((index .data "POSTGRES_USER") | b64dec) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "haDbPass" $dbPass -}}
  {{- $_ := set .Values "haDbHost" $dbHost -}}
  {{- $_ := set .Values "haDbName" $dbName -}}
  {{- $_ := set .Values "haDbUser" $dbUser -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}
secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}
  nextcloud-creds:
    enabled: true
    data:
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}
      NEXTCLOUD_DATA_DIR: {{ .Values.ncConfig.dataDir }}
      PHP_UPLOAD_LIMIT: {{ printf "%vG" .Values.ncConfig.maxUploadLimit | default 3 }}
      PHP_MEMORY_LIMIT: {{ printf "%vM" .Values.ncConfig.phpMemoryLimit | default 512 }}
    {{- if .Values.ncNetwork.certificateID }}
      APACHE_DISABLE_REWRITE_IP: "1"
      OVERWRITEPROTOCOL: "https"
      TRUSTED_PROXIES: "127.0.0.1"
      {{- if and .Values.ncConfig.host .Values.ncNetwork.webPort }}
        {{- if .Values.ncConfig.nginx.useDifferentAccessPort }}
      OVERWRITEHOST: {{ .Values.ncConfig.host }}
        {{- else }}
      OVERWRITEHOST: {{ .Values.ncConfig.host }}:{{ .Values.ncNetwork.webPort }}
        {{- end }}
      {{- end }}
    {{- end }}
      NEXTCLOUD_TRUSTED_DOMAINS: {{ .Values.ncConfig.host }}
      NEXTCLOUD_ADMIN_USER: {{ .Values.ncConfig.adminUser }}
      NEXTCLOUD_ADMIN_PASSWORD: {{ .Values.ncConfig.adminPassword }}
  {{- if eq (include "nextcloud.is-migration" $) "true" }}
  postgres-backup-creds:
    enabled: true
    annotations:
      helm.sh/hook: "pre-upgrade"
      helm.sh/hook-delete-policy: "hook-succeeded"
      helm.sh/hook-weight: "1"
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}-ha
      POSTGRES_URL: {{ printf "postgres://%s:%s@%s-ha:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName }}
  {{- end }}
{{- end -}}
