{{/* Returns the global annotations */}}
{{- define "ix.v1.common.lib.metadata.globalAnnotations" -}}

  {{- include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $ "annotations" .Values.global.annotations) -}}

{{- end -}}
