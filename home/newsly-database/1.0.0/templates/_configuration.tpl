{{- define "newslydb.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "immich" -}}
  {{- $dbName := "immich" -}}

  {{- $dbPass := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "immichDbPass" $dbPass -}}
  {{- $_ := set .Values "immichDbHost" $dbHost -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}

  {{- $typesenseKey := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-immich-creds" $fullname)) -}}
    {{- $typesenseKey = ((index .data "TYPESENSE_API_KEY") | b64dec) -}}
  {{- end -}}

  {{- $mlURL := printf "http://%v-machinelearning:%v" $fullname .Values.immichNetwork.machinelearningPort }}

secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}
{{- end -}}
