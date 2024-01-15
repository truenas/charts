{{- define "listmonk.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "listmonk" -}}
  {{- $dbName := "listmonk" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}
  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "listmonkDbPass" $dbPass -}}
  {{- $_ := set .Values "listmonkDbHost" $dbHost -}}

secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}

  listmonk-creds:
    enabled: true
    data:
      LISTMONK_app__address: {{ printf "0.0.0.0:%v" .Values.listmonkNetwork.webPort }}
      LISTMONK_db__port: "5432"
      LISTMONK_db__host: {{ $dbHost }}
      LISTMONK_db__user: {{ $dbUser }}
      LISTMONK_db__password: {{ $dbPass }}
      LISTMONK_db__database: {{ $dbName }}
      LISTMONK_db__sslmode: "disable"
      LISTMONK_app__admin_username: {{ .Values.listmonkConfig.adminUsername | quote }}
      LISTMONK_app__admin_password: {{ .Values.listmonkConfig.adminPassword | quote }}
{{- end -}}
