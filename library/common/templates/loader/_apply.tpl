{{/* Loads all spawners */}}
{{- define "ix.v1.common.loader.apply" -}}

  {{/* Make sure there are not any YAML errors */}}
  {{- include "ix.v1.common.values.validate" .Values -}}

  {{/* Render ConfigMap(s) */}}
  {{- include "ix.v1.common.spawner.configmap" . | nindent 0 -}}

  {{/* Render Certificate(s) */}}
  {{- include "ix.v1.common.spawner.certificate" . | nindent 0 -}}

  {{/* Render Secret(s) */}}
  {{- include "ix.v1.common.spawner.secret" . | nindent 0 -}}

  {{/* Render Image Pull Secrets(s) */}}
  {{- include "ix.v1.common.spawner.imagePullSecret" . | nindent 0 -}}

  {{/* Render Service Accounts(s) */}}
  {{- include "ix.v1.common.spawner.serviceAccount" . | nindent 0 -}}

  {{/* Render RBAC(s) */}}
  {{- include "ix.v1.common.spawner.rbac" . | nindent 0 -}}

  {{/* Render External Interface(s) */}}
  {{- include "ix.v1.common.spawner.externalInterface" . | nindent 0 -}}

  {{/* Render PVC(s) */}}
  {{- include "ix.v1.common.spawner.pvc" . | nindent 0 -}}

  {{/* Render Workload(s) */}}
  {{- include "ix.v1.common.spawner.workload" . | nindent 0 -}}

  {{/* Render Services(s) */}}
  {{- include "ix.v1.common.spawner.service" . | nindent 0 -}}


{{- end -}}
