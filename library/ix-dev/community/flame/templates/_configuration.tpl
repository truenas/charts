{{- define "flame.configuration" -}}
secret:
  flame-config:
    enabled: true
    data:
      PORT: {{ .Values.flameNetwork.webPort | quote }}
      PASSWORD: {{ .Values.flameConfig.password | quote }}
{{- end -}}
