{{- define "immich.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "immich" -}}
  {{- $dbName := "immich" -}}

  {{- $dbPass := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}

  {{- $typesenseKey := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-immich-creds" $fullname)) -}}
    {{- $typesenseKey = ((index .data "TYPESENSE_API_KEY") | b64dec) -}}
  {{- end -}}

  {{- $mlURL := "false" -}}
  {{- if .Values.immichConfig.enableML -}}
    {{- $mlURL = printf "http://%v-machinelearning:%v" $fullname .Values.immichNetwork.mlPort -}}
  {{- end }}

secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}

  immich-creds:
    enabled: true
    data:
      TYPESENSE_API_KEY: {{ $typesenseKey }}
      DB_USERNAME: {{ $dbUser }}
      DB_PASSWORD: {{ $dbPass }}
      DB_HOSTNAME: {{ $dbHost }}
      DB_DATABASE_NAME: {{ $dbName }}
      DB_PORT: "5432"
      # TODO: Redis
      # REDIS_HOSTNAME:
      # REDIS_PASSWORD:
      # REDIS_PORT: "6379"
      # REDIS_DBINDEX: "0"

  {{- if .Values.immichConfig.enableTypesense }}
  typesense-creds:
    enabled: true
    data:
      TYPESENSE_API_KEY: {{ $typesenseKey }}
      TYPESENSE_DATA_DIR: /typesense-data
  {{- end }}

configmap:
  server-config:
    enabled: true
    data:
      NODE_ENV: production
      SERVER_PORT: {{ .Values.immichNetwork.serverPort | quote }}
      TYPESENSE_ENABLED: {{ .Values.immichConfig.enableTypesense | quote }}
      IMMICH_MACHINE_LEARNING_URL: {{ $mlURL }}
      {{- if .Values.immichConfig.enableTypesense }}
      TYPESENSE_URL: {{ printf "http://%v-typesense:%v" .Values.immichNetwork.typesensePort }}
      TYPESENSE_PROTOCOL: http
      TYPESENSE_HOST: {{ printf "%v-typesense" $fullname }}
      TYPESENSE_PORT: {{ .Values.immichNetwork.typesensePort }}
      {{- end }}

  micro-config:
    enabled: true
    data:
      NODE_ENV: production
      MICROSERVICES_PORT: {{ .Values.immichNetwork.microPort | quote }}
      IMMICH_MACHINE_LEARNING_URL: {{ $mlURL }}
      REVERSE_GEOCODING_DUMP_DIRECTORY: /microcache
      DISABLE_REVERSE_GEOCODING: {{ .Values.immichConfig.disableReverseGeocoding | quote }}
      {{- if not .Values.immichConfig.disableReverseGeocoding }}
      REVERSE_GEOCODING_PRECISION: {{ .Values.immichConfig.reverseGeocodingPrecision | quote }}
      {{- end }}
      TYPESENSE_ENABLED: {{ .Values.immichConfig.enableTypesense | quote }}
      {{- if .Values.immichConfig.enableTypesense }}
      TYPESENSE_URL: {{ printf "http://%v-typesense:%v" .Values.immichNetwork.typesensePort }}
      TYPESENSE_PROTOCOL: http
      TYPESENSE_HOST: {{ printf "%v-typesense" $fullname }}
      TYPESENSE_PORT: {{ .Values.immichNetwork.typesensePort }}
      {{- end }}

  web-config:
    enabled: true
    data:
      NODE_ENV: production
      PORT: {{ .Values.immichNetwork.webPort | quote }}
      IMMICH_SERVER_URL: {{ printf "http://%v-server:%v" $fullname .Values.immichNetwork.serverPort }}
      PUBLIC_IMMICH_SERVER_URL: {{ printf "http://%v-server:%v" $fullname .Values.immichNetwork.serverPort }}
      {{- with .Values.immichConfig.publicLoginMessage }}
      PUBLIC_LOGIN_PAGE_MESSAGE: {{ . | quote }}
      {{- end }}

  proxy-config:
    enabled: true
    data:
      IMMICH_WEB_URL: {{ printf "http://%v-web:%v" $fullname .Values.immichNetwork.webPort }}
      IMMICH_SERVER_URL: {{ printf "http://%v-server:%v" $fullname .Values.immichNetwork.serverPort }}

  {{- if .Values.immichConfig.enableML }}
  ml-config:
    enabled: true
    data:
      NODE_ENV: production
      MACHINE_LEARNING_PORT: {{ .Values.immichNetwork.mlPort | quote }}
      TRANSFORMERS_CACHE: /mlcache
  {{- end }}
{{- end -}}
