{{- define "redis.workload" -}}
workload:
{{- include "ix.v1.common.app.redis" (dict  "secretName" "redis-creds"
                                            "resources" .Values.resources) | nindent 2 }}

{{- end -}}
