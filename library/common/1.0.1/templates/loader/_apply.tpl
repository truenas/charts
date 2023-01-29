{{/* Loads all spawners */}}

{{- define "ix.v1.common.loader.apply" -}}
  {{/* Render configmap(s) */}}
  {{- include "ix.v1.common.spawner.configmaps" . | nindent 0 -}}

{{- end -}}
