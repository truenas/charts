{{- define "castopod.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $saltKey := randAlphaNum 64 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-castopod-creds" $fullname)) -}}
    {{- $saltKey = ((index .data "CP_ANALYTICS_SALT") | b64dec) -}}
  {{- end -}}

  {{- $redisHost := (printf "%s-redis" $fullname) -}}

  {{- $redisPass := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-redis-creds" $fullname)) -}}
    {{- $redisPass = ((index .data "REDIS_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $dbHost := (printf "%s-mariadb" $fullname) -}}
  {{- $dbUser := "castopod" -}}
  {{- $dbName := "castopod" -}}

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
  redis-creds:
    enabled: true
    data:
      ALLOW_EMPTY_PASSWORD: "no"
      REDIS_PASSWORD: {{ $redisPass }}
      REDIS_HOST: {{ $redisHost }}

  castopod-creds:
    enabled: true
    data:
      CP_ANALYTICS_SALT: {{ $saltKey }}
      CP_DATABASE_HOSTNAME: {{ $dbHost }}
      CP_DATABASE_NAME: {{ $dbName }}
      CP_DATABASE_USERNAME: {{ $dbUser }}
      CP_DATABASE_PASSWORD: {{ $dbPass }}
      CP_CACHE_HANDLER: redis
      CP_REDIS_HOST: {{ $redisHost }}
      CP_REDIS_PASSWORD: {{ $redisPass }}
      CP_REDIS_PORT: "6379"
      CP_REDIS_DATABASE: "0"

configmap:
  castopod-config:
    enabled: true
    data:
      CP_TIMEOUT: {{ .Values.castopodConfig.webTimeout | quote }}
      CP_MAX_BODY_SIZE: {{ printf "%vM" .Values.castopodConfig.webMaxBodySize }}
      CP_PHP_MEMORY_LIMIT: {{ printf "%vM" .Values.castopodConfig.phpMemoryLimit }}
      CP_BASEURL: {{ .Values.castopodConfig.baseUrl }}
      CP_MEDIAURL: {{ .Values.castopodConfig.baseUrl }}
      CP_DISABLE_HTTPS: {{ ternary "1" "0" .Values.castopodConfig.disableHttpsRedirect | quote }}
      CP_ENABLE_2FA: {{ .Values.castopodConfig.enable2fa | quote }}
{{- end -}}
