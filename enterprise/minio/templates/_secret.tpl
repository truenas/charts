{{- define "minio.creds" -}}
enabled: true
data:
  MINIO_ROOT_USER: {{ required "Expected non-empty <root_user>" .Values.minio.creds.root_user }}
  MINIO_ROOT_PASSWORD: {{ required "Expected non-empty <root_pass>" .Values.minio.creds.root_pass }}
{{- end -}}
