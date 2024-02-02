{{- define "home-assistant.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "home-assistant" -}}
  {{- $dbName := "home-assistant" -}}
  {{- $dbPass := (randAlphaNum 32) -}}

  {{/* Fetch secrets from pre-migration secret */}}
  {{- with (lookup "v1" "Secret" .Release.Namespace "db-details") -}}
    {{- $dbUser = ((index .data "db-user") | b64dec) -}}
    {{- $dbPass = ((index .data "db-password") | b64dec) -}}
    {{/* Previous installs had a typo */}}
    {{- $dbName = "homeassistance" -}}
  {{- end -}}

  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbUser = ((index .data "POSTGRES_USER") | b64dec) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
    {{- $dbName = ((index .data "POSTGRES_DB") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "haDbPass" $dbPass -}}
  {{- $_ := set .Values "haDbHost" $dbHost -}}
  {{- $_ := set .Values "haDbName" $dbName -}}
  {{- $_ := set .Values "haDbUser" $dbUser -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}
  {{- $haDBURL := (printf "postgresql://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) }}
secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}
  {{- if eq (include "home-assistant.is-migration" $) "true" }}
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
  ha-config:
    enabled: true
    data:
      configuration.default: |
        # Configure a default setup of Home Assistant (frontend, api, etc)
        default_config:
        # Text to speech
        tts:
          - platform: google_translate
      recorder.default: |
        recorder:
          purge_keep_days: 30
          commit_interval: 3
          db_url: {{ $haDBURL }}
      script.sh: |
        #!/bin/sh
        config="/config/configuration.yaml"
        default="/default/init"
        # Attemp to get read/write access
        chmod +rw "$config" || echo "Failed to set permissions on [$config]"
        if [ ! -f "$config" ]; then
          echo "File [$config] does NOT exist. Creating..."
          cp "$default/configuration.default" "$config"
        fi
        if ! grep -q "recorder:" "$config"; then
          echo "Section [recorder] does NOT exist in [$config]. Appending..."
          cat "$default/recorder.default" >> "$config"
        fi
        echo "Ensure DB URL is up to date"
        yq -i '.recorder.db_url = "{{ $haDBURL }}"' "$config"
        echo "Done"
{{- end -}}
