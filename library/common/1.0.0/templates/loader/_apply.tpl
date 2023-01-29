{{/* Loads all spawners */}}

{{- define "ix.v1.common.loader.apply" -}}

  {{/* Render ConfigMap(s) */}}
  {{- include "ix.v1.common.spawner.configmaps" . | nindent 0 -}}

  {{/* Render Secret(s) */}}
  {{- include "ix.v1.common.spawner.secrets" . | nindent 0 -}}

  {{/* Render Image Pull Secrets(s) */}}
  {{- include "ix.v1.common.spawner.imagePullSecrets" . | nindent 0 -}}

{{- end -}}
