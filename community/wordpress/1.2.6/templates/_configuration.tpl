{{- define "wordpress.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-mariadb" $fullname) -}}
  {{- $dbUser := "wordpress" -}}
  {{- $dbName := "wordpress" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- $dbRootPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-mariadb-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "MARIADB_PASSWORD") | b64dec) -}}
    {{- $dbRootPass = ((index .data "MARIADB_ROOT_PASSWORD") | b64dec) -}}
  {{- end }}

secret:
  mariadb-creds:
    enabled: true
    data:
      MARIADB_USER: {{ $dbUser }}
      MARIADB_DATABASE: {{ $dbName }}
      MARIADB_PASSWORD: {{ $dbPass }}
      MARIADB_ROOT_PASSWORD: {{ $dbRootPass }}
      MARIADB_HOST: {{ $dbHost }}

  wordpress-creds:
    enabled: true
    data:
      WORDPRESS_DB_HOST: {{ $dbHost }}
      WORDPRESS_DB_NAME: {{ $dbName }}
      WORDPRESS_DB_USER: {{ $dbUser }}
      WORDPRESS_DB_PASSWORD: {{ $dbPass }}
      {{/* Disable On Page Load Cron when k8s CronJob is enabled */}}
      {{- if .Values.wpConfig.enableCronJob }}
      WORDPRESS_CONFIG_EXTRA: |
          define( 'DISABLE_WP_CRON', true );
      {{- end -}}
{{- end -}}
