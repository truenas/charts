{{- define "linkding.validation" -}}

  {{- if .Values.linkdingConfig.enableAuthProxy -}}
    {{- if not .Values.linkdingConfig.authProxyUsernameHeader -}}
      {{- fail "Linkding - [Auth Proxy Username Header] is required when [Auth Proxy] is enabled" -}}
    {{- end -}}
  {{- end -}}

  {{- if or .Values.linkdingConfig.username .Values.linkdingConfig.password -}}
    {{- if not (and .Values.linkdingConfig.username .Values.linkdingConfig.password) -}}
      {{- fail "Linkding - Expected none or both [Username] and [Password] set, but only 1 set." -}}
    {{- end -}}
  {{- end -}}

{{- end -}}
