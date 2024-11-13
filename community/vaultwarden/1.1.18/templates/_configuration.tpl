{{- define "vaultwarden.configuration" -}}

  {{- if and .Values.vaultwardenNetwork.domain (not (hasPrefix "http" .Values.vaultwardenNetwork.domain)) -}}
    {{- fail "Vaultwarden - Expected [Domain] to have the following format [http(s)://(sub).domain.tld(:port)]." -}}
  {{- end -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "vaultwarden" -}}
  {{- $dbName := "vaultwarden" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "vaultwardenDbPass" $dbPass -}}
  {{- $_ := set .Values "vaultwardenDbHost" $dbHost -}}

  {{ $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) }}
secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}
  {{ with .Values.vaultwardenConfig.adminToken }}
  vaultwarden:
    enabled: true
    data:
      ADMIN_TOKEN: {{ . | quote }}
  {{ end }}
{{- end -}}
