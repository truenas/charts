{{- define "twofauth.validation" -}}
  {{- if eq .Values.twofauthConfig.authenticationGuard "reverse-proxy-guard" -}}

    {{- if not .Values.twofauthConfig.authProxyHeaderUser -}}
      {{- fail "[Auth Proxy Header User] is required when using reverse-proxy-guard" -}}
    {{- end -}}

    {{- if not .Values.twofauthConfig.authProxyHeaderEmail -}}
      {{- fail "[Auth Proxy Header Email] is required when using reverse-proxy-guard" -}}
    {{- end -}}

  {{- end }}
{{- end -}}
