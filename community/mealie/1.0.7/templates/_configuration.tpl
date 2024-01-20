{{- define "mealie.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "mealie" -}}
  {{- $dbName := "mealie" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}
  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "mealieDbPass" $dbPass -}}
  {{- $_ := set .Values "mealieDbHost" $dbHost -}}

secret:
  mealie:
    enabled: true
    data:
      DB_ENGINE: postgres
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_SERVER: {{ $dbHost }}
      POSTGRES_PORT: "5432"
      POSTGRES_DB: {{ $dbName }}

  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}

configmap:
  mealie:
    enabled: true
    data:
      API_PORT: {{ .Values.mealieNetwork.webPort | quote }}
      BASE_URL: {{ .Values.mealieConfig.baseURL | quote }}
      ALLOW_SIGNUP: {{ .Values.mealieConfig.allowSignup | quote }}
      DEFAULT_GROUP: {{ .Values.mealieConfig.defaultGroup | quote }}
      DEFAULT_EMAIL: {{ .Values.mealieConfig.defaultAdminEmail | quote }}
      DEFAULT_PASSWORD: {{ .Values.mealieConfig.defaultAdminPassword | quote }}
{{- end -}}
