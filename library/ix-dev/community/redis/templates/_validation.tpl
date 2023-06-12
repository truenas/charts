{{- define "redis.validation" -}}
  {{- if not .Values.redisConfig.allowEmptyPassword -}}
    {{- if not .Values.redisConfig.password -}}
      {{- fail "Redis - Field [Password] is required when [Allow Empty Password] is false" -}}
    {{- end -}}
  {{- end -}}

{{- end -}}
