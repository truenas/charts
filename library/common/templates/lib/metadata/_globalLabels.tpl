{{/* Returns the global labels */}}
{{- define "ix.v1.common.lib.metadata.globalLabels" -}}

  {{- include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $ "labels" .Values.global.labels) -}}

{{- end -}}
