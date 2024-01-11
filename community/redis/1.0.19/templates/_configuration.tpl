{{- define "redis.configuration" -}}
configmap:
  config:
    enabled: true
    data:
      REDIS_PORT_NUMBER: {{ .Values.redisNetwork.redisPort | quote }}
      ALLOW_EMPTY_PASSWORD: {{ ternary "yes" "no" .Values.redisConfig.allowEmptyPassword | quote }}
      {{- if not .Values.redisConfig.allowEmptyPassword }}
      REDIS_PASSWORD: {{ .Values.redisConfig.password | quote }}
      {{- end }}
{{- end -}}
