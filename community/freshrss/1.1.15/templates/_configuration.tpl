{{- define "freshrss.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "freshrss" -}}
  {{- $dbName := "freshrss" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}
  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "freshrssDbPass" $dbPass -}}
  {{- $_ := set .Values "freshrssDbHost" $dbHost -}}

secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}

  freshrss-creds:
    enabled: true
    data:
      # This is only used on the first install
      FRESHRSS_INSTALL: |
        --default_user {{ .Values.freshrssConfig.defaultAdmin }}
        --db-type pgsql
        --db-base {{ $dbName }}
        --db-host {{ $dbHost }}
        --db-user {{ $dbUser }}
        --db-password {{ $dbPass }}
      # This is only used on the first install
      FRESHRSS_USER: |
        --user {{ .Values.freshrssConfig.defaultAdmin }}
        --password {{ .Values.freshrssConfig.defaultAdminPass }}
configmap:
  freshrss-config:
    enabled: true
    data:
      FRESHRSS_ENV: production
      LISTEN: {{ .Values.freshrssNetwork.webPort | quote }}
      DATA_PATH: /var/www/FreshRSS/data
      # We use k8s cron instead of the in-container cron
      CRON_MIN: ""
{{- end -}}
