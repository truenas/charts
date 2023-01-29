{{/* Loads all spawners */}}

{{- define "ix.v1.common.loader.apply" -}}

  {{/* Render configmap(s) */}}
  {{- include "ix.v1.common.spawner.configmaps" . | nindent 0 -}}

  {{/* Render secret(s) */}}
  {{- include "ix.v1.common.spawner.secrets" . | nindent 0 -}}

{{- end -}}
