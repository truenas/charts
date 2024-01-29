{{- define "linkding.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "linkding" -}}
  {{- $dbName := "linkding" -}}

  {{- $dbPass := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}
  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "linkdingDbPass" $dbPass -}}
  {{- $_ := set .Values "linkdingDbHost" $dbHost -}}

  {{- $secret := randAlphaNum 64 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-linkding-secret" $fullname)) -}}
    {{- $secret = ((index .data "secretkey.txt") | b64dec) -}}
  {{- end }}

secret:
  linkding-secret:
    enabled: true
    data:
      secretkey.txt: {{ $secret }}
  linkding:
    enabled: true
    data:
      LD_DB_ENGINE: postgres
      LD_DB_DATABASE: {{ $dbName }}
      LD_DB_USER: {{ $dbUser }}
      LD_DB_HOST: {{ $dbHost }}
      LD_DB_PORT: "5432"
      LD_DB_PASSWORD: {{ $dbPass }}
      {{- with .Values.linkdingConfig.username }}
      LD_SUPERUSER_NAME: {{ . }}
      {{- end }}
      {{- with .Values.linkdingConfig.password }}
      LD_SUPERUSER_PASSWORD: {{ . }}
      {{- end }}

  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}

configmap:
  linkding:
    enabled: true
    data:
      LD_SERVER_PORT: {{ .Values.linkdingNetwork.webPort | quote }}
      LD_DISABLE_BACKGROUND_TASKS: {{ ternary "True" "False" .Values.linkdingConfig.disableBackgroundTasks | quote }}
      LD_DISABLE_URL_VALIDATION: {{ ternary "True" "False" .Values.linkdingConfig.disableUrlValidation | quote }}
      LD_ENABLE_AUTH_PROXY: {{ ternary "True" "False" .Values.linkdingConfig.enableAuthProxy | quote }}
      {{- if .Values.linkdingConfig.enableAuthProxy }}
      LD_AUTH_PROXY_USERNAME_HEADER: {{ .Values.linkdingConfig.authProxyUsernameHeader | quote }}
        {{- with .Values.linkdingConfig.authProxyLogoutUrl }}
      LD_AUTH_PROXY_LOGOUT_URL: {{ . | quote }}
        {{- end -}}
      {{- end -}}
      {{- with .Values.linkdingConfig.csrfTrustedOrigins }}
      LD_CSRF_TRUSTED_ORIGINS: {{ join "," . }}
      {{- end -}}
{{- end -}}
