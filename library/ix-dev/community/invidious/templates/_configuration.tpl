{{- define "invidious.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "kemal" -}} {{/* User is hardcoded */}}
  {{- $dbName := "kemal" -}} {{/* Database is hardcoded */}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $hmacKey := (randAlphaNum 64) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-invidious-creds" $fullname)) -}}
    {{- $hmacKey = ((index .data "INVIDIOUS_HMAC_KEY") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "invidiousDbPass" $dbPass -}}
  {{- $_ := set .Values "invidiousDbHost" $dbHost -}}

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
      # Used by invidious init script
      PGPASSWORD: {{ $dbPass }}
      PGHOST: {{ $dbHost }}
      PGPORT: "5432"

  {{/* Do not quote: bools, numbers, json */}}
  {{- $configOpts := list
    (dict "path" "check_tables" "value" "true")
    (dict "path" "database_url" "value" ($dbURL | quote))
    (dict "path" "db.user" "value" ($dbUser | quote))
    (dict "path" "db.password" "value" ($dbPass | quote))
    (dict "path" "db.dbname" "value" ($dbName | quote))
    (dict "path" "db.host" "value" ($dbHost | quote))
    (dict "path" "db.port" "value" "5432")
    (dict "path" "hmac_key" "value" ($hmacKey | quote))
    (dict "path" "host_binding" "value" ("0.0.0.0" | quote))
    (dict "path" "port" "value" .Values.invidiousNetwork.webPort)
    (dict "path" "admins" "value" (.Values.invidiousConfig.admins | toJson))
    (dict "path" "registration_enabled" "value" .Values.invidiousConfig.registrationEnabled)
    (dict "path" "login_enabled" "value" .Values.invidiousConfig.loginEnabled)
    (dict "path" "captcha_enabled" "value" .Values.invidiousConfig.captchaEnabled)
  }}

  invidious-creds:
    enabled: true
    data:
      INVIDIOUS_HMAC_KEY: {{ $hmacKey }}
      config.sh: |
        #!/bin/sh
        config="/config/config.yaml"
        echo "Updating Invidious Config..."
        {{- range $item := $configOpts }}
        echo "Updating [{{ $item.path }}]"
        yq -i '.{{ $item.path }} = {{ $item.value }}' "$config"
        echo "Updated [{{ $item.path }}] to $(yq '.{{ $item.path }}' "$config")"
        {{- end }}
        echo "Config updated!"
{{- end -}}
