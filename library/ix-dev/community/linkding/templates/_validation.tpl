{{- define "linkding.validation" -}}

  {{- if .Values.linkdingConfig.enableAuthProxy -}}
    {{- if not .Values.linkdingConfig.authProxyUsernameHeader -}}
      {{- fail "Linkding - [Auth Proxy Username Header] is required when [Auth Proxy] is enabled" -}}
    {{- end -}}
  {{- end -}}

{{- end -}}
