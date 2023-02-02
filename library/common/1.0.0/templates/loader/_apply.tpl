{{/* Loads all spawners */}}
{{- define "ix.v1.common.loader.apply" -}}

  {{/* Render ConfigMap(s) */}}
  {{- include "ix.v1.common.spawner.configmap" . | nindent 0 -}}

  {{/* Render Secret(s) */}}
  {{- include "ix.v1.common.spawner.secret" . | nindent 0 -}}

  {{/* Render Image Pull Secrets(s) */}}
  {{- include "ix.v1.common.spawner.imagePullSecret" . | nindent 0 -}}

  {{/* Render Service Accounts(s) */}}
  {{- include "ix.v1.common.spawner.serviceAccount" . | nindent 0 -}}

  {{/* Render Workload(s) */}}
  {{- include "ix.v1.common.spawner.workload" . | nindent 0 -}}

{{- end -}}
