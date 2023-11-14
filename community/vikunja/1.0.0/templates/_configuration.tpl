{{- define "vikunja.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $redisHost := (printf "%s-redis" $fullname) -}}
  {{- $redisPass := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-redis-creds" $fullname)) -}}
    {{- $redisPass = ((index .data "REDIS_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $secretKey := randAlphaNum 64 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-vikunja" $fullname)) -}}
    {{- $secretKey = ((index .data "VIKUNJA_SERVICE_JWTSECRET") | b64dec) -}}
  {{- end -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "vikunja" -}}
  {{- $dbName := "vikunja" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}
  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "vikunjaDbPass" $dbPass -}}
  {{- $_ := set .Values "vikunjaDbHost" $dbHost -}}

secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}

  redis-creds:
    enabled: true
    data:
      ALLOW_EMPTY_PASSWORD: "no"
      REDIS_PASSWORD: {{ $redisPass }}
      REDIS_HOST: {{ $redisHost }}

  vikunja-creds:
    enabled: true
    data:
      VIKUNJA_SERVICE_JWTSECRET: {{ $secretKey }}
      VIKUNJA_DATABASE_USER: {{ $dbUser }}
      VIKUNJA_DATABASE_PASSWORD: {{ $dbPass }}
      VIKUNJA_DATABASE_HOST: {{ $dbHost }}
      VIKUNJA_DATABASE_DATABASE: {{ $dbName }}
      VIKUNJA_REDIS_HOST: {{ printf "%s:6379" $redisHost }}
      VIKUNJA_REDIS_PASSWORD: {{ $redisPass }}
      VIKUNJA_REDIS_DB: "0"

configmap:
  vikunja-api:
    enabled: true
    data:
      VIKUNJA_SERVICE_TIMEZONE: {{ .Values.TZ }}
      VIKUNJA_SERVICE_INTERFACE:
      VIKUNJA_REDIS_ENABLED: "true"
      VIKUNJA_KEYVALUE_TYPE: redis
      VIKUNJA_DATABASE_TYPE: postgres
      VIKUNJA_SERVICE_INTERFACE: {{ printf ":%v" .Values.vikunjaPorts.api | quote }}
      VIKUNJA_FILES_MAXSIZE: {{ printf "%vMB" .Values.vikunjaConfig.maxFileSize }}
      VIKUNJA_FILES_BASEPATH: /app/vikunja/files
      VIKUNJA_SERVICE_FRONTENDURL: {{ printf "%s/" (.Values.vikunjaConfig.url | trimSuffix "/") }}

  vikunja-frontend:
    enabled: true
    data:
      VIKUNJA_HTTP_PORT: {{ .Values.vikunjaPorts.frontHttp | quote }}
      VIKUNJA_HTTP2_PORT: {{ .Values.vikunjaPorts.frontHttp2 | quote }}

  nginx-config:
    enabled: true
    data:
      nginx-config: |
        server {
            listen {{ .Values.vikunjaNetwork.webPort }};
            location /nginx-health {
                return 200;
            }
            location / {
                proxy_pass {{ printf "http://%s-frontend:%v" $fullname .Values.vikunjaPorts.frontHttp }};
            }
            location ~* ^/(api|dav|\.well-known)/ {
                proxy_pass {{ printf "http://%s:%v" $fullname .Values.vikunjaPorts.api }};
                client_max_body_size {{ printf "%vM" .Values.vikunjaConfig.maxFileSize }};
            }
        }
{{- end -}}
