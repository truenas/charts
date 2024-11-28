{{- define "twofauth.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $appKey := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-twofauth-creds" $fullname)) -}}
    {{- $appKey = ((index .data "APP_KEY") | b64dec) -}}
  {{- end }}

secret:
  twofauth-creds:
    enabled: true
    data:
      APP_KEY: {{ $appKey }}

configmap:
  twofauth-config:
    enabled: true
    data:
      # When this is set to production, it initialize automatically
      # Because it waits for user input in the console.
      APP_ENV: local
      # It is symlinked to /2fauth/database.sqlite
      DB_DATABASE: /srv/database/database.sqlite
      APP_NAME: {{ .Values.twofauthConfig.appName }}
      APP_URL: {{ .Values.twofauthConfig.appUrl }}
      SITE_OWNER: {{ .Values.twofauthConfig.siteOwnerEmail }}
      AUTHENTICATION_GUARD: {{ .Values.twofauthConfig.authenticationGuard }}
      {{- if eq .Values.twofauthConfig.authenticationGuard "reverse-proxy-guard" }}
      AUTH_PROXY_HEADER_FOR_USER: {{ .Values.twofauthConfig.authProxyHeaderUser }}
      AUTH_PROXY_HEADER_FOR_EMAIL: {{ .Values.twofauthConfig.authProxyHeaderEmail }}
      {{- end }}
      WEBAUTHN_USER_VERIFICATION: {{ .Values.twofauthConfig.webauthnUserVerification }}
      {{- with .Values.twofauthConfig.trustedProxies }}
      TRUSTED_PROXIES: {{ join "," . | quote }}
      {{- end -}}
{{- end -}}
